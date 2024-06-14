/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Main app controller object using adopting the NSApplicationDelegate protocol.
 */

#import "AppDelegate.h"
#import "MyWindowController.h"

@interface AppDelegate ()

@property (strong) MyWindowController *myWindowController;

@end

#pragma mark -

@implementation AppDelegate

// -------------------------------------------------------------------------------
//	applicationShouldTerminateAfterLastWindowClosed:sender
//
//	NSApplication delegate method placed here so the sample conveniently quits
//	after we close the window.
// -------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

// -------------------------------------------------------------------------------
//	applicationDidFinishLaunching:notification
// -------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// Load the app's main window for display.
	_myWindowController = [[MyWindowController alloc] initWithWindowNibName:@"TestWindow"];
	[self.myWindowController showWindow:self];
}

@end
