//
//  ViewSizeCalculation.swift
//
//  Created by strayRed on 2023/1/23.
//

import Foundation

extension UIView {
    public enum LayoutSizeFittingStyle {
        case compressed
        case expanded
        var size: CGSize {
            switch self {
            case .compressed: return UIView.layoutFittingCompressedSize
            case .expanded: return UIView.layoutFittingCompressedSize
            }
        }
    }
    public enum LayoutSizeConstraint {
        case height(CGFloat?)
        case width(CGFloat?)
        case none
    }
}
extension UIView {
    @objc public var autoLayoutContentView: UIView { self }
}

extension UITableViewCell {
     public override var autoLayoutContentView: UIView {
        return contentView
    }
}

extension UICollectionViewCell {
    public override var autoLayoutContentView: UIView {
        return contentView
    }
}

extension UITableViewHeaderFooterView {
    public override var autoLayoutContentView: UIView {
        return contentView
    }
}

extension UIView {
    public enum LayoutSizeCaculatingType {
        case autoLayout(sizeConstraint: LayoutSizeConstraint, style: UIView.LayoutSizeFittingStyle)
        case frame(edgeSize: CGSize)
    }
    
    public func caculateLayoutSize(type: LayoutSizeCaculatingType) -> CGSize {
        switch type {
        case .frame(let edgeSize):
            layoutIfNeeded()
            let maxSize = maxSubviewSize
            return CGSize.init(width: maxSize.width + edgeSize.width, height: maxSize.height + edgeSize.height)
        case let .autoLayout(sizeConstraint, style):
            return caculateAutoLayoutSize(sizeConstraint: sizeConstraint, style: style)
        }
    }
    
    public func caculateAutoLayoutSize(sizeConstraint: LayoutSizeConstraint, style: UIView.LayoutSizeFittingStyle) -> CGSize {
        let isListItemView = self.isListItemView
        let translatesAutoresizingMaskIntoConstraints = autoLayoutContentView.translatesAutoresizingMaskIntoConstraints
        let autoresizingMaskCondition = !isListItemView && translatesAutoresizingMaskIntoConstraints
        defer {
            if autoresizingMaskCondition {
                autoLayoutContentView.translatesAutoresizingMaskIntoConstraints = true
            }
        }
        if autoresizingMaskCondition {
            autoLayoutContentView.translatesAutoresizingMaskIntoConstraints = false
        }
        var currentHeightConstraint: NSLayoutConstraint?
        var currentWidthConstraint: NSLayoutConstraint?
        
        func deactivateSizeConstraints() {
            guard !isListItemView else { return }
            for constraint in autoLayoutContentView.constraints {
                if constraint.firstItem as! NSObject == autoLayoutContentView && constraint.secondItem == nil {
                    switch constraint.firstAttribute {
                    case .height:
                        currentHeightConstraint = constraint
                        NSLayoutConstraint.deactivate([constraint])
                    case .width:
                        currentWidthConstraint = constraint
                        NSLayoutConstraint.deactivate([constraint])
                    default: break
                    }
                }
            }
        }
        
        func reactivateSizeConstraints() {
            if let currentHeightConstraint = currentHeightConstraint {
                NSLayoutConstraint.activate([currentHeightConstraint])
            }
            if let currentWidthConstraint = currentWidthConstraint {
                NSLayoutConstraint.activate([currentWidthConstraint])
            }
        }
        
        switch sizeConstraint {
        case .width(let constraintWidth):
            var addtionalWidthConstraint: NSLayoutConstraint?
            if let constraintWidth = constraintWidth {
                deactivateSizeConstraints()
                addtionalWidthConstraint = .init(item: autoLayoutContentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constraintWidth)
                NSLayoutConstraint.activate([addtionalWidthConstraint!])
            }
            let size = autoLayoutContentView.systemLayoutSizeFitting(style.size)
            if let addtionalWidthConstraint = addtionalWidthConstraint {
                NSLayoutConstraint.deactivate([addtionalWidthConstraint])
            }
            reactivateSizeConstraints()
            return size
        case .height(let constraintHeight):
            var addtionalHeightConstraint: NSLayoutConstraint?
            if let constraintHeight = constraintHeight {
                deactivateSizeConstraints()
                addtionalHeightConstraint = .init(item: autoLayoutContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: constraintHeight)
                NSLayoutConstraint.activate([addtionalHeightConstraint!])
            }
            let size = autoLayoutContentView.systemLayoutSizeFitting(style.size)
            if let addtionalHeightConstraint = addtionalHeightConstraint {
                NSLayoutConstraint.deactivate([addtionalHeightConstraint])
            }
            reactivateSizeConstraints()
            return size
        case .none:
            return autoLayoutContentView.systemLayoutSizeFitting(style.size)
        }
    }
    
    private var maxSubviewSize: CGSize {
        var maxX: CGFloat = 0; var maxY: CGFloat = 0
        subviews.forEach() {
            if $0.frame.maxX > maxX { maxX = $0.frame.maxX }
            if $0.frame.maxY > maxY { maxY = $0.frame.maxY }
        }
        return .init(width: maxX, height: maxY)
    }
    
    private var isListItemView: Bool {
        let conditions: [(UIView) -> (Bool)] = [
            { $0 is UITableViewCell },
            { $0 is UITableViewHeaderFooterView },
            { $0 is UICollectionReusableView }
        ]
        for condition in conditions {
            if condition(self) { return true }
        }
        return false
    }
}
