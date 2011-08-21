//
//  FGSpecPost.h
//  DiscoKit
//
//  Created by Keith Pitt on 22/06/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@interface FGSpecPost : DKManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * published;

@end
