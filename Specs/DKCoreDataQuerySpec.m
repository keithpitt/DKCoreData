//
//  DKCoreDataQuerySpec.m
//  DiscoKit
//
//  Created by Keith Pitt on 22/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKCoreDataQuery.h"
#import "FGSpecPost.h"

SPEC_BEGIN(DKCoreDataQuerySpec)

describe(@"DKCoreDataQuery", ^{
    
    afterEach(^{
        [FGSpecPost destroyAll];
    });
    
    context(@"#where:isFalse", ^{
        
        __block FGSpecPost * notPublished;
        __block FGSpecPost * published;
        __block DKCoreDataQuery *relation;
        
        beforeEach(^{
            notPublished = [FGSpecPost buildWithDictionary:
                            [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"published"]];
            published = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"published"]];
        });        
        
        context(@"with YES", ^{

            beforeEach(^{
                relation = [[FGSpecPost query] where:@"published" isFalse:YES];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"published == 0"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(notPublished);
                expect(records).Not.toContain(published);
            });
            
        });
        
        context(@"with NO", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"published" isFalse:NO];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"published == 1"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(published);
                expect(records).Not.toContain(notPublished);
            });
            
        });
        
    });
    
    context(@"#where:isTrue", ^{
        
        __block FGSpecPost * notPublished;
        __block FGSpecPost * published;
        __block DKCoreDataQuery *relation;
        
        beforeEach(^{
            notPublished = [FGSpecPost buildWithDictionary:
                            [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"published"]];
            published = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"published"]];
        });        
        
        context(@"with YES", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"published" isTrue:YES];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"published == 1"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(published);
                expect(records).Not.toContain(notPublished);
            });
            
        });
        
        context(@"with NO", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"published" isTrue:NO];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"published == 0"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(notPublished);
                expect(records).Not.toContain(published);
            });
            
        });
        
    });
    
    context(@"#where:isNull", ^{
        
        __block FGSpecPost * withName;
        __block FGSpecPost * noName;
        __block DKCoreDataQuery * relation;
        
        beforeEach(^{
            withName = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"Greatest Post Ever" forKey:@"name"]];
            noName = [FGSpecPost build];
        });        
        
        context(@"with YES", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"name" isNull:YES];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"name == nil"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(noName);
                expect(records).Not.toContain(withName);
            });
            
        });
        
        context(@"with NO", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"name" isNull:NO];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"name != nil"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(withName);
                expect(records).Not.toContain(noName);
            });
            
        });
        
    });
    
    context(@"#where:isNotNull", ^{
        
        __block FGSpecPost * withName;
        __block FGSpecPost * noName;
        __block DKCoreDataQuery * relation;
        
        beforeEach(^{
            withName = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"Greatest Post Ever" forKey:@"name"]];
            noName = [FGSpecPost build];
        });        
        
        context(@"with YES", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"name" isNotNull:YES];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"name != nil"); 
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(withName);
                expect(records).Not.toContain(noName);
            });
            
        });
        
        context(@"with NO", ^{
            
            beforeEach(^{
                relation = [[FGSpecPost query] where:@"name" isNotNull:NO];
            });
            
            it(@"should add the correct predicate", ^{
                NSPredicate *predicate = [relation.predicates objectAtIndex:0];
                
                expect(predicate.predicateFormat).toEqual(@"name == nil");
            });
            
            it(@"should return the correct results", ^{
                NSArray *records = [relation results];   
                
                expect(records).toContain(noName);
                expect(records).Not.toContain(withName);
            });
            
        });
        
    });
    
    context(@"#where:equals", ^{
    
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" equals:[NSNumber numberWithInt:15]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount == 15"); 
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
        
    context(@"#where:doesntEqual", ^{
    
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query ]where:@"commentsCount" doesntEqual:[NSNumber numberWithInt:35]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount != 35"); 
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:like", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"cheese" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"breeze" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"fudge" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" like:@"*ee*"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"name LIKE[cd] \"*ee*\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:startsWith", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"keith" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"kevin" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"steven" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" startsWith:@"ke"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"name BEGINSWITH[cd] \"ke\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:doesntStartWith", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"brains" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"arms" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"bleh" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" doesntStartWith:@"bl"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"NOT name BEGINSWITH[cd] \"bl\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:endsWith", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"ramin" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"kevin" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"steven" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" endsWith:@"in"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"name ENDSWITH[cd] \"in\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:doesntEndWith", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"keith" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"kevin" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"steven" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" doesntEndWith:@"en"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"NOT name ENDSWITH[cd] \"en\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });

    context(@"#where:contains", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"cheese" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"breeze" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"fudge" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" contains:@"ee"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"name CONTAINS[cd] \"ee\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:contains", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"cheese" forKey:@"name"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:@"breeze" forKey:@"name"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:@"fudge" forKey:@"name"]];
            
            relation = [[FGSpecPost query] where:@"name" contains:@"ee"];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"name CONTAINS[cd] \"ee\"");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:isNotIn", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect1;
        __block FGSpecPost *incorrect2;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15] forKey:@"commentsCount"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:10] forKey:@"commentsCount"]];
            
            incorrect1 = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            incorrect2 = [FGSpecPost buildWithDictionary:
                          [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:64] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" 
                                         isNotIn:[NSArray arrayWithObjects:[NSNumber numberWithInt:35], [NSNumber numberWithInt:64], nil]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"NOT commentsCount IN {35, 64}");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect1);
            expect(records).Not.toContain(incorrect2);
        });
        
    });
    
    context(@"#where:isIn", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct1;
        __block FGSpecPost *correct2;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct1 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15] forKey:@"commentsCount"]];
            correct2 = [FGSpecPost buildWithDictionary:
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:10] forKey:@"commentsCount"]];
            
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" 
                                            isIn:[NSArray arrayWithObjects:[NSNumber numberWithInt:15], [NSNumber numberWithInt:10], nil]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount IN {15, 10}");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct1);
            expect(records).toContain(correct2);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:greaterThan", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:563] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" greaterThan:[NSNumber numberWithInt:400]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount > 400"); 
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:greaterThanOrEqualTo", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:563] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" greaterThanOrEqualTo:[NSNumber numberWithInt:563]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount >= 563"); 
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:lessThan", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:12] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" lessThan:[NSNumber numberWithInt:20]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount < 20");
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#where:lessThanOrEqualTo", ^{
        
        __block DKCoreDataQuery *relation;
        __block FGSpecPost *correct;
        __block FGSpecPost *incorrect;
        
        beforeEach(^{
            correct = [FGSpecPost buildWithDictionary:
                       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15] forKey:@"commentsCount"]];
            incorrect = [FGSpecPost buildWithDictionary:
                         [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:35] forKey:@"commentsCount"]];
            
            relation = [[FGSpecPost query] where:@"commentsCount" lessThanOrEqualTo:[NSNumber numberWithInt:15]];
        });
        
        it(@"should add the correct predicate", ^{
            NSPredicate *predicate = [relation.predicates objectAtIndex:0];
            
            expect(predicate.predicateFormat).toEqual(@"commentsCount <= 15"); 
        });
        
        it(@"should return the correct results", ^{
            NSArray *records = [relation results];   
            
            expect(records).toContain(correct);
            expect(records).Not.toContain(incorrect);
        });
        
    });
    
    context(@"#results", ^{
        
        it(@"should return an NSArray of all the records", ^{
            FGSpecPost * firstPost = [FGSpecPost build];
            FGSpecPost * secondPost = [FGSpecPost build];
            [[DKCoreData shared] saveManagedObjectContext];
            
            NSArray *records = [[FGSpecPost query] results];            
            expect(records).toContain(firstPost);
            expect(records).toContain(secondPost);
        });
        
    });
    
    context(@"#count", ^{
        
        it(@"should return an integer of the amount of records that would be returned from the results", ^{
            [FGSpecPost build];
            [FGSpecPost build];
            [[DKCoreData shared] saveManagedObjectContext];
            
            int count = [[FGSpecPost query] count];
            expect(count).toEqual(2);
        });
        
    });
    
    context(@"#firstObject", ^{
        
        it(@"should return the first object in the results", ^{
            FGSpecPost *firstOne = [FGSpecPost buildWithDictionary:
                                    [NSDictionary dictionaryWithObject:@"First One" forKey:@"name"]];
            FGSpecPost *secondOne = [FGSpecPost buildWithDictionary:
                                     [NSDictionary dictionaryWithObject:@"Second One" forKey:@"name"]];
            
            DKCoreDataQuery *relation = [[FGSpecPost query] orderBy:@"name" ascending:YES];
            expect([relation firstObject]).toEqual(firstOne);
            expect([relation firstObject]).Not.toEqual(secondOne);
        });
        
    });
    
    context(@"#lastObject", ^{
        
        it(@"should return the last object in the results", ^{
            FGSpecPost *firstOne = [FGSpecPost buildWithDictionary:
                                    [NSDictionary dictionaryWithObject:@"First One" forKey:@"name"]];
            FGSpecPost *secondOne = [FGSpecPost buildWithDictionary:
                                     [NSDictionary dictionaryWithObject:@"Second One" forKey:@"name"]];
            
            DKCoreDataQuery *relation = [[FGSpecPost query] orderBy:@"name" ascending:YES];
            expect([relation lastObject]).toEqual(secondOne);
            expect([relation lastObject]).Not.toEqual(firstOne);
        });
        
    });
    
    context(@"#fetchRequest", ^{
        
        __block NSFetchRequest *fetchRequest;
        
        beforeEach(^{
            DKCoreDataQuery *relation = [FGSpecPost query];
            [relation where:@"name" equals:@"The Best Post Ever"];
            [relation where:@"commentsCount" between:[NSNumber numberWithInt:10] andThis:[NSNumber numberWithInt:20]];
            [relation orderBy:@"commentsCount" ascending:NO];
            [relation orderBy:@"name" ascending:YES];
            [relation limit:30];
            [relation batchSize:10];
            
            fetchRequest = [relation fetchRequest];
        });
        
        it(@"should have the correct predicates attached", ^{
            expect(fetchRequest.predicate.predicateFormat).
                       toEqual(@"name == \"The Best Post Ever\" AND (commentsCount >= 10 AND commentsCount < 20)");
        });
        
        it(@"should have the correct limit", ^{
            expect(fetchRequest.fetchLimit).toEqual(30);
        });
        
        it(@"should have the correct batch size", ^{
            expect(fetchRequest.fetchBatchSize).toEqual(10);
        });
        
        it(@"should have the correct ordering", ^{            
            NSArray *sortDescriptors = fetchRequest.sortDescriptors;
            NSSortDescriptor *firstDescriptor = [sortDescriptors objectAtIndex:0];
            NSSortDescriptor *secondDescriptor = [sortDescriptors objectAtIndex:1];
            
            expect(firstDescriptor.key).toEqual(@"commentsCount");
            expect(firstDescriptor.ascending).toEqual(NO);
            expect(secondDescriptor.key).toEqual(@"name");
            expect(secondDescriptor.ascending).toEqual(YES);
        });
        
    });
    
    context(@"#fetchedResultsController", ^{
        
        __block DKCoreDataQuery *relation;
        
        beforeEach(^{
            relation = [FGSpecPost query];
        });
        
        it(@"should return an NSFecthedResultsController", ^{
            id fetchedResultsController = [relation fetchedResultsController];
            
            expect(fetchedResultsController).toBeInstanceOf([NSFetchedResultsController class]);
        });
        
        it(@"should have the fetchRequest attached", ^{
            NSFetchedResultsController *fetchedResultsController = [relation fetchedResultsController];
            
            expect(fetchedResultsController.fetchRequest).Not.toBeNil();
        });
        
    });
    
    context(@"#limit", ^{
        
        it(@"should should set the limit on the relation", ^{
            DKCoreDataQuery *relation = [[FGSpecPost query] limit:2];
            
            expect(relation.limit).toEqual([NSNumber numberWithInt:2]);
        });
        
        it(@"should correctly limit the results", ^{
            [FGSpecPost build];
            [FGSpecPost build];
            [FGSpecPost build];
            
            NSArray *records = [[[FGSpecPost query]limit:2] results];
            expect([records count]).toEqual(2);
        });

    });
    
    context(@"#orderBy", ^{
        
        it(@"should add it to the sorters array on the relation", ^{
            DKCoreDataQuery *relation = [[FGSpecPost query] orderBy:@"name" ascending:YES];
            NSSortDescriptor *sortDescriptor = [[relation sorters] objectAtIndex:0];
            
            expect(sortDescriptor.key).toEqual(@"name");
            expect(sortDescriptor.ascending).toEqual(YES);
        });
        
        it(@"should correctly order the results", ^{
            FGSpecPost *firstOne = [FGSpecPost buildWithDictionary:[NSDictionary dictionaryWithObject:@"First One" forKey:@"name"]];
            FGSpecPost *secondOne = [FGSpecPost buildWithDictionary:[NSDictionary dictionaryWithObject:@"Second One" forKey:@"name"]];
            
            NSArray *records = [[[FGSpecPost query] orderBy:@"name" ascending:YES] results];
            
            expect([records objectAtIndex:0]).toEqual(firstOne);
            expect([records objectAtIndex:1]).toEqual(secondOne);
        });
        
    });
    
});

SPEC_END