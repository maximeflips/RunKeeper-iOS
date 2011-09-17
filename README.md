# BRBitly

BRBitly provides an Objective C wrapper class for accessing the free URL shortening services at [bit.ly](http://www.bitly.com) from iOS 4.0 or newer.

# Disclosure

BRBitly was rather brazenly copied and adapted from [ILBitly](https://github.com/InfiniteLoopDK/ILBitly.git).  I wanted to use ILBitly directly, but the existing project was already built around ASI and SBJson rather than AFNetwork and JSONkit, so I adapted it to my needs.

## Dependencies

- [ASI HTTP Request](https://github.com/pokeb/asi-http-request) - Used for the underlying network access
- [SBJson](https://github.com/stig/json-framework.git) - Needed for parsing the response from bit.ly
- You will also need an account at bit.ly including an [API key](http://bitly.com/a/your_api_key)


## Example Usage
###Shortening an URL
	BRBitly *bitly = [[BRBitly alloc] initWithLogin:login apiKey:apiKey];
	[bitly shorten:@"http://www.infinite-loop.dk" result:^(NSString *shortURLString) {
		NSLog(@"The shortened URL: %@", shortURLString);
	} error:^(NSError *err) {
		NSLog(@"An error occurred %@", err);
	}];
	[bitly release];

###Expanding an URL
	[bitly expand:@"http://j.mp/its-your-round" result:^(NSString *longURLString) {
		NSLog(@"The expanded URL: %@", longURLString);
	} error:^(NSError *err) {
		NSLog(@"An error occurred %@", err);
	}];

###Getting statistics on number of clicks
	[bitly clicks:@"http://j.mp/qnpNBs" result:^(NSInteger userClicks, NSInteger globalClicks) {
		NSLog(@"This link has been clicked %d times out of %d clicks globally: %d", userClicks, globalClicks);
	} error:^(NSError *err) {
		NSLog(@"An error occurred %@", err);
	}];


See more examples in the attached sample project.

## Building Xcode Documentation

BRBitly is documented in the header files using the appledoc syntax. The sample app contains a target called "Documentation" which will build the documentation and install it for use inside Xcode as a searchable and browsable docset.
In order to be able to build it you will need to install appledoc on your own computer. You can get appledoc from [GitHub](https://github.com/tomaz/appledoc).
For more information about how to setup and build the documentation you can read this [short tutorial](http://wp.me/p1xKtH-52).

Feel free to add enhanchements, bug fixes, changes and provide them back to the community!


Thanks,

Reid van Melle

