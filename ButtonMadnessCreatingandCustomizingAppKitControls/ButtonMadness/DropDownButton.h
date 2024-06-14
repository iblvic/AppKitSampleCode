/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 NSButton subclass for supporting drop down menus.
 */

@import Cocoa;

@interface DropDownButton : NSButton
{
    NSPopUpButtonCell *popUpCell;
}

@property (NS_NONATOMIC_IOSONLY) BOOL usesMenu;

@end
