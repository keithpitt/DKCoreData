//
//  FGSpecProfile.h
//  DiscoKit
//
//  Created by Keith Pitt on 23/06/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@class FGSpecUser;

@interface FGSpecProfile : DKManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSString * githubUrl;
@property (nonatomic, retain) NSString * myspaceUrl;
@property (nonatomic, retain) FGSpecUser * user;

@end