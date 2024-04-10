/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Item prototype for laying out an individual collection view item.
*/

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    static let reuseIdentifier = NSUserInterfaceItemIdentifier("text-item-reuse-identifier")

    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            updateSelectionHighlighting()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateSelectionHighlighting()
        }
    }

    private func updateSelectionHighlighting() {
        if !isViewLoaded {
            return
        }

        let showAsHighlighted = (highlightState == .forSelection) ||
            (isSelected && highlightState != .forDeselection) ||
            (highlightState == .asDropTarget)

        textField?.textColor = showAsHighlighted ? .selectedControlTextColor : .labelColor
        if let box = view as? NSBox {
            box.fillColor = showAsHighlighted ? .selectedControlColor : .clear
        }
    }
}

