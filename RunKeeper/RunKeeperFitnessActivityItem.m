//
//  RunKeeperFitnessActivityItem.m
//  RunKeeper-iOS
//
//  Created by Falko Buttler (www.bluebamboo.de) on 5/2/13.
//

#import "RunKeeperFitnessActivityItem.h"

@implementation RunKeeperFitnessActivityItem

// For debugging purposes
- (NSString*)description
{
    return [NSString stringWithFormat:@"Date: %@, type: %@, distance: %.2f, duration: %.2f, uri: %@",
            _startTime, [RunKeeper activityString:_activityType], _totalDistanceInMeters, _durationInSeconds, _uri];
}

@end
