//
//  RunKeeperFitnessActivity.h
//  RunKeeper-iOS
//
//  Created by Falko Buttler on 5/2/13.
//  Copyright 2013 BlueBamboo.de Apps (www.bluebamboo.de). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunKeeper.h"

/** FitnessActivity as returned by different fitnessActivities API end points 
    Depending on the API call and expected content type, only basic data, advanced or all fields are filled. */
@interface RunKeeperFitnessActivity : NSObject

#/*********************************************************************************/
#pragma mark - Base information (included in feed)
/*********************************************************************************/

/** The type of activity, as one of the following values: Running, Cycling, Mountain Biking, Walking, Hiking,
    Downhill Skiing, Cross-Country Skiing, Snowboarding, Skating, Swimming, Wheelchair, Rowing, Elliptical, Other */
@property (nonatomic, assign) RunKeeperActivityType activityType;

// The starting time for the activity (e.g., Sat, 1 Jan 2011 00:00:00)
@property (nonatomic, strong) NSDate* startTime;

// The UTC offset of the timezone for the activity
@property (nonatomic, strong) NSNumber* utcOffset;

// The total distance for the activity, in meters
@property (nonatomic, strong) NSNumber* totalDistanceInMeters;

// The duration of the activity, in seconds
@property (nonatomic, strong) NSNumber* durationInSeconds;

// The name of the application that last modified this activity
@property (nonatomic, strong) NSString* source;

// The mode by which this activity was originally entered, as one of the following values: API, Web
@property (nonatomic, strong) NSString* entryMode;

// Whether a path exists for this activity
@property (nonatomic, assign) BOOL hasPath;

// The URI of the detailed information for the past activity
@property (nonatomic, strong) NSString* uri;

#/*********************************************************************************/
#pragma mark - Advanced information (included in summary)
/*********************************************************************************/

// The unique ID of the user for the activity
@property (nonatomic, strong) NSNumber* userID;

// The secondary type of the activity, as a free-form string (max. 64 characters).
// This field is used only if the type field is Other.
@property (nonatomic, strong) NSString* secondaryType;

// The equipment used to complete this activity, as one of the following values: None, Treadmill, Stationary Bike,
// Elliptical, Row Machine. (Optional; if not specified, None is assumed.)
@property (nonatomic, strong) NSString* equipment;

// The user’s average heart rate, in beats per minute (omitted if not available)
@property (nonatomic, strong) NSNumber* averageHeartRate;

// The total calories burned
@property (nonatomic, strong) NSNumber* totalCalories;

// The total elevation climbed over the course of the activity, in meters
@property (nonatomic, strong) NSNumber* climbInMeters;

// Any notes that the user has associated with the activity
@property (nonatomic, strong) NSString* notes;

// Whether this activity is currently being tracked via RunKeeper Live
@property (nonatomic, assign) BOOL isLive;

// The visibility of this activity to others, as one of the following values: "Just Me", "Street Team", "Everyone"
@property (nonatomic, strong) NSString* share;

// The visibility of this activity's routes to others, as one of the following values:
// "Just Me", "Street Team", "Everyone" (omitted if the activity has no routes)
@property (nonatomic, strong) NSString* shareMap;

// The URL of the user’s public, human-readable page for this activity
@property (nonatomic, strong) NSString* publicURI;

@end
