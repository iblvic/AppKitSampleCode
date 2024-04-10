# Creating and Customizing the Touch Bar

Adopt Touch Bar support by displaying interactive content and controls for your macOS apps.

## Overview
You can use the Touch Bar to display interactive content and controls for supported models of MacBook Pro.

This sample uses a split-view controller architecture to navigate various ways to implement the [`NSTouchBar`](https://developer.apple.com/documentation/appkit/nstouchbar) class. The `PrimaryViewController` class shows the available use cases. When you select one of the use cases, the secondary view shows what you can do with the Touch Bar controls.

The description in each secondary view controller reflects its target item. For example, the `ButtonViewController` class shows how to use an `NSButton` object. The sample hosts all view controllers in separate storyboards.

Refer to this sample if you're looking for specific ways to use and customize the `NSTouchBar`. It shows how to create an [`NSTouchBarItem`](https://developer.apple.com/documentation/appkit/nstouchbaritem) for use with buttons, views, pickers, sliders, popovers, scrubbers, text fields, and text views.

The sample also displays a secondary window that shows a typical use case with the Touch Bar that uses an [`NSScrubber`](https://developer.apple.com/documentation/appkit/nsscrubber) to pick an image that changes the window background.

## Configure the Sample Code Project

In Xcode, select your development team on the macOS target's Signing and Capabilities tab.

## Simulate the Touch Bar in Xcode

When adopting Touch Bar support for your app, but running Xcode on a Mac without a Touch Bar, enable the Xcode Touch Bar simulator by choosing Window > Touch Bar -> Show Touch Bar.

## Create the Touch Bar

Create a Touch Bar by adding one to a view controller in the storyboard, or by creating one programmatically by overriding the `NSResponder` [`makeTouchBar()`](https://developer.apple.com/documentation/appkit/nsresponder/2544690-maketouchbar) function. The following example demonstrates overriding `makeTouchBar()` for an `NSViewController` that displays a color-picker button or [`NSColorPickerTouchBarItem`](https://developer.apple.com/documentation/appkit/nscolorpickertouchbaritem):

``` swift
override func makeTouchBar() -> NSTouchBar? {
    let touchBar = NSTouchBar()
    touchBar.delegate = self
    
    touchBar.customizationIdentifier = colorPickerBar
    touchBar.defaultItemIdentifiers = [selectedItemIdentifier]
    touchBar.customizationAllowedItemIdentifiers = [selectedItemIdentifier]
    touchBar.principalItemIdentifier = selectedItemIdentifier
    
    return touchBar
}
```

## Add Content to the Touch Bar

Add content to the Touch Bar by adopting the [`NSTouchBarDelegate`](https://developer.apple.com/documentation/appkit/nstouchbardelegate) protocol and implementing [`touchBar(_:makeItemForIdentifier:)`](https://developer.apple.com/documentation/appkit/nstouchbardelegate/2544851-touchbar). The following example adds a Sharing Service button:

``` swift
func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
    guard identifier == services else { return nil }
    
    let services = NSSharingServicePickerTouchBarItem(identifier: identifier)
    services.delegate = self
    
    return services
}
```

## Add a Scrubber to the Touch Bar

The `NSScrubber` class provides a way to add a flexible, horizontally oriented picker. Add a scrubber view to an [`NSCustomTouchBarItem`](https://developer.apple.com/documentation/appkit/nscustomtouchbaritem), and that view adds a scrubber to the Touch Bar.

``` swift
func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
    let scrubberItem: NSCustomTouchBarItem
    
    scrubberItem = NSCustomTouchBarItem(identifier: identifier)
    scrubberItem.customizationLabel = NSLocalizedString("Choose Photo", comment: "")
    
    let scrubber = NSScrubber()
    scrubber.register(NSScrubberImageItemView.self, forItemIdentifier: itemViewIdentifier)
    scrubber.mode = .free
    scrubber.selectionBackgroundStyle = .roundedBackground
    scrubber.delegate = self
    scrubber.dataSource = self
    scrubber.showsAdditionalContentIndicators = true
    scrubber.scrubberLayout = NSScrubberFlowLayout()
    
    scrubberItem.view = scrubber
    
    // Set the scrubber's width to be 400.
    let viewBindings: [String: NSView] = ["scrubber": scrubber]
    let hconstraints =
        NSLayoutConstraint.constraints(withVisualFormat: "H:[scrubber(400)]",
                                       options: [],
                                       metrics: nil,
                                       views: viewBindings)
    NSLayoutConstraint.activate(hconstraints)
    
    return scrubberItem
}
```

## Add a Popover to the Touch Bar

An `NSCustomTouchBarItem` class shows its own Touch Bar when the user taps and holds on it. This class is a two-state control that can expand into its second state, which shows the contents of a bar it owns. The second Touch Bar displays when this item *pops*. The following example shows how to create an [`NSPopoverTouchBarItem`](https://developer.apple.com/documentation/appkit/nspopovertouchbaritem) with an `NSScrubber` view with a set of numbered text items:

``` swift
func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
    guard identifier == scrubberPopover else { return nil }
    
    let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
    popoverItem.collapsedRepresentationLabel =
        NSLocalizedString("Scrubber Popover", comment: "")
    popoverItem.customizationLabel =
        NSLocalizedString("Scrubber Popover", comment: "")
    
    let scrubber = PopoverScrubber()
    scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: textScrubber)
    
    scrubber.mode = .free
    scrubber.selectionBackgroundStyle = .roundedBackground
    scrubber.delegate = self
    scrubber.dataSource = self
    scrubber.presentingItem = popoverItem
    
    popoverItem.collapsedRepresentation = scrubber
    
    popoverItem.popoverTouchBar =
        PopoverTouchBarSample(presentingItem: popoverItem)
    
    return popoverItem
}
```
