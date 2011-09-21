//
//  RootViewController.m
//  runkeepersample
//
//  Created by Reid van Melle on 11-09-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "AppData.h"

@implementation RootViewController

@synthesize progressLabel, startButton, pauseButton, disconnectButton, connectButton;

- (void)updateViews
{
    RunKeeper *rk = [AppData sharedAppData].runKeeper;
    self.connectButton.enabled = !rk.connected;
    self.disconnectButton.hidden = !rk.connected;
    self.pauseButton.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    state = kStopped;
    self.title = @"RunKeeper Sample";
    self.progressLabel.text = @"Touch start to begin";
    [self updateViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (IBAction)toggleStart
{
    if (state == kStopped) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 0.0;
        [locationManager startUpdatingLocation];  
        state = kRunning;
        [self.startButton setTitle:@"STOP" forState:UIControlStateNormal];
        self.pauseButton.hidden = NO;
    } else if (state == kRunning) {
        [locationManager stopUpdatingLocation];
        [locationManager release];
        locationManager = nil;
        state = kStopped;
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
        self.pauseButton.hidden = YES;
    }
}

- (IBAction)togglePause
{
    if (state == kRunning) {
        state = kPaused;
        [self.pauseButton setTitle:@"RESUME" forState:UIControlStateNormal];
    } else if (state == kPaused) {
        state = kRunning;
        [self.pauseButton setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
}

- (IBAction)connectToRunKeeper
{
    [[AppData sharedAppData].runKeeper tryToConnect:self];
}

- (IBAction)disconnect
{
    [[AppData sharedAppData].runKeeper disconnect];
    [self updateViews];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Disconnect" 
                                                     message:@"Running Intensity is no longer linked to your RunKeeper account"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

#pragma mark CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
}

#pragma mark RunKeeperConnectionDelegate

// Connected is called when an existing auth token is found
- (void)connected
{
    [self updateViews];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connected" 
                                                     message:@"Running Intensity is linked to your RunKeeper account"
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
    
}

// Called when the request to connect to runkeeper failed
- (void)connectionFailed:(NSError*)err
{
    [self updateViews];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connection Failed" 
                                                     message:@"The link to your RunKeeper account failed."
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

// Called when authentication is needed to connect to RunKeeper --- normally, the client app will call
// tryToAuthorize at this point
- (void)needsAuthentication
{
    [[AppData sharedAppData].runKeeper tryToAuthorize];
}


/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.progressLabel = nil;
    self.startButton = nil;
    self.disconnectButton = nil;
    self.pauseButton = nil;
    self.connectButton = nil;

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
    [self.progressLabel release];
    [self.startButton release];
    [self.pauseButton release];
    [self.disconnectButton release];
    [self.connectButton release];
    if (locationManager) {
        [locationManager stopUpdatingLocation];
        [locationManager release];
    }
}

@end
