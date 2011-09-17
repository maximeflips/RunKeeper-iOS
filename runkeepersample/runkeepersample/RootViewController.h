//
//  RootViewController.h
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIButton *startButton;

- (IBAction)toggleStart;
- (IBAction)connectToRunKeeper;


@end
