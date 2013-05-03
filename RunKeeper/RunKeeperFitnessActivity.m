//
//  RunKeeperFitnessActivity.m
//  RunKeeper-iOS
//
//  Created by Falko Buttler on 5/2/13.
//  Copyright 2013 BlueBamboo.de Apps (www.bluebamboo.de). All rights reserved.
//

#import "RunKeeperFitnessActivity.h"

@implementation RunKeeperFitnessActivity

// For debugging purposes
- (NSString*)description
{
    return [NSString stringWithFormat:@"Date: %@, type: %@, distance: %@, duration: %@, calories: %@, uri: %@",
            _startTime, [RunKeeper activityString:_activityType], _totalDistanceInMeters,
            _durationInSeconds, _totalCalories, _uri];
}

@end
