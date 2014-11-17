//
//  RunKeeper.m
//  RunKeeper-iOS
//
//  Created by Reid van Melle on 11-09-14.
//  Copyright 2011 Brierwood Design Co-operative. All rights reserved.
//

#import "AFNetworking.h"
#import "NSDate+JSON.h"
#import "RunKeeper.h"
#import "RunKeeperPathPoint.h"
#import "RunKeeperFitnessActivity.h"
#import "RunKeeperProfile.h"

#define kRunKeeperAuthorizationURL @"https://runkeeper.com/apps/authorize"
#define kRunKeeperAccessTokenURL @"https://runkeeper.com/apps/token"

#define kRunKeeperBasePath @"https://api.runkeeper.com"
#define kRunKeeperBaseURL @"/user/"

#define kNotConnectedErrorCode         100
#define kPaginatorStillActiveErrorCode 101

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
{
    BOOL _isLoading;
    NSUInteger _pageSize;
    NSUInteger _currentPage;
    NSUInteger _totalPages;
    NSMutableArray* _allItems;
}

- (NSString*)localizedStatusText:(NSString*)bitlyStatusTxt;
- (NSError*)errorWithCode:(NSInteger)code status:(NSString*)status;
- (void)newPathPoint:(NSNotification*)note;

@property (nonatomic, strong) NSDictionary *paths;
@property (nonatomic, strong) NSNumber *userID;

// OAuth stuff
@property (nonatomic, strong) NSString *clientID, *clientSecret;
@property (nonatomic, strong, readonly) NXOAuth2Client *oauthClient;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;

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
        
//        AFNetworkActivityIndicatorManager* man = [AFNetworkActivityIndicatorManager sharedManager];
//        man.enabled = YES;
        
        self.httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kRunKeeperBasePath]];
        [self.httpClient setRequestSerializer:[AFJSONRequestSerializer serializer]];
        self.httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
        self.httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/vnd.com.runkeeper.user+json",
                                                           @"application/vnd.com.runkeeper.fitnessactivityfeed+json",
                                                           @"application/vnd.com.runkeeper.fitnessactivitysummary+json",
                                                           @"application/vnd.com.runkeeper.fitnessactivity+json",
                                                           @"application/vnd.com.runkeeper.profile+json",
                                                           @"text/plain",
                                                           nil];

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
//    NSURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:kRunKeeperBaseURL parameters:nil];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    NSLog(@"Http client headers: %@", self.httpClient.requestSerializer.HTTPRequestHeaders);
    NSLog(@"response object for base paths: %@", kRunKeeperBaseURL);
    [self.httpClient GET:kRunKeeperBaseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object for base paths: %@", responseObject);
        self.paths = responseObject;
        self.userID = [self.paths objectForKey:kRKUserIDKey];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        self.paths = nil;
        self.userID = nil;
        connected = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RunKeeper Error"
                                                        message:@"Error while communicating with RunKeeper."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
//    [self.httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark RunKeeperAPI Calls

- (void)getProfileOnSuccess:(void (^)(RunKeeperProfile *profile))success
                     failed:(RIBasicFailedBlock)failed
{
    if (!connected) {
        NSError *err = [self errorWithCode:kNotConnectedErrorCode status:@"You are not connected to RunKeeper"];
        if (failed) failed(err);
        return;
    }

    [self.httpClient GET:[self.paths objectForKey:kRKProfileKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RunKeeperProfile* profile = [[RunKeeperProfile alloc] init];
        profile.name = [responseObject objectForKey:@"name"];
        profile.location = [responseObject objectForKey:@"location"];
        profile.athleteType = [responseObject objectForKey:@"athlete_type"];
        profile.gender = [responseObject objectForKey:@"gender"];
        profile.birthday = [responseObject objectForKey:@"birthday"];
        profile.elite = [[responseObject objectForKey:@"elite"] boolValue];
        profile.profile = [responseObject objectForKey:@"profile"];
        profile.smallPicture = [responseObject objectForKey:@"small_picture"];
        profile.normalPicture = [responseObject objectForKey:@"normal_picture"];
        profile.mediumPicture = [responseObject objectForKey:@"medium_picture"];
        profile.largePicture = [responseObject objectForKey:@"large_picture"];

        if ( success ) {
            success(profile);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ( failed ) {
            failed(error);
        }
    }];
//    [self.httpClient enqueueHTTPRequestOperation:operation];
}

+ (NSString*)activityString:(RunKeeperActivityType)activity
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

+ (RunKeeperActivityType)activityType:(NSString*)type
{
    if ( [type isEqualToString:@"Running"] ) {
        return kRKRunning;
    }
    else if ( [type isEqualToString:@"Cycling"] ) {
        return kRKCycling;
    }
    else if ( [type isEqualToString:@"Mountain Biking"] ) {
        return kRKMountainBiking;
    }
    else if ( [type isEqualToString:@"Walking"] ) {
        return kRKWalking;
    }
    else if ( [type isEqualToString:@"Hiking"] ) {
        return kRKHiking;
    }
    else if ( [type isEqualToString:@"Downhill Skiing"] ) {
        return kRKDownhillSkiing;
    }
    else if ( [type isEqualToString:@"Cross Country Skiing"] ) {
        return kRKXCountrySkiing;
    }
    else if ( [type isEqualToString:@"Snowboarding"] ) {
        return kRKSnowboarding;
    }
    else if ( [type isEqualToString:@"Skating"] ) {
        return kRKSkating;
    }
    else if ( [type isEqualToString:@"Swimming"] ) {
        return kRKSwimming;
    }
    else if ( [type isEqualToString:@"Wheelchair"] ) {
        return kRKWheelchair;
    }
    else if ( [type isEqualToString:@"Rowing"] ) {
        return kRKRowing;
    }
    else if ( [type isEqualToString:@"Elliptical"] ) {
        return kRKElliptical;
    }
    return kRKOther;
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
                                               [RunKeeper activityString:activity], @"type",
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
    
//    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST"
//                                                                 path:[self.paths objectForKey:kRKFitnessActivitiesKey]
//                                                           parameters:activityDictionary];
//    [request setValue:@"application/vnd.com.runkeeper.NewFitnessActivity+json" forHTTPHeaderField:@"Content-Type"];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    [self.httpClient POST:[self.paths objectForKey:kRKFitnessActivitiesKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ( failed ) {
            failed(error);
        }
    }];
