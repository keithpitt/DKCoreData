//
//  DKManagedObject.m
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

#import "DKCoreData.h"
#import "DKSupport.h"
#import "ISO8601DateFormatter.h"

@implementation DKManagedObject

+ (NSString*)primaryKey {
    
    return @"identifier";
    
}

+ (NSString*)entityName {
    
    return [[[DKCoreData shared] entityClassNames] objectForKey:[[self class] description]];
    
}

+ (id)build {
    
    // Build with the default of the shared managed object
    // context.
    return [self buildInManagedObjectContext:[[DKCoreData shared] managedObjectContext]];
    
}

+ (id)buildInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    // Build in a paticular object context
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:managedObjectContext];
    
}

+ (id)buildWithDictionary:(NSDictionary*)dictionary {
    
    // Build within the default managed object context
    return [self buildWithDictionary:dictionary managedObjectContext:[[DKCoreData shared] managedObjectContext]];
    
}

+ (id)buildWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    // Create an instance of the record
    DKManagedObject *record = [self buildInManagedObjectContext:managedObjectContext];
    
    // Loop through the dictionary, and add values to
    // the properties
    for(NSString *property in dictionary)
        [record setValue:[dictionary objectForKey:property] forKey:property];
    
    return record;
    
}

+ (NSDictionary*)lookupSynchronizationObject:(NSDictionary*)data {
    
    // By default Rails returns data that looks like this.
    // [ { "job" => { ... } },  { "job" => { ... } } ]
    // This method attempts to automatically figure out the "job" key.
    // This can be overwritten by the model if need be.
    
    // Does a lowercase version of the entity name exist, and is
    // there only 1 key
    NSString * entity = [[self entityName] lowercaseString];    
    if ([data objectForKey:entity] != nil && [[data allKeys] count] == 1)
        return [data objectForKey:entity];
    
    // If we've gotten this far, just return the original data.
    return data;
    
}

+ (void)synchronizeFromJSON:(NSArray*)data {
    
    bool save = false;
    
    for (NSDictionary *result in data) {
        
        // Find the object
        NSDictionary * object = [self lookupSynchronizationObject:result];
        
        // Find the ID
        NSNumber * identifier = [NSNumber numberWithString:[object objectForKey:@"id"]];
        
        // Find or build by the ID
        DKManagedObject * record = [self findOrBuildBy:[self primaryKey] value:identifier];
        
        // Synchronize the object
        [record updateAttributes:object];
        
        // Mark for save
        save = true;
        
    }
    
    // Save the managed object context if we need to
    if (save)
        [[DKCoreData shared] saveManagedObjectContext];
    
}

+ (void)destroyAll {
    
    NSArray *records = [[self query] results];
    
    for (int i = 0, l = [records count]; i < l; i++)
        [[records objectAtIndex:i] destroy];
    
    [[DKCoreData shared] saveManagedObjectContext];
    
}

+ (id)find:(NSNumber*)identifier {
    
    DKCoreDataQuery * relation = [[self query] where:[self primaryKey] equals:identifier];
    DKManagedObject * object = [relation firstObject];
    
    return object;
    
}

+ (id)findOrBuildBy:(NSString*)key value:(id)value {
    
    return [self findOrBuildBy:key value:value managedObjectContext:[[DKCoreData shared] managedObjectContext]];
    
}

+ (id)findOrBuildBy:(NSString*)key value:(id)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    DKManagedObject *record = [[[[self query] where:key equals:value] managedObjectContext:managedObjectContext] firstObject];
    
    if (!record) {
        record = [self buildInManagedObjectContext:managedObjectContext];
        [record setValue:value forKey:key];
    }
    
    return record;
    
}

+ (DKCoreDataQuery *)query {
    
    DKCoreDataQuery * query = [[DKCoreDataQuery alloc] initWithEntity:[self entityName]];
    
    return [query autorelease];
    
}

- (void)destroy {
    
    [[self managedObjectContext] deleteObject:self];
    
}

- (BOOL)isPersistedRemotely {
    
    NSNumber * remoteIdentifier = [self valueForKey:[[self class] primaryKey]];
    
    return [remoteIdentifier intValue] > 0;
    
}
            
- (NSDictionary*)serialize {

    return [self serializeWithAssociations:NO andIncludeRoot:YES];
    
}

- (NSDictionary*)serializeWithAssociations:(BOOL)includeAssociations {
    
    return [self serializeWithAssociations:includeAssociations andIncludeRoot:YES];
    
}

