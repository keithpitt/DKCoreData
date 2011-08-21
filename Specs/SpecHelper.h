//
//  SpecHelper.h
//  DiscoKit
//
//  Created by Keith Pitt on 21/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#define HC_SHORTHAND

#if TARGET_OS_IPHONE
    #import <Cedar-iPhone/SpecHelper.h>
    #import <OCMock-iPhone/OCMock.h>
#else
    #import <Cedar/SpecHelper.h>
    #import <OCMock/OCMock.h>
#endif

#define EXP_SHORTHAND
#import "Expecta.h"