//
//  DKDataImporter.h
//  DiscoKit
//
//  Created by Keith Pitt on 30/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DKCoreDataImporter;

typedef void (^DKCoreDataImporterBlock)(DKCoreDataImporter *);
typedef void (^DKCoreDataImporterCompletionBlock)(void);

@interface DKCoreDataImporter : NSObject {
    
    NSAutoreleasePool * pool;

    NSManagedObjectContext * managedObjectContext;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    
    DKCoreDataImporterBlock importBlock;
    DKCoreDataImporterCompletionBlock completeBlock;
    
    BOOL backgrounded;
    
    NSInteger loopLimit;
    
    dispatch_queue_t parentQueue;
    
}

+ (void)import:(DKCoreDataImporterBlock)callback;

+ (void)import:(DKCoreDataImporterBlock)callback
    completion:(DKCoreDataImporterCompletionBlock)completion;

+ (void)import:(DKCoreDataImporterBlock)callback
    background:(BOOL)background;

+ (void)import:(DKCoreDataImporterBlock)callback
    completion:(DKCoreDataImporterCompletionBlock)completion
    background:(BOOL)background;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator
                               mainBlock:(DKCoreDataImporterBlock)block
                         completionBlock:(DKCoreDataImporterCompletionBlock)completion
                            inBackground:(BOOL)background
                     parentDispatchQueue:(dispatch_queue_t)parentDispatchQueue;

- (void)start;

- (BOOL)import:(NSArray *)data;
- (BOOL)import:(NSArray *)data toEntityClass:(Class)entity;

@end