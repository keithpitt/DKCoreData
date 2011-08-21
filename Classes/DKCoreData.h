//
//  DKCoreData.h
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DKCoreData : NSObject {

@private
    
    NSString * modelName;
    NSString * databaseName;
    NSString * databaseVersion;
    
    NSBundle * sourceBundle;
    NSDictionary * entityClassNames;

    NSManagedObjectContext * managedObjectContext;
    NSManagedObjectModel * managedObjectModel;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    
}

@property (nonatomic, retain, readonly) NSDictionary * entityClassNames;
@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (DKCoreData *)shared;

- (id)initWithDatabase:(NSString *)name bundle:(NSBundle *)bundle;
- (id)initWithDatabase:(NSString *)name version:(NSString *)version bundle:(NSBundle *)bundle;
- (void)deleteDatabase;
- (void)saveManagedObjectContext;

@end