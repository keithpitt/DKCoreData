//
//  DKCoreDataQuery.h
//  DiscoKit
//
//  Created by Keith Pitt on 15/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DKCoreData.h"
#import "DKPredicateBuilder.h"

@class DKManagedObject;

@interface DKCoreDataQuery : DKPredicateBuilder {
    
    NSString * entity;
    
    NSManagedObjectContext * managedObjectContext;
    
}

@property (nonatomic, retain) NSString * entity;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

- (id)initWithEntity:(NSString *)entityName;

- (NSFetchRequest *)fetchRequest;
- (NSFetchedResultsController *)fetchedResultsController;

- (DKCoreDataQuery *)managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;

- (NSArray *)results;
- (NSUInteger)count;

- (DKManagedObject *)firstObject;
- (DKManagedObject *)lastObject;

@end