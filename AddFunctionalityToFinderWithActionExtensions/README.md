# Add Functionality to Finder with Action Extensions 

Implement Action Extensions to provide quick access to commonly used features of your app.

## Overview

Action Extensions can let users access features of your app directly from macOS. For example, if your app contains the functionality to perform image processing, an Action Extension could allow users to process their images directly from Finder. This sample code project creates three Action Extensions, two for processing images and one for processing text. One extension also presents a user interface and all three are available from both the Touch Bar and Finder Preview pane.

The project consists of four targets:

* A macOS app target that has no functionality, but would normally contain your main application.
* `ThumbnailAction`, an Action Extension target that takes images of any type as inputs and outputs thumbnail versions of them. This extension preserves the original input files and creates thumbnails as new files.
* `RemoveOpacityAction`, an Action Extension target that takes PNG images as inputs and replaces them with opaque versions of the same images. During processing, this extension prompts the user for a color to draw as the background behind the transparent image.
* `UppercaseAction`, an Action Extension target that takes text as input and converts it to be uppercase.

The extensions in this sample all accept file data from Finder, process it, and output the data back to Finder. 

By default, new Action Extensions are not enabled in macOS. After running this sample code project, enable the extensions by selecting the "Create Thumbnail", "Make PNG Opaque", and "Convert Text to Upper Case" checkboxes in the Actions, Finder, and Touch Bar categories of the [Extensions System Preferences](https://support.apple.com/guide/mac-help/change-extensions-preferences-mchl8baf92fe/mac).

## Accept File Data

The system makes Action Extensions available depending on the type of data that the user has selected in Finder. For example, if the user selects a `PNG` file, Action Extensions that support images are shown. Each of the extensions in this sample operate on different kinds of input content:

* `ThumbnailAction` operates on *any* kind of image.
* `RemoveOpacityAction` operates specifically on PNG images.
* `UppercaseAction` operates on text.

The `NSExtensionActivationRule` key in the `Info.plist` of the associated target determines the conditions under which extensions are available. The value for this key can either be a dictionary, or a string.

`ThumbnailAction` and `UppercaseAction` are both configured with dictionary values. `ThumbnailAction` specifies that it accepts image data with the `NSExtensionActivationSupportsImageWithMaxCount` key and `UppercaseAction` specifies that it accepts text data with the `NSExtensionActivationSupportsText` key.

For more information on valid dictionary keys for `NSExtensionActivationRule`, see the [App Extension Keys reference](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html#//apple_ref/doc/uid/TP40014212-SW10).

`RemoveOpacityAction` uses a [`NSPredicate`](https://developer.apple.com/documentation/foundation/nspredicate) query as a string value for the `NSExtensionActivationRule`. The query in this sample project filters images to only be valid if they are in PNG format.

````
SUBQUERY (
    extensionItems,
    $extensionItem,
    SUBQUERY (
        $extensionItem.attachments,
        $attachment,
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.png"
    ).@count == $extensionItem.attachments.@count
).@count == 1
````

For more information on defining extension activation rules, see the [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW8). 

## Process Input Attachments

When a user invokes an Action Extension, the system instantiates the [`NSExtensionPrincipalClass`](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html#//apple_ref/doc/uid/TP40014212-SW3) specified in the `Info.plist` and asks it to handle the request through the [`NSExtensionRequestHandling`](https://developer.apple.com/documentation/foundation/nsextensionrequesthandling) protocol.

The system calls the [`beginRequest(with:)`](https://developer.apple.com/documentation/foundation/nsextensionrequesthandling/1413395-beginrequest) method and passes in an [`NSExtensionContext`](https://developer.apple.com/documentation/foundation/nsextensioncontext). To access the input files, use the [`attachments`](https://developer.apple.com/documentation/foundation/nsextensionitem/1416690-attachments) property of the [`NSExtensionItem`](https://developer.apple.com/documentation/foundation/nsextensionitem) contained in the [`inputItems`](https://developer.apple.com/documentation/foundation/nsextensioncontext/1414827-inputitems) array.

Once processing completes, pass output files back to the system by creating new [`NSItemProvider`](https://developer.apple.com/documentation/foundation/nsitemprovider) objects and registering them with [`registerFileRepresentation(forTypeIdentifier:fileOptions:visibility:loadHandler:`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888337-registerfilerepresentation). 

``` swift
let itemProvider = NSItemProvider()
itemProvider.registerFileRepresentation(
    forTypeIdentifier: kUTTypePNG as String, fileOptions: [.openInPlace],
    visibility: .all, loadHandler: { completionHandler in
        guard let sourceImage = NSImage(contentsOf: sourceUrl) else { return nil }
        let thumbnailImage = sourceImage.thumbnailImage
        let thumbnailUrl = self.thumbnailUrl(for: sourceUrl)
        thumbnailImage.savePNGToDisk(at: thumbnailUrl)
        completionHandler(thumbnailUrl, false, nil)
        return nil
    }
)
```
[View in Source](x-source-tag://RegisterFileRepresentation)

To obtain the correct directory path for writing output files, use [`url(for:in:appropriateFor:create:)`](https://developer.apple.com/documentation/foundation/filemanager/1407693-url), passing the [`itemReplacementDirectory`](https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory/itemreplacementdirectory) constant.

``` swift
let itemReplacementDirectory = try FileManager.default.url(
    for: .itemReplacementDirectory, in: .userDomainMask,
    appropriateFor: URL(fileURLWithPath: NSHomeDirectory()), create: true)
let thumbnailFilename = sourceUrl.deletingPathExtension().lastPathComponent + " Thumbnail.png"
```
[View in Source](x-source-tag://ItemReplacementDirectory)

Finally, signal that the action is complete by calling [`completeRequest(returningItems:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsextensioncontext/1411301-completerequest).

- Note: If you wish to preserve the input files instead of replacing them, it is important that `NSItemProvider` objects for the original input files are also included in the returned array of item providers. The `ThumbnailAction` target in this sample code project demonstrates passing back both the original input files as well as new thumbnail files.

## Process Text Data

The `UppercaseAction` extension accepts any text, either supplied as attachments in the same way as `ThumbnailAction` and `RemoveOpacityAction`, or from other sources such as a standard `NSTextField` control. Check the [`attributedContentText`](https://developer.apple.com/documentation/foundation/nsextensionitem/1408297-attributedcontenttext) property for input from text fields.

If `attributedContentText` is empty, check for input in the [`attachments`](https://developer.apple.com/documentation/foundation/nsextensionitem/1416690-attachments) property of [`NSExtensionItem`](https://developer.apple.com/documentation/foundation/nsextensionitem). 

``` swift
let outputItem = NSExtensionItem()
outputItem.attributedContentText = NSAttributedString(string: inputContent.string.uppercased())
context.completeRequest(returningItems: [outputItem], completionHandler: nil)
```
[View in Source](x-source-tag://AttributedContentText)

## Present a User Interface

If the action requires user interaction then the extension may present a user interface. Set the [`NSExtensionPointIdentifier`](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html#//apple_ref/doc/uid/TP40014212-SW15) key in the `Info.plist` to `com.apple.ui-services` and ensure that the principal class is a subclass of  [`NSViewController`](https://developer.apple.com/documentation/appkit/nsviewcontroller). If the extension does not require user interaction, specify `com.apple.services` and have the principal class conform to `NSExtensionRequestHandling`. 

- Note: When creating a new Action Extension target, Xcode prompts you to decide if your extension will present a user interface. Based on that choice, Xcode sets appropriate initial values for `NSExtensionPointIdentifier` and [`NSExtensionPrincipalClass`](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html#//apple_ref/doc/uid/TP40014212-SW3).

Extensions that present a user interface show their view controller's view immediately after the extension calls [`beginRequest(with:)`](https://developer.apple.com/documentation/foundation/nsextensionrequesthandling/1413395-beginrequest) and should input files with the [`extensionContext`](https://developer.apple.com/documentation/appkit/nsviewcontroller/1434457-extensioncontext) property of [`NSViewController`](https://developer.apple.com/documentation/appkit/nsviewcontroller). 

Once the extension's user interface has completed any required user interaction for the task, process the files in the normal way by calling [`completeRequest(returningItems:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsextensioncontext/1411301-completerequest).

To cancel the task, use the [`cancelRequest(withError:)`](https://developer.apple.com/documentation/foundation/nsextensioncontext/1412773-cancelrequest). Pass a [`NSUserCancelledError`](https://developer.apple.com/documentation/foundation/nsusercancellederror) if the user canceled the task, or an error caused the failure. 

``` swift
let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
context.cancelRequest(withError: cancelError)
```
[View in Source](x-source-tag://CancelRequest)

## Support the Touch Bar and Finder Preview Pane

Users may also access Action Extensions from the Touch Bar and from the Quick Actions menu in Finder's Preview pane. Set both `NSExtensionServiceAllowsFinderPreviewItem` and `NSExtensionServiceAllowsTouchBarItem` to `YES` in the `Info.plist` to support the Touch Bar and Preview Pane.

Each extension must also have a template icon for use in the Quick Actions menu and the Finder Preview pane. Specify the icon with the `NSExtensionServiceTouchBarIconName` key of the `Info.plist` for each target. For more information, see the [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/extensions/action-extensions/). The color of the Touch Bar button can also be customized using the `NSExtensionServiceTouchBarBezelColorName` key. By default, this is a `TouchBarBezel` color but can be any color in the asset catalog for the target.

For information on how to add Quick Actions to the Touch Bar see the [Automator User Guide](https://support.apple.com/guide/automator/use-quick-action-workflows-aut73234890a/mac#aut7b29b7fc1).
