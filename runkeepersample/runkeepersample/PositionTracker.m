//
//  PositionTracker.m
//  rrgps-iphone
//
//  Created by Shawn Hyam on 10-10-26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PositionTracker.h"
//#import "JSON.h"



@implementation PositionTracker


- (id)init {
	if (self = [super init]) {				
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 0.0;
		[locationManager startUpdatingLocation];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
	[locationManager stopUpdatingLocation];
	[locationManager release];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

}


@end
