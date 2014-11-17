//
//  RunKeeperProfile.h
//  RunKeeper-iOS
//
//  Created by Falko Buttler on 5/4/13.
//  Copyright 2013 BlueBamboo.de Apps (www.bluebamboo.de). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunKeeperProfile : NSObject

/** The user's full name (omitted if not yet specified) */
@property (nonatomic, strong) NSString* name;

/** The user's geographical location (omitted if not yet specified) */
@property (nonatomic, strong) NSString* location;

/** One of the following values: Athlete, Runner, Marathoner, Ultra Marathoner, Cyclist, Tri-Athlete, Walker, Hiker, 
 Skier, Snowboarder, Skater, Swimmer, Rower (omitted if not yet specified) */
@property (nonatomic, strong) NSString* athleteType;

/** One of the following values: M, F (omitted if not yet specified) */
@property (nonatomic, strong) NSString* gender;

/** The user's birthday (e.g., Sat, 1 Jan 2011 00:00:00) (omitted if not yet specified) */
@property (nonatomic, strong) NSString* birthday;

/** True if the user subscribes to RunKeeper Elite, false otherwise */
@property (nonatomic, assign) BOOL elite;

/** The URL of the user's public, human-readable profile on the RunKeeper Web site */
@property (nonatomic, strong) NSString* profile;

/** The URI of the small (50×50 pixels) version of the user's profile picture on the RunKeeper Web site 
 (omitted if the user has no such picture) */
@property (nonatomic, strong) NSString* smallPicture;

/** The URI of the small (100×100 pixels) version of the user's profile picture on the RunKeeper Web site 
 (omitted if the user has no such picture) */
@property (nonatomic, strong) NSString* normalPicture;

/** The URI of the small (200×600 pixels) version of the user's profile picture on the RunKeeper Web site 
 (omitted if the user has no such picture) Note: The image may be shorter than 600 pixels in height if the user has 
 provided a smaller picture. */
@property (nonatomic, strong) NSString* mediumPicture;

/** The URI of the small (600×1800 pixels) version of the user's profile picture on the RunKeeper Web site 
 (omitted if the user has no such picture) Note: The image may be shorter than 1800 pixels in height if the user has 
 provided a smaller picture. */
@property (nonatomic, strong) NSString* largePicture;

@end
