//
//  FGSpecImportableUser.m
//  DiscoKit
//
//  Created by Keith Pitt on 6/07/11.
//  Copyright (c) 2011 Mostly Disco. All rights reserved.
//

#import "FGSpecImportableUser.h"

@implementation FGSpecImportableUser

@dynamic active;
@dynamic email;
@dynamic firstName;
@dynamic followersCount;
@dynamic identifier;
@dynamic lastName;
@dynamic password;
@dynamic username;

- (void)afterImport {
    self.password = @"afterImport";
}

@end