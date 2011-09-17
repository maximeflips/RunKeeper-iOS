# RunKeeper-iOS

RunKeeper-iOS provides an Objective C wrapper class for accessing the [RunKeeper Health Graph API](http://developer.runkeeper.com/healthgraph) from iOS 4.0 or newer.

RunKeeper-iOS was developed for use in our iPhone fitness app "Running Intensity".  It is meant to be general, but is built primarily for a Running app.

## Dependencies

- [ASI HTTP Request](https://github.com/pokeb/asi-http-request) - Used for the underlying network access
- [SBJson](https://github.com/stig/json-framework.git) - Needed for parsing the response from bit.ly
- [OAuth2Client](https://github.com/nxtbgthng/OAuth2Client) - Used for OAuth2 access to RunKeeper API
- You will also need to register for a RunKeeper account, create an app, and get your tokens


## Example Usage
###Posting a Run
	BRBitly *bitly = [[BRBitly alloc] initWithLogin:login apiKey:apiKey];
	[bitly shorten:@"http://www.infinite-loop.dk" result:^(NSString *shortURLString) {
		NSLog(@"The shortened URL: %@", shortURLString);
	} error:^(NSError *err) {
		NSLog(@"An error occurred %@", err);
	}];
	[bitly release];


See more examples in the attached sample project.

## Getting Started

Check out the sample app to see a very simple integration.

Feel free to add enhanchements, bug fixes, changes and provide them back to the community!


Thanks,

Reid van Melle

