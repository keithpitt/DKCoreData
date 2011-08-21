//
//  FGSpecUser.m
//  DiscoKit
//
//  Created by Keith Pitt on 18/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "FGSpecUser.h"
#import "FGSpecComment.h"
#import "FGSpecProfile.h"

@implementation FGSpecUser

@dynamic active;
@dynamic password;
@dynamic firstName;
@dynamic email;
@dynamic username;
@dynamic identifier;
@dynamic followersCount;
@dynamic lastName;
@dynamic comments;
@dynamic profile;

- (void)addCommentsObject:(FGSpecComment *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"comments"] addObject:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCommentsObject:(FGSpecComment *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"comments"] removeObject:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addComments:(NSSet *)value {    
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"comments"] unionSet:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeComments:(NSSet *)value {
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"comments"] minusSet:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end