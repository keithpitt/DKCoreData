//
//  DKCoreDataQuery.m
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKCoreDataQuery.h"

@implementation DKCoreDataQuery

@synthesize entity, managedObjectContext, batchSize, columns;

- (id)init {
    
    if ((self = [super init])) {
        
        // Create the columns mutable array
        columns = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

- (id)initWithEntity:(NSString *)entityName {

    if ((self = [self init])) {
        
        // Copy the entity
        self.entity = entityName;
        
    }
    
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext == nil) {
        
        // Use the shared managed object context
        managedObjectContext = [[DKCoreData shared] managedObjectContext];
        
        // Retain a copy of the managed object context
        [managedObjectContext retain];
        
    }
    
    return managedObjectContext;
    
}

- (DKCoreDataQuery *)managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
    
    // If a mananged object context has already been set,
    // release it and set it to nil.
    if (managedObjectContext) {
        [managedObjectContext release], managedObjectContext = nil;
    }
    
    // Set the managed object context
    managedObjectContext = theManagedObjectContext;
    
    // Retain a copy of the managed object context
    [managedObjectContext retain];
    
    return self;
    
}

- (NSFetchRequest *)fetchRequest {
    
	// Setup a request for an existing object
	NSFetchRequest * fetchRequest = [NSFetchRequest new];
    
    // Set the entity
	[fetchRequest setEntity:[NSEntityDescription entityForName:self.entity
                                        inManagedObjectContext:self.managedObjectContext]];
    
    // Add the predicates
    [fetchRequest setPredicate:[self compoundPredicate]];
    
    // Add the sorters
    [fetchRequest setSortDescriptors:self.sorters];
    
    // Set the limit
    if (self.limit)
        [fetchRequest setFetchLimit:[self.limit integerValue]];
        
    // Set the offset
    if (self.offset)
        [fetchRequest setFetchOffset:[self.offset integerValue]];
    
    // Set the batch size
    if (self.batchSize)
        [fetchRequest setFetchBatchSize:[self.batchSize integerValue]];
    
    // Only fetch these properies
    if ([self.columns count] > 0)
        [fetchRequest setPropertiesToFetch:self.columns];
    
    return [fetchRequest autorelease];
    
}

- (NSArray *)results {
    
    // Perform the fetch
    NSError * error = nil;
	NSArray * objects = [[self managedObjectContext] executeFetchRequest:[self fetchRequest]
                                                                   error:&error];
    
    // executeFetchRequest returns nil if there was an error
    if (objects == nil) {
        NSLog(@"%@", [error localizedDescription]);
        abort();
    }
    
    // TODO: Do something with the error, not sure yet. Perhaps
    // and NSNotification, or some sort of callback? Perhaps I return an
    // NSArray-like object with a #fetchError method attached? A few options
    // I want to explore.
	
	return objects;
    
}

- (NSUInteger)count {
    
    // Perform the count fetch
    NSError * error = nil;
	NSUInteger count = [[self managedObjectContext] countForFetchRequest:[self fetchRequest]
                                                                    error:&error];
    
    // countForFetchRequest returns nil if there was an error
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
        abort();
    }
    
    return count;
    
}

- (id)only:(NSString *)column {
    
    [self.columns addObject:column];
    
    return self;
    
}

- (id)batchSize:(int)value {
    
    // Set the batch size
    self.batchSize = [NSNumber numberWithInt:value];
    
    return self;
    
}

- (DKManagedObject *)firstObject {
    
    // TODO: some sort of results caching here
    return [self count] > 0 ? [[self results] objectAtIndex:0] : nil;
    
}

- (DKManagedObject *)lastObject {
    
    // TODO:We should do some sort of results caching here
    return [self count] > 0 ? [[self results] lastObject] : nil;
    
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    // Create the fetched results controller
    NSFetchedResultsController * fetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:nil 
                                                   cacheName:nil];
    

    return [fetchedResultsController autorelease];
    
}

- (void)dealloc {
    
    [managedObjectContext release];
    [entity release];
    
    [columns release];
    [batchSize release];
    
    [super dealloc];
    
}

@end