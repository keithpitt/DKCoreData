//
//  DKDataImporter.m
//  DiscoKit
//
//  Created by Keith Pitt on 30/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKCoreDataImporter.h"

#import "DKManagedObject.h"
#import "DKSupport.h"

// The importer expects data to be formatted like such:
// [ { "fg_spec_post" => { "name" => "Effective importing in Objective C" } }, 
//   { "fg_spec_user" => { "username" => "keithpitt" } } ]

@implementation DKCoreDataImporter

+ (void)import:(DKCoreDataImporterBlock)callback {
    
    return [self import:callback completion:nil background:NO];
    
}

+ (void)import:(DKCoreDataImporterBlock)callback
    completion:(DKCoreDataImporterCompletionBlock)completion {
    
    return [self import:callback completion:completion background:NO];
    
}

+ (void)import:(DKCoreDataImporterBlock)callback
    background:(BOOL)background {
    
    return [self import:callback completion:nil background:background];
    
}

+ (void)import:(DKCoreDataImporterBlock)callback
    completion:(DKCoreDataImporterCompletionBlock)completion
    background:(BOOL)background {
    
    // Grab the shared persistent store coordinator from DKCoreData
    NSPersistentStoreCoordinator * coordinator = [DKCoreData shared].persistentStoreCoordinator;
    
    // Create an instance of our importer
    DKCoreDataImporter * importer = [[DKCoreDataImporter alloc] initWithPersistentStoreCoordinator:coordinator
                                                                               mainBlock:callback
                                                                         completionBlock:completion
                                                                            inBackground:background
                                                                     parentDispatchQueue:dispatch_get_current_queue()];
    
    // Run in thread
    if (background) {
        [importer performSelectorInBackground:@selector(start) withObject:nil];
    } else {
        [importer start];
    }
    
    // Release our hold on the importer. When we add it to the NSOperationQueue,
    // it increments the retainCount of it. That means, when its finished the
    // operation, it will just release itself!
    [importer release];
    
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator
                               mainBlock:(DKCoreDataImporterBlock)block
                         completionBlock:(DKCoreDataImporterCompletionBlock)completion
                            inBackground:(BOOL)background
                     parentDispatchQueue:(dispatch_queue_t)parentDispatchQueue {
    
    if ((self = [super init])) {
        
        // Store the persistent store coordinator and retain it.
        persistentStoreCoordinator = coordinator;
        [persistentStoreCoordinator retain];
        
        // Whether or not the import is running in the background
        backgrounded = background;
        
        // Copy the import and complete blocks onto the operation
        importBlock = Block_copy(block);
        completeBlock = Block_copy(completion);
        
        // Retain a reference to the parent queue
        parentQueue = parentDispatchQueue;
        dispatch_retain(parentQueue);
        
        // Default loop limit. This may be a configuration at a later
        // date.
        loopLimit = 200;
        
    }
    
    return self;
    
}

- (void)mergeChanges:(NSNotification * )notification {
    
    NSManagedObjectContext * mainContext = [DKCoreData shared].managedObjectContext;
    
    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:backgrounded]; // Only wait to finish if we're in a background thread
    
}

- (void)start {
    
    // While this is running, we want to keep ahold of outself.
    [self retain];
    
    // Apple recomends that we create a new NSManagedObjectContext per thread.
    // Passing NSManagedObjectContexts per thread will cause major headaches
    // because it will constantly send objects between threads. Locking will
    // become an issue at this point as well.
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    // Set the persistent store coordinator on the managed object context. There is
    // generally only one of these per application.
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    // Apple also recomends we turn off the undo manager when we import
    // large amounts of data to CoreData. The Undo Manager tracks all sorts of
    // changes on objects. We don't really need this functionality when we're
    // straight importing data.
    [managedObjectContext setUndoManager:nil];
    
    // Set the merge policy
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    // Setup an observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:managedObjectContext];
    
    // Because the import is going to load a signifigant amount
    // of autoreleased objects (strings, numbers, etc) its more efficent
    // for us to create our own NSAutoReleasePool, as apposed to using the
    // one in the main thread.
    pool = [NSAutoreleasePool new];
    
    // Run the import block
    importBlock(self);
    
    // Drain the pool for the last time
    [pool drain];
    
    // Remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:managedObjectContext];
    
    // Release our managed object context
    [managedObjectContext release];
    
    // If we have a completeBlock
    if (completeBlock) {
        // If the import has been backgrounded, run the completeBlock
        // in the main thread (usually the UI thread), but if we are running
        // synchronously, just run it in the main thread.
        if (backgrounded) {;
            dispatch_async(parentQueue, completeBlock);
        } else {
            completeBlock();
        }
    }
    
    // Yay, we're done! Release ourselfs...
    [self release];
    
}

