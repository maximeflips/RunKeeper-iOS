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

typedef enum {
    kStopped,
    kRunning,
    kPaused,
} ActivityState;


@interface RootViewController : UIViewController <RunKeeperConnectionDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    ActivityState state;
    UIButton *startButton, *pauseButton, *disconnectButton, *connectButton;
}

@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIButton *startButton, *pauseButton, *disconnectButton, *connectButton;

- (IBAction)toggleStart;
- (IBAction)togglePause;
- (IBAction)connectToRunKeeper;
- (IBAction)disconnect;


@end