//    [self.httpClient enqueueHTTPRequestOperation:operation];
}

#define SecondsPerDay (24 * 60 * 60)

- (void)getFitnessActivityFeedNoEarlierThan:(NSDate*)noEarlierThan
                                noLaterThan:(NSDate*)noLaterThan
                      modifiedNoEarlierThan:(NSDate*)modifiedNoEarlierThan
                        modifiedNoLaterThan:(NSDate*)modifiedNoLaterThan
                                   progress:(RIPaginatorCompletionBlock)progress
                                    success:(RIPaginatorCompletionBlock)success
                                     failed:(RIBasicFailedBlock)failed
{
    if (!connected) {
        NSError *err = [self errorWithCode:kNotConnectedErrorCode status:@"You are not connected to RunKeeper"];
        if (failed) failed(err);
        return;
    }

    if ( _isLoading ) {
        NSError *err = [self errorWithCode:kPaginatorStillActiveErrorCode status:@"The paginator is still active"];
        if (failed) failed(err);
        return;
    }
    
    _isLoading = YES;
    _pageSize = 25;
    _currentPage = 0;
    _totalPages = 1;
    _allItems = [NSMutableArray array];
        
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    if ( !noEarlierThan ) {
        noEarlierThan = [NSDate dateWithTimeIntervalSince1970:0];
    }
    if ( !modifiedNoEarlierThan ) {
        modifiedNoEarlierThan = [NSDate dateWithTimeIntervalSince1970:0];
    }
    if ( !noLaterThan ) {
        noLaterThan = [NSDate dateWithTimeIntervalSinceNow:SecondsPerDay * 2]; // this is what RunKeeper does by default
    }
    if ( !modifiedNoLaterThan ) {
        modifiedNoLaterThan = [NSDate dateWithTimeIntervalSinceNow:SecondsPerDay * 2]; // this is what RunKeeper does by default
    }
    
    NSDictionary* dict = @{@"pageSize" : @(_pageSize),
                           @"noEarlierThan" : [dateFormatter stringFromDate:noEarlierThan],
                           @"noLaterThan" : [dateFormatter stringFromDate:noLaterThan],
                           @"modifiedNoEarlierThan" : [dateFormatter stringFromDate:modifiedNoEarlierThan],
                           @"modifiedNoLaterThan" : [dateFormatter stringFromDate:modifiedNoLaterThan]};
    [self loadNextPage:[self.paths objectForKey:kRKFitnessActivitiesKey] parameters:dict progress:progress success:success failed:failed];
}

- (void)fillFitnessActivity:(RunKeeperFitnessActivity*)item fromFeedDict:(NSDictionary*)itemDict
{
    item.activityType = [RunKeeper activityType:[itemDict objectForKey:@"type"]];
    item.startTime = [NSDate dateFromJSONDate:[itemDict objectForKey:@"start_time"]];
    item.totalDistanceInMeters = [itemDict objectForKey:@"total_distance"];
    item.durationInSeconds = [itemDict objectForKey:@"duration"];
    item.source = [itemDict objectForKey:@"source"];
    item.entryMode = [itemDict objectForKey:@"entry_mode"];
    item.hasPath = [[itemDict objectForKey:@"has_path"] boolValue];
    item.uri = [itemDict objectForKey:@"uri"];
}