- (NSArray *)fetchRecordsFrom:(Class)entity primaryKey:(NSString *)primaryKey ids:(NSArray *)ids {
    
    DKCoreDataQuery * relation = [[entity class] performSelector:@selector(query)];
    
    // Set the managed object context to the one in this thread
    [relation managedObjectContext:managedObjectContext];
    
    // Where the primary is in the list of IDs we have
    [relation where:primaryKey isIn:ids];
    
    // Only the primary key
    [relation only:primaryKey];
    
    // Order by the primary key
    [relation orderBy:primaryKey ascending:YES];
    
    return [relation results];
    
}

- (NSArray *)extractAndSortIDsFrom:(NSArray *)records range:(NSRange)range {

    // Create a smaller array with the range specified
    NSArray * slicedArray = [records subarrayWithRange:range];
    
    // Create another array that will hold all the IDs
    NSArray * ids = [slicedArray collectWithKey:@"id"];
    
    // Sort them
    return [ids sortedArrayUsingSelector: @selector(compare:)];
    
}

- (BOOL)import:(NSArray *)data toEntityClass:(Class)entity {
    
    // What is the primary key for this entity?
    NSString * primaryKey = [[entity class] performSelector:@selector(primaryKey)];
    
    // Start count
    NSInteger indexInCurrentIteration = 0, iterationCount = 0, index = 0, changes = 0, existingRecordIndex;
    
    // Total data count
    NSInteger totalDataCount = [data count];
    
    // Starting range
    NSRange range;
    
    NSArray * existingRecords;
    NSArray * sortedIDs;
    
    DKManagedObject * managedObject = nil;
    
    NSError * error = nil;
    
    // Place holder for inserting new record boolean
    BOOL newRecord = YES;
    
    for (NSDictionary * record in data) {
        
        if (index % loopLimit == 0) {
            
            iterationCount++;
            
            // The lowerBound & upperBound of the possible range
            // EG: (0, 200), (200, 400), (600, 800)
            int upperBound = iterationCount * loopLimit;
            int lowerBound = index;
            
            // The actual length of the range
            int rangeLength;
            
            if (upperBound > totalDataCount) {
                rangeLength = totalDataCount - lowerBound;
            } else {
                rangeLength = loopLimit;
            }
            
            range = NSMakeRange(lowerBound, rangeLength);
            
            // Extract and sort the IDs from the data being passed in
            sortedIDs = [self extractAndSortIDsFrom:data
                                              range:range];
            
            // Find all the existing records in the same order as the
            // sorted IDs.
            existingRecords = [self fetchRecordsFrom:entity
                                          primaryKey:primaryKey
                                                 ids:sortedIDs];
            
            // Reset the walking existing record index
            existingRecordIndex = 0;
            
            // Reset the iteration counter
            indexInCurrentIteration = 0;
            
        }
        
        // If we have found some existing records...
        if ([existingRecords count] > 0) {
            
            if ([existingRecords count] > existingRecordIndex) {
                managedObject = [existingRecords objectAtIndex:existingRecordIndex];
            }
            
            if (managedObject && ([[managedObject valueForKey:primaryKey] intValue] != [[sortedIDs objectAtIndex:indexInCurrentIteration] intValue])) {
                
                // We can't use this managed object, set it to nil
                // so the code below will build a new one for us.
                managedObject = nil;
                
            } else {
                
                // This is not a new record
                newRecord = NO;    
                
            }
            
            // Increment the existing record index walker.
            existingRecordIndex++;
            
        }
        
        // Does the record we're importing have a primary key?
        if ([record valueForKey:@"id"]) {
        
            // If we don't have a managed object, create one.
            if (!managedObject) {
                managedObject = [[entity class] performSelector:@selector(buildInManagedObjectContext:)
                                                     withObject:managedObjectContext];
                
                newRecord = YES;
            }
            
            // Synchronize the object
            [managedObject updateAttributes:record];
            
            // Call the afterImport hook on the record
            [managedObject afterImport];
            
            if (newRecord) {
                // Do something like [managedObject afterCreate];
            }
            
            changes++;
            
        }
        
        // Don't need this anymore
        managedObject = nil;
        
        // Increment the counters
        indexInCurrentIteration++;
        index++;
        
        // If we've reached our actualLoopLimit, save the import to the persistend
        // store, and clean up.
        if (indexInCurrentIteration == range.length) {
            
            // Save to the persistent store
            if (![managedObjectContext save:&error]) {
                NSLog(@"%@", [error localizedDescription]);
                abort();
            }
            
            // Reset the managed object context
            [managedObjectContext reset];
            
            // Drain the NSAutoReleasePool
            [pool drain], pool = [[NSAutoreleasePool alloc] init];
            
        }
        
    }
    
    // If the count doesn't equal 0, that means the for loop above finished
    // with some unsaved records. Just repeat the same save process here.
    if (indexInCurrentIteration != 0) {
        
        // Save to the persistent store
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            abort();
        }
        
        // Reset the managed object context
        [managedObjectContext reset];
        
    }
    
    // If the index is more than 0, it means we actually
    // imported something.
    if (changes > 0) {
        return true;
    } else {
        return false;
    }
    
}

