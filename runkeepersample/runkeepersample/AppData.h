//
//  AppData.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCSingleton.h"

@class RunKeeper;

@interface AppData : NSObject {
@private
    RunKeeper *runKeeper;    
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(AppData)

@property (nonatomic, strong) RunKeeper *runKeeper;

@end
