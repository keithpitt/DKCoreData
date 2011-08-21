//
//  FGSpecImportableUser.h
//  DiscoKit
//
//  Created by Keith Pitt on 6/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@interface FGSpecImportableUser : DKManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;

@end