//
//  AppData.m
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppData.h"
#import "RunKeeper.h"

#define kRunKeeperClientID @"055cac1c950b46e6ac7910d62800a854"
#define kRunKeeperClientSecret @"fecafee9ecfa43fab1dc25fb883066fb"

@implementation AppData

SYNTHESIZE_SINGLETON_FOR_CLASS(AppData)

@synthesize runKeeper;

- (RunKeeper*)runKeeper
{
    if (runKeeper != nil) {
        return runKeeper;
    }
    
    self.runKeeper = [[RunKeeper alloc] initWithClientID:kRunKeeperClientID clientSecret:kRunKeeperClientSecret];
    return runKeeper;
    
}

@end


