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
typedef void(^RIBasicFailedBlock)(NSError *err);

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

// 


@protocol RunKeeperConnectionDelegate <NSObject>

@optional
// Connected is called when an existing auth token is found
- (void)connected;

// Called when the request to connect to runkeeper failed
- (void)connectionFailed:(NSError*)err;

// Called when authentication is needed to connect to RunKeeper --- normally, the client app will call
// tryToAuthorize at this point
- (void)needsAuthentication;
@end

extern NSString *const kRunKeeperNewPointNotification;

@interface RunKeeper : NSObject <NXOAuth2ClientDelegate> {
    
@private
    id <RunKeeperConnectionDelegate> delegate;
}

// The timestamp for the starting point --- used to calculate relative times
@property (nonatomic, retain) NSDate *startPointTimestamp;


/** TRUE if RunKeeper API thinks we have a valid connection -- NOTE, we could be wrong.  The API
 will check for an authorization token at startup and assume it is valid if found.  Otherwise, the connected
 status will get updated during actual oauth connections or manual disconnects.
*/
@property (nonatomic, readonly) BOOL connected;


/** The currentPath of GPS points which the RunKeeper API has recorded via notifications (if you 
 decide to use this feature).  You can safely pass this into the postActivity call.
 */
@property (nonatomic, retain) NSMutableArray *currentPath;

/** Create a new client with your shiny credentials and secretz pleeze
 */
- (id)initWithClientID:(NSString*)clientID clientSecret:(NSString*)secret;

/** Callback from RunKeeper oauth */
- (void)handleOpenURL:(NSURL *)url;

/** Try to connect to the RunKeeper API via auth. The delegate will receive callbacks about the status
 and state of things.  NOTE: this will not actually trigger the authorization flow --- just checks for 
 existing authorization. */
- (void)tryToConnect:(id <RunKeeperConnectionDelegate>)delegate;

/** This actually initiates the authorization process --- it is not trigger authomatically since it
 may not be appropriate for your application. */
- (void)tryToAuthorize;

/** Disconnect from the RunKeeper API --- all this does is *forget* the authorization token; there
 are not actual network calls being made */
- (void)disconnect;

- (void)postActivity:(RunKeeperActivityType)activity start:(NSDate*)start distance:(NSNumber*)distance
                 duration:(NSNumber*)duration calories:(NSNumber*)calories avgHeartRate:(NSNumber*)avgHeartRate
               notes:(NSString*)notes path:(NSArray*)path heartRatePoints:(NSArray*)heartRatePoints
             success:(RIBasicCompletionBlock)success failed:(RIBasicFailedBlock)failed;


@end


// Nothing to see here
extern NSString *const kRunKeeperErrorDomain;
extern NSString *const kRunKeeperStatusTextKey;
