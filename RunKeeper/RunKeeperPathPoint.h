//
//  RunKeeperPathPoint.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kRKStartPoint,
    kRKEndPoint,
    kRKPausePoint,
    kRKResumePoint,
    kRKGPSPoint,
    kRKManualPoint
} RunKeeperPathPointType;

@interface RunKeeperPathPoint : NSObject {
}
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, assign) NSTimeInterval timeStamp;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) RunKeeperPathPointType pointType;

- (id)initWithLocation:(CLLocation*)loc ofType:(RunKeeperPathPointType)t;
- (id)proxyForJson;
@end

