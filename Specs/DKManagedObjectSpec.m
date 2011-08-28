//
//  DKManagedObjectSpec.m
//  DiscoKit
//
//  Created by Keith Pitt on 23/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKCoreDataQuery.h"
#import "FGSpecComment.h"

#import "FGSpecPost.h"
#import "FGSpecUser.h"
#import "FGSpecProfile.h"

SPEC_BEGIN(DKManagedObjectSpec)

describe(@"DKManagedObject", ^{
    
    afterEach(^{
        [FGSpecUser destroyAll];
        [FGSpecProfile destroyAll];
    });
    
    describe(@"+primaryKey", ^{
        
        it(@"should default to 'identifier'", ^{
            expect([FGSpecUser primaryKey]).toEqual(@"identifier");
        });
        
    });
    
    describe(@"+entityName", ^{
        
        it(@"should automatically look up entity names", ^{
            expect([FGSpecPost entityName]).toEqual(@"Post");
            expect([FGSpecUser entityName]).toEqual(@"User");
            expect([FGSpecProfile entityName]).toEqual(@"Profile");
        });
        
    });
    
    describe(@"+build", ^{
        
        it(@"should create an empty instance of the object", ^{
            FGSpecUser *user = [FGSpecUser build];
            
            expect(user).toBeInstanceOf([FGSpecUser class]);
            expect(user.firstName).toBeNil();
            expect(user.lastName).toBeNil();
        });
        
    });
    
    describe(@"+buildWithDictionary", ^{
        
        it(@"should create a new instance of the object and set properties from the dictionary", ^{
            FGSpecUser *user = [FGSpecUser buildWithDictionary:
                                [NSDictionary dictionaryWithObjectsAndKeys:@"Keith", @"firstName", @"Pitt", @"lastName", nil]];
            
            expect(user.firstName).toEqual(@"Keith");
            expect(user.lastName).toEqual(@"Pitt");
        });
        
    });
    
    describe(@"+destroyAll", ^{
        
        it(@"should mark all the objects as ready for deletion", PENDING);
        
    });
    
    describe(@"+find", ^{
        
        it(@"should find an object based off the primary key", ^{
            FGSpecUser *user = [FGSpecUser buildWithDictionary:
                                [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:12], @"identifier", nil]];
            FGSpecUser *found = [FGSpecUser find:[NSNumber numberWithInt:12]];
            
            expect(user).toEqual(found);
        });
        
    });
    
    describe(@"+findOrBuildBy", ^{
        
        it(@"should find and build by the attribute", PENDING);
        
    });
    
    describe(@"-destroy", ^{
        
        it(@"should add the object to the managed object context deleted objects array", ^{
            FGSpecUser *user = [FGSpecUser build];
            [user destroy];
            NSSet * deletedObjects = [[[DKCoreData shared] managedObjectContext] deletedObjects];
            
            expect([deletedObjects allObjects]).toContain(user);
        });
        
    });
    
    describe(@"-serialize", ^{
        
        it(@"should return a JSON representation of the object", ^{
            FGSpecUser *user = [FGSpecUser buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"me@keithpitt.com", @"email",
                                                                [NSNumber numberWithInt:55], @"identifier",
                                                                [NSNumber numberWithBool:YES], @"active",
                                                                nil]];
            
            NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"me@keithpitt.com", @"email",
                                      [NSNumber numberWithInt:55], @"id",
                                      [NSNumber numberWithInt:0], @"followers_count",
                                      @"true", @"active",
                                      nil];
            
            expect([user serialize]).toEqual([NSDictionary dictionaryWithObject:expected forKey:@"user"]);
        });
        
    });
    
    describe(@"-serializeWithAssociations", ^{
        
        it(@"should return a JSON representation of the object with 1 to 1 associations", ^{
            FGSpecUser *user = [FGSpecUser buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"me@keithpitt.com", @"email",
                                                                [NSNumber numberWithInt:66], @"identifier",
                                                                nil]];
            
            user.profile = [FGSpecProfile buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"Been a long time...", @"biography", 
                                                               nil]];
            
            NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"me@keithpitt.com", @"email",
                                      [NSNumber numberWithInt:66], @"id",
                                      [NSNumber numberWithInt:0], @"followers_count",
                                      @"false", @"active",
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Been a long time...", @"biography", 
                                       nil], @"profile_attributes",
                                      [NSDictionary dictionary], @"comments_attributes",
                                      nil];
            
            expect([user serializeWithAssociations:YES]).toEqual([NSDictionary dictionaryWithObject:expected forKey:@"user"]);
        });
        
        it(@"should return a JSON representation of the object with 1 to many associations", ^{
            FGSpecUser *user = [FGSpecUser buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"me@keithpitt.com", @"email",
                                                                [NSNumber numberWithInt:12], @"identifier",
                                                                nil]];
            
            [FGSpecComment buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:user, @"user", @"Comment #1", @"body", nil]];
            [FGSpecComment buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:user, @"user", @"Comment #2", @"body", nil]];
            [FGSpecComment buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:user, @"user", @"Comment #3", @"body", nil]];
            
            [[DKCoreData shared] saveManagedObjectContext];
            
            NSDictionary * json = [user serializeWithAssociations:YES];
            NSArray * jsonComments = [[[json valueForKey:@"user"] valueForKey:@"comments_attributes"] allValues];
            
            NSDictionary * comment1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment #1", @"body", nil];
            NSDictionary * comment2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment #2", @"body", nil];
            NSDictionary * comment3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment #3", @"body", nil];
            
            expect(jsonComments).toContain(comment1);
            expect(jsonComments).toContain(comment2);
            expect(jsonComments).toContain(comment3);
        });
        
    });
    
    describe(@"- (id)formData:(DKAPIFormData *)formData valueForKey:(NSString *)key", ^{
        
        it(@"should return the primary key", ^{
            
            FGSpecUser *user = [FGSpecUser buildWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"me@keithpitt.com", @"email",
                                                                [NSNumber numberWithInt:12], @"identifier",
                                                                nil]];
            
            expect([user performSelector:@selector(formData:valueForKey:) withObject:nil withObject:nil]).toEqual(user.identifier);
            
        });
        
    });
    
});

SPEC_END