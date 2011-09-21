//
//  RootViewController.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunKeeper.h"

@interface RootViewController : UIViewController <RunKeeperConnectionDelegate> {
}

@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIButton *startButton, *pauseButton, *disconnectButton, *connectButton;

- (IBAction)toggleStart;
- (IBAction)togglePause;
- (IBAction)connectToRunKeeper;
- (IBAction)disconnect;


@end
