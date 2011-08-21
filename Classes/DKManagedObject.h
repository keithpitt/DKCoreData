//
//  DKManagedObject.h
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DKCoreDataQuery.h"

@interface DKManagedObject : NSManagedObject

+ (NSString *)primaryKey;
+ (NSString *)entityName;

+ (id)build;
+ (id)buildInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)buildWithDictionary:(NSDictionary *)dictionary;
+ (id)buildWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSDictionary*)lookupSynchronizationObject:(NSDictionary *)data;
+ (void)synchronizeFromJSON:(NSArray *)data;

+ (void)destroyAll;

+ (id)find:(NSNumber *)identifier;
+ (id)findOrBuildBy:(NSString *)key value:(id)value;
+ (id)findOrBuildBy:(NSString *)key value:(id)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (DKCoreDataQuery *)query;

- (void)destroy;

- (void)updateAttributes:(NSDictionary *)data;

- (BOOL)isPersistedRemotely;

- (NSDictionary *)serialize;
- (NSDictionary *)serializeWithAssociations:(BOOL)includeAssociations;
- (NSDictionary *)serializeWithAssociations:(BOOL)includeAssociations andIncludeRoot:(BOOL)includeRoot;

- (void)afterImport;

@end