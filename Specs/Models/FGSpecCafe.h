//
//  FGSpecCafe.h
//  DiscoKit
//
//  Created by Keith Pitt on 14/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "DKManagedObject.h"

@interface FGSpecCafe : DKManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * cafe_type;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSString * name;

@end