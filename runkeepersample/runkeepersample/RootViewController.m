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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
}

- (IBAction)togglePause
{
    
}

- (IBAction)connectToRunKeeper
{
    [[AppData sharedAppData].runKeeper tryToConnect:self];
}

- (IBAction)disconnect
{
    [[AppData sharedAppData].runKeeper disconnect];
    [self updateViews];
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
}

@end