- (BOOL)import:(NSArray *)data {
    
    BOOL successfull = true;
    
    // We want to retain the data while we're importing it
    [data retain];
    
    // This is where we split up all the data. For example, we may have
    // an import that looks like this:
    //
    // [ { "user" => { ... } }, { "job" => { ... } } ]
    //
    // We create an dictionary, with a key of "user" and an array of all
    // the values that were found.
    //
    // I've done some benchmarking on this method, it averages out at about
    // 0.something. This speed seems reasonable. Need to do some testing on
    // the phone however.
    
    NSMutableDictionary * seperated = [[NSMutableDictionary alloc] init];
    NSArray * keys;
    NSString * key;
    
    for (NSDictionary * record in data) {
        
        // Keys for the JSON object
        keys = [record allKeys];
        
        // If there are more keys for the record, skip it. Invalid format.
        if ([keys count] > 1) {
            NSLog(@"[DKDataImporter] Skipping %@ due to invalid format. Needs to be scoped by model name like this: { \"user\" => ... }", record);
            continue;
        }
        
        key = [keys objectAtIndex:0];
        
        // If we haven't created an NSMutableArray at that key value yet,
        // create one.
        if (![seperated objectForKey:key])
            [seperated setValue:[[NSMutableArray alloc] init] forKey:key];
        
        // Add the record to the array
        [((NSMutableArray *)[seperated objectForKey:key]) addObject:[record objectForKey:key]];
        
    }
    
    // Did we find anything to import?
    if ([[seperated allKeys] count] == 0) {
        
        // Release the data
        [data release];
        
        // Return false because we failed in importing anything
        return false;
        
    }
    
    NSDictionary * classNames = [[DKCoreData shared] entityClassNames];
    
    NSString * classifiedEntityName;
    NSString * entityClassName;
    NSArray * reversedEntityClassNames;
    
    for (NSString * entity in seperated) {
        
        // Import the sepearated records. We classify the entity name
        // as a best guess for what the entity name is called. At some
        // point I'll make this overridable, somehow. Probably though a
        // [importer import:array withMapping:[NSDictionary ...]
        classifiedEntityName = [entity classify];
        reversedEntityClassNames = [classNames allKeysForObject:classifiedEntityName];
        
        if ([reversedEntityClassNames count] == 0) {
            
            NSLog(@"[DKDataImporter] Could not locate %@ in the following class names. Have you updated your Core Data models and cleaned/deleted from iDevice? %@", classifiedEntityName, classNames);
            successfull = false;
            
        } else {        
            entityClassName = [reversedEntityClassNames objectAtIndex:0];
            
            // If the import wasn't successfull
            if(![self import:[seperated objectForKey:entity] toEntityClass:NSClassFromString(entityClassName)]) {
                successfull = false;
            }
        }
        
    }
    
    // Release the seperated dictionary we created
    [seperated release];
    
    // Release the data
    [data release];
    
    return successfull;
    
}

- (void)dealloc {
    
    // Release our persistent store coordinator
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    
    // Release our blocks
    Block_release(importBlock), importBlock = nil;
    Block_release(completeBlock), completeBlock = nil;
    
    // Release our hold on the parent queue
    dispatch_release(parentQueue), parentQueue = nil;
    
    [super dealloc];
    
}

@end