//
//  RunKeeperPathPoint.m
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RunKeeperPathPoint.h"


@implementation RunKeeperPathPoint

@synthesize location, pointType, time, timeStamp;

- (id)initWithLocation:(CLLocation*)loc ofType:(RunKeeperPathPointType)t
{
    self = [super init];
    if (self) {
        self.location = loc;
        self.pointType = t;
        self.time = [NSDate date];
    }
    return self;
}

- (NSString*)typeStringForPointType
{
    // "start", "end", "gps", "pause", "resume", "manual"
    switch (pointType) {
        case kRKPausePoint: return @"pause";
        case kRKEndPoint: return @"end";
        case kRKStartPoint: return @"start";
        case kRKResumePoint: return @"resume";
        case kRKGPSPoint: return @"gps";
        case kRKManualPoint: return @"manual";
    }
    return nil;
}
- (id)proxyForJson {
    //NSLog(@"proxyForJSON: %g %g %g %g", self.timeStamp, self.location.altitude, self.location.coordinate.latitude,
    //      self.location.coordinate.longitude);
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:self.timeStamp], @"timestamp",
            [NSNumber numberWithDouble:self.location.altitude], @"altitude",
            [NSNumber numberWithDouble:self.location.coordinate.latitude], @"latitude",
            [NSNumber numberWithDouble:self.location.coordinate.longitude], @"longitude",
            [self typeStringForPointType], @"type",
            nil];
}

- (void)dealloc
{
    [super dealloc];
    [self.location release];
}

@end
