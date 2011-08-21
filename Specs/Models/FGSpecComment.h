//
//  FGSpecComment.h
//  DiscoKit
//
//  Created by Keith Pitt on 18/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@class FGSpecUser;

@interface FGSpecComment : DKManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) FGSpecUser * user;

@end