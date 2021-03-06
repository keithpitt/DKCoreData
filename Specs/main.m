//
//  main.m
//  Specs
//
//  Created by Keith Pitt on 21/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cedar-iPhone/Cedar.h>

#import "DKCoreData.h"

int main(int argc, char *argv[]) {
    
    DKCoreData * coreData = [[DKCoreData alloc] initWithDatabase:@"Specs" bundle:nil];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int retVal = UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
    [pool release];
    
    [coreData release];
    
    return retVal;
    
}