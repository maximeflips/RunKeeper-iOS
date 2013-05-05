//
//  RootViewController.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RunKeeper.h"

@interface NSString (NSString_TimeInterval)

+ (NSString*)stringWithTimeInterval:(NSTimeInterval)interval tenths:(BOOL)tenths;

@end

typedef enum {
    kStopped,
    kRunning,
    kPaused,
} ActivityState;


@interface RootViewController : UIViewController 
    <RunKeeperConnectionDelegate, CLLocationManagerDelegate, UIAlertViewDelegate> {
    ActivityState state;
    NSTimeInterval elapsedTime;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *beginTime, *startTime, *endTime;
@property (nonatomic, strong) NSTimer *tickTimer;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton, *pauseButton, *disconnectButton, *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (IBAction)toggleStart;
- (IBAction)togglePause;
- (IBAction)connectToRunKeeper;
- (IBAction)disconnect;


@end
