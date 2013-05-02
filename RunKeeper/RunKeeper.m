//
//  RunKeeper.m
//  rrgps-iphone
//
//  Created by Reid van Melle on 11-09-14.
//  Copyright 2011 Brierwood Design Co-operative. All rights reserved.
//

#import "RunKeeper.h"
#import "RunKeeperPathPoint.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "NSDate+JSON.h"

#define kRunKeeperAuthorizationURL @"https://runkeeper.com/apps/authorize"
#define kRunKeeperAccessTokenURL @"https://runkeeper.com/apps/token"

#define kRunKeeperBasePath @"https://api.runkeeper.com"
#define kRunKeeperBaseURL @"/user/"

#define kNotConnectedErrorCode 100

#define kRKBackgroundActivitiesKey        @"background_activities"
#define kRKDiabetesKey                    @"diabetes"
#define kRKFitnessActivitiesKey           @"fitness_activities"
#define kRKGeneralMeasurementsKey         @"general_measurements"
#define kRKNutritionKey                   @"nutrition"
#define kRKProfileKey                     @"profile"
#define kRKRecordsKey                     @"records"
#define kRKSettingsKey                    @"settings"
#define kRKSleepKey                       @"sleep"
#define kRKStrengthTrainingActivitiesKey  @"strength_training_activities"
#define kRKTeamKey                        @"team"
#define kRKUserIDKey                      @"userID"
#define kRKWeightKey                      @"weight"

NSString *const kRunKeeperErrorDomain = @"RunKeeperErrorDomain";
NSString *const kRunKeeperStatusTextKey = @"RunKeeperStatusText";
NSString *const kRunKeeperNewPointNotification = @"RunKeeperNewPointNotification";


@interface RunKeeper()

- (NSString*)localizedStatusText:(NSString*)bitlyStatusTxt;
- (NSError*)errorWithCode:(NSInteger)code status:(NSString*)status;
- (void)newPathPoint:(NSNotification*)note;

@property (nonatomic, strong) NSDictionary *paths;
@property (nonatomic, strong) NSNumber *userID;

// OAuth stuff
@property (nonatomic, strong) NSString *clientID, *clientSecret;
@property (nonatomic, strong, readonly) NXOAuth2Client *oauthClient;
@property (nonatomic, strong) AFHTTPClient *httpClient;

@end


@implementation RunKeeper

@synthesize oauthClient, connected, paths, userID;
@synthesize clientID, clientSecret;
@synthesize currentPath, startPointTimestamp;

- (id)initWithClientID:(NSString*)_clientID clientSecret:(NSString*)secret
{
    self = [super init];
    if (self) {
        self.clientID = _clientID;
        self.clientSecret = secret;
        
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kRunKeeperBasePath]];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        connected = self.oauthClient.accessToken != nil;
        self.currentPath = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPathPoint:)
                                                     name:kRunKeeperNewPointNotification object:nil];
    }
    return self;
}

- (void)newPathPoint:(NSNotification*)note
{
    RunKeeperPathPoint *pt = [note object];
    if (pt.pointType == kRKStartPoint) {
        self.startPointTimestamp = pt.time;
    }
    // If we have not received a start point, then just ignore any of the points
    if (self.startPointTimestamp == nil) return;
    pt.timeStamp = [pt.time timeIntervalSinceDate:self.startPointTimestamp];
    
    [self.currentPath addObject:pt];
}

- (void)tryToConnect:(id <RunKeeperConnectionDelegate>)_delegate;
{
    delegate = _delegate;
    [self.oauthClient requestAccess];
}

- (void)disconnect
{
    self.oauthClient.accessToken = nil;
    connected = NO;
}

- (void)tryToAuthorize
{
    NSString *oauth_path = [NSString stringWithFormat:@"rk%@://oauth2", self.clientID];
    NSURL *authorizationURL = [self.oauthClient authorizationURLWithRedirectURL:[NSURL URLWithString:oauth_path]];
    [[UIApplication sharedApplication] openURL:authorizationURL];
}


- (void)handleOpenURL:(NSURL *)url
{
    [self.oauthClient openRedirectURL:url];
}

- (NSString*)localizedStatusText:(NSString*)bitlyStatusTxt {
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *status = [bundle localizedStringForKey:bitlyStatusTxt value:bitlyStatusTxt table:@"RunKeeperErrors"];
    
	return status;
}

- (NSError*)errorWithCode:(NSInteger)code status:(NSString*)status {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	[userDict setObject:status forKey:kRunKeeperStatusTextKey];
	status = [self localizedStatusText:status];
	if(status)
		[userDict setObject:status forKey:NSLocalizedDescriptionKey];
	NSError *bitlyError = [NSError errorWithDomain:kRunKeeperErrorDomain code:code userInfo:userDict];
    
	return bitlyError;
}

