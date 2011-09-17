//
//  RunKeeper.m
//  rrgps-iphone
//
//  Created by Reid van Melle on 11-09-14.
//  Copyright 2011 Brierwood Design Co-operative. All rights reserved.
//

#import "RunKeeper.h"
#import "SynthesizeSingleton.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "NSObject+SBJson.h"


#define kRunKeeperAuthorizationURL @"https://runkeeper.com/apps/authorize"
#define kRunKeeperAccessTokenURL @"https://runkeeper.com/apps/token"

#define kRunKeeperBasePath @"https://api.runkeeper.com"
#define kRunKeeperBaseURL @"/user/"

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

NSString *const kBRBitlyErrorDomain = @"RunKeeperErrorDomain";
NSString *const kBRBitlyStatusTextKey = @"RunKeeperStatusText";

@interface RunKeeper()

- (NSString*)localizedStatusText:(NSString*)bitlyStatusTxt;
- (NSError*)errorWithCode:(NSInteger)code status:(NSString*)status;

@end


@implementation RunKeeper

@synthesize oauthClient, connected, paths, userID;
@synthesize clientID, clientSecret;

SYNTHESIZE_SINGLETON_FOR_CLASS(RunKeeper);

- (void)setClientID:(NSString*)_clientID clientSecret:(NSString*)secret
{
    self.clientID = _clientID;
    self.clientSecret = secret;
}

- (void)tryToConnect:(id <RunKeeperConnectionDelegate>)_delegate;
{
    delegate = _delegate;
    [self.oauthClient requestAccess];
}

- (void)tryToAuthorize
{
    NSString *oauth_path = [NSString stringWithFormat:@"rk%@", self.clientID];
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
	[userDict setObject:status forKey:kBRBitlyStatusTextKey];
	status = [self localizedStatusText:status];
	if(status)
		[userDict setObject:status forKey:NSLocalizedDescriptionKey];
	NSError *bitlyError = [NSError errorWithDomain:kBRBitlyErrorDomain code:code userInfo:userDict];
    
	return bitlyError;
}


- (ASIHTTPRequest*)createStandardRequest:(NSURL*)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    request.delegate = self;
    return request;    
}

- (ASIHTTPRequest*)createRequest:(NSString*)path {
    NSString *str = [NSString stringWithFormat:@"%@%@", kRunKeeperBasePath, path];
    NSLog(@"request URL: %@", str);
    NSURL *url = [NSURL URLWithString:str];
    return [self createStandardRequest:url];
}

- (ASIFormDataRequest*)createPostRequest:(NSString*)path content:(NSString*)content {
    NSString *str = [NSString stringWithFormat:@"%@%@", kRunKeeperBasePath, path];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/vnd.com.runkeeper.NewFitnessActivity+json"];
    request.delegate = self;
    //[request setPostBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [request appendPostData:data]; 
    //[request setContentLength:[data length]];
    return request; 
}


- (ASIHTTPRequest*)request:(NSString*)path onCompletion:(RIJSONCompletionBlock)completion onFailed:(RIBasicFailedBlock)failed {
    __block ASIHTTPRequest *request = [self createRequest:path];    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        if ([request responseStatusCode] == 200) {
            if (completion) {
                completion([[request responseString] JSONValue]);
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"*** request failed reason: %@", [request error]);
        if (failed) failed();
    }];
    [request startAsynchronous];
    return request;
}

- (ASIHTTPRequest*)postRequest:(NSString*)path content:(NSString*)content onCompletion:(RIJSONCompletionBlock)completion onFailed:(RIBasicFailedBlock)failed {
    __block ASIFormDataRequest *request = [self createPostRequest:path content:content];    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        if ([request responseStatusCode] == 201) { // CREATED
            if (completion) {
                NSLog(@"Done: %@", [request responseString]);
                completion(nil);
                //completion([[request responseString] JSONValue]);
            }
        } else {
            NSLog(@"postFailed: %d %@", [request responseStatusCode], [request responseString]);
            if (failed) failed();
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"*** request failed reason: %@", [request error]);
        if (failed) failed();
    }];
    [request startAsynchronous];
    return request;
}


- (void)getBasePaths
{
    [self request:kRunKeeperBaseURL onCompletion:^(id json) {
        self.paths = json;
        self.userID = [self.paths objectForKey:@"kRKUserIDKey"];
    } onFailed:^{
        self.paths = nil;
        self.userID = nil;
        connected = NO;
        NSLog(@"fail: ");
    }];
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
                 duration:(NSNumber*)duration calories:(NSNumber*)calories heartRate:(NSNumber*)heartRate
                    notes:(NSString*)notes path:(NSArray*)path
             success:(RIBasicCompletionBlock)success failed:(RIBasicFailedBlock)failed
{
    /*
    {
        "type": "Running",
        "start_time": "Sat, 1 Jan 2011 00:00:00",
        "notes": "My first late-night run", "path": [{"timestamp":0,
            "altitude":0,
            "longitude":-70.95182336425782,
            "latitude":42.312620297384676,
            "type":"start"},
        {"timestamp":8,
            "altitude":0,
            "longitude":-70.95255292510987,
            "latitude":42.31230294498018,
            "type":"end"}]
        "post_to_facebook": true,
        "post_to_twitter": true
    }*/
    /**
     [[RunKeeper sharedRunKeeper] postActivity:kRKRunning start:[NSDate date] 
     distance:[NSNumber numberWithFloat:10000]
     duration:[NSNumber numberWithInt:3600]
     calories:nil heartRate:nil notes:@"Good to go" path:nil];
     */
    if (!connected) {
        if (failed) failed();
        return;
    }
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self activityString:activity], @"type",
                          start, @"start_time",
                          distance, @"total_distance",
                          duration, @"duration",
                          notes, @"notes",
                          path, @"path",
                          nil];
    NSString *content = [args JSONRepresentation];
    NSLog(@"content: %@", content);
    [self postRequest:[self.paths objectForKey:kRKFitnessActivitiesKey] content:content  onCompletion:^(id json) {
        if (success) success();
    }onFailed:^{
        NSLog(@"fail: ");
        if (failed) failed();
    }];
}

#pragma mark NXOAuth2ClientDelegate

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"didGetAccessToken");
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
    //NSLog(@"requestAccess: %@", oauthClient.accessToken.accessToken);
    return oauthClient;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {	
    [oauthClient release];
    [paths release];
    [userID release];
	[super dealloc];
}



@end
