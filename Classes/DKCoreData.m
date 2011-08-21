//
//  DKCoreData.m
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKCoreData.h"

@implementation DKCoreData

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator, entityClassNames;

static DKCoreData * sharedDKCoreData = nil;

+ (DKCoreData *)shared {
    
    if (sharedDKCoreData == nil) {
        
        NSLog(@"Tried to access the shared DKCoreData instance, but it hasn't been defined yet.");
        
        // Do this somewhere, most likely in your app delegate:
        // 
        // DKCoreData * coreData = [[DKCoreData alloc] initWithDatabase:@"TheNameOfYour.xcdatamodeld" bundle:nil];
        //
        // Be sure to release it in your dealloc method aswell.
        
        abort();
        
    }
    
    // return the instance of this class
    return sharedDKCoreData;
    
}

- (id)initWithDatabase:(NSString *)name bundle:(NSBundle *)bundle {
    
    return [self initWithDatabase:name version:nil bundle:bundle];
    
}

- (id)initWithDatabase:(NSString *)name version:(NSString *)version bundle:(NSBundle *)bundle {
    
    if ((self = [super init])) {
        
        // What bundle do we want to use? Default to the main one.
        sourceBundle = bundle ? bundle : [NSBundle mainBundle];
        
        // The database name
        databaseName = [NSString stringWithFormat:@"%@.sqlite", name];
        [databaseName retain];
        
        // The name of the model
        modelName = name;
        [modelName retain];
        
        // Database version
        databaseVersion = version;
        
        // Set the shared instance
        sharedDKCoreData = self;
        
    }
    
    return self;
    
}

- (void)log:(NSString*)message {
    
    NSLog(@"[DKCoreData] %@", message);
    
}

- (void)error:(NSError*)error {
    
    [self log:[NSString stringWithFormat:@"%@, @%@", error, [error localizedDescription]]];
    
}

- (NSURL*)documentsDirectory {
    
    // Create an instance of the file manager. We don't use the shared
    // one because its not thread safe.
    NSFileManager *fileManager = [NSFileManager new];
    
    // Find the documents directory.
    NSURL *directory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *directoryPath = [directory path];
    
    // Make sure the root path exists
    if(![fileManager fileExistsAtPath:directoryPath])
        [fileManager createDirectoryAtPath:directoryPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    
    // Release the file manager
    [fileManager release];
    
    return directory;
    
}

- (NSString*)databasePath {
    
    return [[[self documentsDirectory] path] stringByAppendingPathComponent:databaseName];
    
}

- (NSURL*)databaseURL {
    
    return [[self documentsDirectory] URLByAppendingPathComponent:databaseName];
    
}

- (void)deleteDatabase {
    
    // Create an instance of the file manager. We don't use the shared
    // one because its not thread safe.
    NSFileManager *fileManager = [NSFileManager new];
    
    // The database path
    NSString *databasePath = [self databasePath];
    
    // Only go to delete if we have the file
    if ([fileManager fileExistsAtPath:databasePath]) {
        
        // Attempt to delete the file
        NSError *error = nil;
        [fileManager removeItemAtPath:databasePath
                                error:&error];
        
        if (error) {
            NSLog(@"[DKCoreData] Could not delete database %@", databasePath);
            NSLog(@"%@", error);
        }
        
    }
    
    [fileManager release];
    
}

- (void)copyDatabaseIfRequired {
    
    // Create an instance of the file manager. We don't use the shared
    // one because its not thread safe.
    NSFileManager *fileManager = [NSFileManager new];
    
    // The database path
    NSString *databasePath = [self databasePath];
    
    // Does the file already exist?
    if (![fileManager fileExistsAtPath:databasePath]) {
    
        // Grab the database from the bundle.
        NSString *defaultDatabase = [[sourceBundle resourcePath]
                                     stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", databaseName]];
        
        // If we have one in the bundle...
        if ([fileManager fileExistsAtPath:defaultDatabase]) {
        
            // Attempt to write it to the file system.
            NSError *error = nil;
            bool success = [fileManager copyItemAtPath:defaultDatabase
                                                toPath:databasePath
                                                 error:&error];
            
            if (!success) {
                [self error:error];
                abort();
            }
            
        }
        
    }
    
    [fileManager release];
    
}

- (NSDictionary *)entityClassNames {
    
    // Returns the entity mapping if we already have one.
    if (entityClassNames != nil) {
        return entityClassNames;
    }
    
    // Create a mapping of entity names to class names. For example, if you
    // have an entity called Job, and its represented by a class called TDJob,
    // then the mapping will contain "TDJob" => "Job". This is usefull for automatically
    // finding out the entity based on the class name.
    
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] init];
    NSArray *entities = [self.managedObjectModel entities];
    
    for (NSEntityDescription *entity in entities)
        [mapping setValue:[entity name] forKey:[entity managedObjectClassName]];
    
    entityClassNames = mapping;
	
    return entityClassNames;
    
}

- (NSManagedObjectContext *)managedObjectContext {

    // Returns the managed object context for the application.
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    // Create and bind to the persistent store coordinator.
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
	
    return managedObjectContext;
	
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // Returns the managed object model for the application.
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    // Create from the application's model
    NSURL * model = [sourceBundle URLForResource:modelName withExtension:@"momd"];
    
    // Are we using a paticular version?
    if (databaseVersion)
        model = [model URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mom", databaseVersion]];
    
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:model];
    
    if (!managedObjectModel) {
        NSLog(@"[DKCoreData] Could not find model at %@", [model absoluteURL]);
        abort();
    }
	
    return managedObjectModel;
	
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // Returns the persistent store coordinator for the application.
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // Create our persistent store coordinator
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    // Copy the database from the bundle if we need to.
    [self copyDatabaseIfRequired];
    
    // Merge options
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                              [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    // Connect to the SQLite database
    NSError *error = nil;
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:[self databaseURL]
                                                    options:options
                                                      error:&error];
    
    if (error) {
        [self log:@"An error occured while creating the persistent store coordinator"];
        [self error:error];
        abort();
    }
    
    return persistentStoreCoordinator;
    
}

- (void)saveManagedObjectContext {
    
    // If we have a managed object context
    if (self.managedObjectContext != nil) {
        
        // And there is changes, attempt to save.
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            [self error:error];
            abort();
        }
        
    }
    
}

- (void)dealloc {
    
    [databaseName release];
    [modelName release];
    [sourceBundle release];
    [entityClassNames release];
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
	
}

@end