- (NSDictionary*)serializeWithAssociations:(BOOL)includeAssociations andIncludeRoot:(BOOL)includeRoot {
    
    NSArray * properties = self.entity.properties;
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    
    // For formatting dates
    ISO8601DateFormatter * dateFormatter = [ISO8601DateFormatter new];
    dateFormatter.includeTime = YES;
    
    for (id property in properties) {
        
        // Work out the key to use in the dictionary. We convert
        // columns like "startTime" to "start_time".
        NSPropertyDescription * propertyDescription = property;
        NSString * jsonKey = [[propertyDescription name] underscore];
        
        // The value of the property
        id value = [self valueForKey:[propertyDescription name]];
        
        if ([property isKindOfClass:[NSRelationshipDescription class]]) {

            // Do we want to include assocaitons with this round of JSONification?
            if (includeAssociations) {
            
                // Type cast the property to be a NSRelationshipDescription
                NSRelationshipDescription *relationshipDescription = property;
                
                NSString * associationJsonKey = [NSString stringWithFormat:@"%@_attributes", jsonKey];
                
                if ([relationshipDescription isToMany]) {
                    
                    NSMutableDictionary * associations = [NSMutableDictionary new];
                    
                    NSArray * records = [self valueForKey:[propertyDescription name]];
                    
                    int count = 0;
                    for (DKManagedObject * child in records) {
                        [associations setValue:[child serializeWithAssociations:NO andIncludeRoot:NO] forKey:[NSString stringWithFormat:@"%i", count]];
                        count++;
                    }
                    
                    [attributes setValue:associations forKey:associationJsonKey];
                    [associations release];
                    
                } else {
                    
                    [attributes setValue:[value serializeWithAssociations:NO andIncludeRoot:NO]
                                  forKey:associationJsonKey];
                    
                }
                
            }
            
            continue;
            
        }
        
        // Work out the data type
        NSAttributeDescription * attributeDescription = property;            
        NSAttributeType attributeType = [attributeDescription attributeType];
        
        // Special case for primary key
        if ([[property name] isEqualToString:[[self class] primaryKey]]) {
            
            // Force to be a column name of "id" so Rails likes it better if we have one
            if ([self isPersistedRemotely]) {
                [attributes setValue:(NSString*)value forKey:@"id"];
            }
            
        } else if (attributeType == NSDateAttributeType) {
            
            // Format the date using the ISO8601DateFormatter class
            [attributes setValue:[dateFormatter stringFromDate:(NSDate*)value] forKey:jsonKey];
            
        } else if (attributeType == NSBooleanAttributeType) {
            
            // Format to true/false
            if (value == [NSNumber numberWithBool:YES]) {
                [attributes setValue:@"true" forKey:jsonKey];
            } else {
                [attributes setValue:@"false" forKey:jsonKey];
            }
            
        } else {
            
            [attributes setValue:value forKey:jsonKey];
            
        }
        
    }
    
    [dateFormatter release];
    dateFormatter = nil;
    
    if (includeRoot) {
        
        return [NSDictionary dictionaryWithObject:attributes
                                           forKey:[self.entity.name lowercaseString]];
        
    } else {
        
        return attributes;
        
    }
    
}

- (void)updateAttributes:(NSDictionary*)data {
    
    NSArray *properties = self.entity.properties;
    
    for (id property in properties) {
        
        NSPropertyDescription *propertyDescription = property;
        NSString *jsonKey = [[propertyDescription name] underscore];
        
        // The remote primary jsonKey is always "id"
        if ([[property name] isEqualToString:[[self class] primaryKey]]) {
            jsonKey = @"id";
        }
      
        // If the value is nil or null, skip it aswell
        if ([data objectForKey:jsonKey] == nil || [data objectForKey:jsonKey] == [NSNull null]) {
            continue;
        }
        
        // If it's a relationship, handle it appropriately.
        if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            
            // Find out the destination entity
            NSRelationshipDescription * relationshipDescription = property;
            NSEntityDescription * destination = [relationshipDescription destinationEntity];
            
            // Create the association class
            Class assocaitionClass = NSClassFromString([destination managedObjectClassName]);
            
            if ([relationshipDescription isToMany]) {
                
                // The data for the association.
                NSArray * associations = [data objectForKey:jsonKey];
                NSMutableArray * records = [NSMutableArray array];
                
                for (NSDictionary * jsonData in associations) {
                    
                    // The data for the association.
                    NSDictionary * associationData = [jsonData objectForKey:[[assocaitionClass entityName] lowercaseString]];
                    
                    // Grab the ID and convert it an NSNumber
                    NSNumber * identifier = [NSNumber numberWithString:[associationData objectForKey:@"id"]];
                    
                    // Find or build the assocaition
                    DKManagedObject * record = [assocaitionClass findOrBuildBy:[assocaitionClass primaryKey] value:identifier managedObjectContext:[self managedObjectContext]];
                    [record updateAttributes:associationData];
                    
                    [records addObject:record];
                    
                }
                
                // Set the association back to the base record
                [self setValue:[NSSet setWithArray:records] forKey:[propertyDescription name]];
                
            } else {
                
                // The data for the association.
                NSDictionary * associationData = [data objectForKey:jsonKey];
                
                // Grab the ID and convert it an NSNumber
                NSNumber * identifier = [NSNumber numberWithString:[associationData objectForKey:@"id"]];
                
                // Find or build the assocaition
                DKManagedObject * record = [assocaitionClass findOrBuildBy:[assocaitionClass primaryKey] value:identifier managedObjectContext:[self managedObjectContext]];
                [record updateAttributes:associationData];
                
                // Set the association back to the base record
                [self setValue:record forKey:[propertyDescription name]];
                
            }
            
            continue;
            
        }
        
        NSAttributeDescription * attributeDescription = property;            
        NSString * kind = [attributeDescription attributeValueClassName];
        id value = [data objectForKey:jsonKey];
        
        // NSLog(@"%@.%@ = (%@ = %@ (%@))", [[self entity] name], [propertyDescription name], jsonKey, value, kind);
        
        if ([kind isEqualToString:@"NSDate"]) {
            
            [self setValue:[NSDate dateFromString:value]
                    forKey:[propertyDescription name]];
            
        } else if(value != [NSNull null]) {
            
            [self setValue:value
                    forKey:[propertyDescription name]];
            
        }
        
    }
    
}

- (id)formData:(DKAPIFormData *)formData valueForKey:(NSString *)key {
    
    return [self valueForKey:[[self class] primaryKey]];
    
}

- (void)afterImport {
    
    // Do nothing. This can be overridden by sub classes.
    
}

@end