- (void)fillFitnessActivity:(RunKeeperFitnessActivity*)item fromSummaryDict:(NSDictionary*)itemDict
{
    [self fillFitnessActivity:item fromFeedDict:itemDict];
    item.userID = [itemDict objectForKey:@"userID"];
    item.secondaryType = [itemDict objectForKey:@"secondary_type"];
    item.equipment = [itemDict objectForKey:@"equipment"];
    item.averageHeartRate = [itemDict objectForKey:@"average_heart_rate"];
    item.totalCalories = [itemDict objectForKey:@"total_calories"];
    item.climbInMeters = [itemDict objectForKey:@"climb"];
    item.notes = [itemDict objectForKey:@"notes"];
    item.isLive = [[itemDict objectForKey:@"is_live"] boolValue];
    item.share = [itemDict objectForKey:@"share"];
    item.shareMap = [itemDict objectForKey:@"share_map"];
    item.publicURI = [itemDict objectForKey:@"activity"];
}

- (void)loadNextPage:(NSString*)uri
          parameters:(NSDictionary*)dict
            progress:(RIPaginatorCompletionBlock)progress
             success:(RIPaginatorCompletionBlock)success
              failed:(RIBasicFailedBlock)failed
{
//    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET"
//                                                                 path:uri
//                                                           parameters:dict];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    NSLog(@"Http client headers: %@", self.httpClient.requestSerializer.HTTPRequestHeaders);
    NSLog(@"Base url: %@", self.httpClient.baseURL);
    NSLog(@"Getting next page: %@", uri);
    [self.httpClient GET:uri parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Next page response: %@", responseObject);
        NSArray* itemDicts = [responseObject objectForKey:@"items"];
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:itemDicts.count];
        for( NSDictionary* itemDict in itemDicts ) {
            RunKeeperFitnessActivity* item = [[RunKeeperFitnessActivity alloc] init];
            [self fillFitnessActivity:item fromFeedDict:itemDict];
            [items addObject:item];
        }
        [_allItems addObjectsFromArray:items];
        
        if ( _currentPage == 0 ) {
            _totalPages = roundf(([[responseObject objectForKey:@"size"] floatValue] / (float)_pageSize) + 0.5);
        }
        
        if ( _totalPages == 1 || _currentPage == _totalPages-1 ) { // We reached the last page
            _isLoading = NO;
            if ( progress ) {
                progress(items, _currentPage, _totalPages);
            }
            if ( success ) {
                success(_allItems, _currentPage, _totalPages);
            }
            _allItems = nil;
        }
        else { // Load next page recursively
            NSString* nextPageURI = [responseObject objectForKey:@"next"];
            [self loadNextPage:nextPageURI parameters:nil progress:progress success:success failed:failed];
            
            if ( progress ) {
                progress(items, _currentPage, _totalPages);
            }
            _currentPage++;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error log: %@", error);
        _isLoading = NO;
        _allItems = nil;
        if ( failed ) {
            failed(error);
        }
    }];
    
}

- (void)getFitnessActivitySummary:(NSString*)uri
                          success:(RIFitnessActivityCompletionBlock)success
                           failed:(RIBasicFailedBlock)failed
{
//    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:uri parameters:nil];
//    [request setValue:@"application/vnd.com.runkeeper.FitnessActivitySummary+json" forHTTPHeaderField:@"Accept"];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//                                         {
    [self.httpClient GET:uri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RunKeeperFitnessActivity* item = [[RunKeeperFitnessActivity alloc] init];
        [self fillFitnessActivity:item fromSummaryDict:responseObject];
        if ( success ) {
            success(item);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ( failed ) {
            failed(error);
        }
    }];
}

#pragma mark NXOAuth2ClientDelegate

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"didGetAccessToken");
    NSLog(@"Access token: %@", oauthClient.accessToken.accessToken);
    [self.httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken] forHTTPHeaderField:@"Authorization"];
//    [self.httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
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
    
    NSLog(@"Setting value for header");
    assert(clientID);
    assert(clientSecret);
    oauthClient = [[NXOAuth2Client alloc] initWithClientID:clientID
                                              clientSecret:clientSecret
                                              authorizeURL:[NSURL URLWithString:kRunKeeperAuthorizationURL]
                                                  tokenURL:[NSURL URLWithString:kRunKeeperAccessTokenURL]
                                                  delegate:self];
//    [self.httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    [self.httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken] forHTTPHeaderField:@"Authorization"];
    return oauthClient;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
