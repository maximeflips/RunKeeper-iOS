# RunKeeper-iOS

RunKeeper-iOS provides an Objective C wrapper class for accessing the [RunKeeper Health Graph API](http://developer.runkeeper.com/healthgraph) from iOS 4.0 or newer.

RunKeeper-iOS was developed for use in our iPhone fitness app "Running Intensity".  It is meant to be general, but is built primarily for a Running app.  The API is NOT fully supported, but more will be added based on our own needs or the requests of others.

## Dependencies

- [ASI HTTP Request](https://github.com/pokeb/asi-http-request) - Used for the underlying network access
- [SBJson](https://github.com/stig/json-framework.git) - Needed for parsing the response from bit.ly
- [OAuth2Client](https://github.com/nxtbgthng/OAuth2Client) - Used for OAuth2 access to RunKeeper API
- You will also need to register for a RunKeeper account, create an app, and get your tokens


## Example Usage

### Saving GPS Points

The RunKeeper will automatically create a correctly timestamped path for you if you post notifications.

  RunKeeperPathPoint *point = [[[RunKeeperPathPoint alloc] initWithLocation:newLocation ofType:kRKGPSPoint] autorelease];
  [[NSNotificationCenter defaultCenter] postNotificationName:kRunKeeperNewPointNotification object:point];
        
### Posting a Run
  [self.runKeeper postActivity:kRKRunning start:[NSDate date] 
                distance:[NSNumber numberWithFloat:10000]
                duration:[NSNumber numberWithFloat:[self.endTime timeIntervalSinceDate:self.startTime] + elapsedTime]
                calories:nil 
               heartRate:nil 
                   notes:@"What a great workout!" 
                    path:self.runKeeper.currentPath
                 success:^{
                     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Success" 
                                                                      message:@"Your activity was posted to your RunKeeper account."
                                                                     delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                     [alert show];
                     
                 }
                  failed:^(NSError *err){
                      NSString *msg = [NSString stringWithFormat:@"Upload to RunKeeper failed: %@", [err localizedDescription]]; 
                      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Failed" 
                                                                       message:msg
                                                                      delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                      [alert show];
                  }];



See more examples in the attached sample project.

## Getting Started

### Create a RunKeeper Instance with your Secret Keys

  self.runKeeper = [[[RunKeeper alloc] initWithClientID:kRunKeeperClientID clientSecret:kRunKeeperClientSecret] autorelease];
  
### Register a URL Scheme

Your URL Scheme is constructed by taking your RunKeeper ClientID and prepending "rk" --- an example is "rk055cac1c950b46e6ac7910d62800a854".  The URL scheme is registered in your app's Info.plist file in order to receive redirects from OAuth2.

### Handle the Redirect

In your application delegate:

  - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [self.runKeeper handleOpenURL:url];
    return TRUE;
  }
  
## More Info

Check out the sample app to see a very simple integration.

Feel free to add enhancements, bug fixes, changes and provide them back to the community!

Thanks,

Reid van Melle

