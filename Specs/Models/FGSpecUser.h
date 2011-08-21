//
//  FGSpecUser.h
//  DiscoKit
//
//  Created by Keith Pitt on 18/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@class FGSpecComment, FGSpecProfile;

@interface FGSpecUser : DKManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet * comments;
@property (nonatomic, retain) FGSpecProfile * profile;

- (void)addCommentsObject:(FGSpecComment *)value;

@end