- (void)getBasePaths
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/vnd.com.runkeeper.user+json"]];
    NSURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:kRunKeeperBaseURL parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.paths = JSON;
        self.userID = [self.paths objectForKey:@"kRKUserIDKey"];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        self.paths = nil;
        self.userID = nil;
        connected = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RunKeeper Error"
                                                        message:@"Error while communicating with RunKeeper."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark RunKeeperAPI Calls

- (NSString*)activityString:(RunKeeperActivityType)activity
{
    switch (activity) {
        case kRKRunning:        return @"Running";
        case kRKCycling:        return @"Cycling";
        case kRKMountainBiking: return @"Mountain Biking";
        case kRKWalking:        return @"Walking";
        case kRKHiking:         return @"Hiking";
        case kRKDownhillSkiing: return @"Downhill Skiing";
        case kRKXCountrySkiing: return @"Cross Country Skiing";
        case kRKSnowboarding:   return @"Snowboarding";
        case kRKSkating:        return @"Skating";
        case kRKSwimming:       return @"Swimming";
        case kRKWheelchair:     return @"Wheelchair";
        case kRKRowing:         return @"Rowing";
        case kRKElliptical:     return @"Elliptical";
        case kRKOther:          return @"Other";
    }
    return @"Running";
}

- (void)postActivity:(RunKeeperActivityType)activity start:(NSDate*)start distance:(NSNumber*)distance
            duration:(NSNumber*)duration calories:(NSNumber*)calories avgHeartRate:(NSNumber*)avgHeartRate
               notes:(NSString*)notes path:(NSArray*)path  heartRatePoints:(NSArray*)heartRatePoints
             success:(RIBasicCompletionBlock)success failed:(RIBasicFailedBlock)failed
{
    if (!connected) {
        NSError *err = [self errorWithCode:kNotConnectedErrorCode status:@"You are not connected to RunKeeper"];
        if (failed) failed(err);
        return;
    }
    
    NSMutableDictionary *activityDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [self activityString:activity], @"type",
                                               [start proxyForJson], @"start_time",
                                               distance, @"total_distance",
                                               duration, @"duration",
                                               nil];
    
    if (avgHeartRate != nil){
        [activityDictionary setValue:avgHeartRate forKey:@"average_heart_rate"];
    }
    
    if (calories != nil){
        [activityDictionary setValue:calories forKey:@"total_calories"];
    }
    
    if (notes != nil){
        [activityDictionary setValue:notes forKey:@"notes"];
    }
    
    if (path != nil){
        [activityDictionary setValue:[path valueForKeyPath:@"proxyForJson"] forKey:@"path"];
    }
    
    if (heartRatePoints != nil){
        [activityDictionary setValue:[heartRatePoints valueForKeyPath:@"proxyForJson"] forKey:@"heart_rate"];
    }
    
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST" path:[self.paths objectForKey:kRKFitnessActivitiesKey] parameters:activityDictionary];
    [request setValue:@"application/vnd.com.runkeeper.NewFitnessActivity+json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success) {
            success();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ( failed ) {
            failed(error);
        }
    }];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark NXOAuth2ClientDelegate

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"didGetAccessToken");
    [self.httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    connected = YES;
    [self getBasePaths];
    if (delegate && [delegate respondsToSelector:@selector(connected)]) {
        [delegate connected];
    }
    
}
- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"didLoseAccessToken");
    connected = NO;
    if (delegate && [delegate respondsToSelector:@selector(connectionFailed:)]) {
        [delegate connectionFailed:nil];
    }
}
- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error
{
    NSLog(@"didFailToGetAccessToken");
    connected = NO;
    if (delegate && [delegate respondsToSelector:@selector(connectionFailed:)]) {
        [delegate connectionFailed:nil];
    }
}

- (void)oauthClientNeedsAuthentication:(NXOAuth2Client *)client
{
    if (delegate && [delegate respondsToSelector:@selector(needsAuthentication)]) {
        [delegate needsAuthentication];
    }
}

- (NXOAuth2Client*)oauthClient {
    if (oauthClient != nil) {
        return oauthClient;
    }
    
    assert(clientID);
    assert(clientSecret);
    oauthClient = [[NXOAuth2Client alloc] initWithClientID:clientID
                                              clientSecret:clientSecret
                                              authorizeURL:[NSURL URLWithString:kRunKeeperAuthorizationURL]
                                                  tokenURL:[NSURL URLWithString:kRunKeeperAccessTokenURL]
                                                  delegate:self];
    NSLog(@"requestAccess: %@", oauthClient.accessToken.accessToken);
    [self.httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    return oauthClient;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
