//
//  AppData.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RunKeeper;

@interface AppData : NSObject {
@private
    RunKeeper *runKeeper;    
}

@property (nonatomic, retain) RunKeeper *runKeeper;

+ (AppData*)sharedAppData;

@end
