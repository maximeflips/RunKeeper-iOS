//
//  RunKeeperFitnessActivityItem.h
//  RunKeeper-iOS
//
//  Created by Falko Buttler (www.bluebamboo.de) on 5/2/13.
//

#import <Foundation/Foundation.h>
#import "RunKeeper.h"

/** Item as returned by fitnessActivities API end point with content type application/vnd.com.runkeeper.FitnessActivityFeed+json */
@interface RunKeeperFitnessActivityItem : NSObject

/** The type of activity, as one of the following values: Running, Cycling, Mountain Biking, Walking, Hiking,
    Downhill Skiing, Cross-Country Skiing, Snowboarding, Skating, Swimming, Wheelchair, Rowing, Elliptical, Other */
@property (nonatomic, assign) RunKeeperActivityType activityType;

// The starting time for the activity (e.g., Sat, 1 Jan 2011 00:00:00)
@property (nonatomic, strong) NSDate* startTime;

// The total distance for the activity, in meters
@property (nonatomic, assign) double totalDistanceInMeters;

// The duration of the activity, in seconds
@property (nonatomic, assign) double durationInSeconds;

// The name of the application that last modified this activity
@property (nonatomic, strong) NSString* source;

// The mode by which this activity was originally entered, as one of the following values: API, Web
@property (nonatomic, strong) NSString* entryMode;

// Whether a path exists for this activity
@property (nonatomic, assign) BOOL hasPath;

// The URI of the detailed information for the past activity
@property (nonatomic, strong) NSString* uri;

@end
