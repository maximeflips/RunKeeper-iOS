//
//  RunKeeper.h
//  rrgps-iphone
//
//  Created by Reid van Melle on 11-09-14.
//  Copyright 2011 Brierwood Design Co-operative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

typedef void(^RIBasicCompletionBlock)(void);
typedef void(^RIJSONCompletionBlock)(id json);
typedef void(^RINSStringCompletionBlock)(NSString *msg);
typedef void(^RIBasicFailedBlock)(void);
typedef void(^RIErrorDictFailedBlock)(NSDictionary *errors);

typedef enum {
    kRKRunning,
    kRKCycling,
    kRKMountainBiking,
    kRKWalking,
    kRKHiking,
    kRKDownhillSkiing,
    kRKXCountrySkiing,
    kRKSnowboarding,
    kRKSkating,
    kRKSwimming,
    kRKWheelchair,
    kRKRowing,
    kRKElliptical,
    kRKOther
} RunKeeperActivityType;

@interface RunKeeper : NSObject <NXOAuth2ClientDelegate> {
    NXOAuth2Client *oauthClient; 
    BOOL connected;
    NSDictionary *paths;
    NSNumber *userID;
}

@property (nonatomic, retain, readonly) NXOAuth2Client *oauthClient;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, retain) NSDictionary *paths;
@property (nonatomic, retain) NSNumber *userID;

+ (RunKeeper *)sharedRunKeeper;

- (void)handleOpenURL:(NSURL *)url;
- (void)connect;
- (void)postActivity:(RunKeeperActivityType)activity start:(NSDate*)start distance:(NSNumber*)distance
                 duration:(NSNumber*)duration calories:(NSNumber*)calories heartRate:(NSNumber*)heartRate
                    notes:(NSString*)notes path:(NSArray*)path
             success:(RIBasicCompletionBlock)success failed:(RIBasicFailedBlock)failed;


@end
