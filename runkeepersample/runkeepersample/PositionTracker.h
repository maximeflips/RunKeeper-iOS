//
//  PositionTracker.h
//  rrgps-iphone
//
//  Created by Shawn Hyam on 10-10-26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface PositionTracker : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
}

@end
