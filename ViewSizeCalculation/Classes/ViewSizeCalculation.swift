//
//  ViewSizeCalculation.swift
//  Pods-ViewSizeCalculation_Example
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
        let translatesAutoresizingMaskIntoConstraints = autoLayoutContentView.translatesAutoresizingMaskIntoConstraints
        let autoresizingMaskCondition = translatesAutoresizingMaskCondition && translatesAutoresizingMaskIntoConstraints
        defer {
            if autoresizingMaskCondition {
                autoLayoutContentView.translatesAutoresizingMaskIntoConstraints = true
            }
        }
        if autoresizingMaskCondition {
            autoLayoutContentView.translatesAutoresizingMaskIntoConstraints = false
        }
        switch sizeConstraint {
        case .width(let constraintWidth):
            var addtionalWidthConstraint: NSLayoutConstraint?
            var currentHeightConstraint: NSLayoutConstraint?
            if let constraintWidth = constraintWidth {
                addtionalWidthConstraint = .init(item: autoLayoutContentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constraintWidth)
                NSLayoutConstraint.activate([addtionalWidthConstraint!])
            }
            for constraint in constraints {
                if constraint.firstItem as! NSObject == autoLayoutContentView && constraint.firstAttribute == .height && constraint.secondItem == nil {
                    currentHeightConstraint = constraint
                    NSLayoutConstraint.deactivate([constraint])
                    break
                }
            }
            let size = autoLayoutContentView.systemLayoutSizeFitting(style.size)
            if let addtionalWidthConstraint = addtionalWidthConstraint {
                NSLayoutConstraint.deactivate([addtionalWidthConstraint])
            }
            if let currentHeightConstraint = currentHeightConstraint {
                NSLayoutConstraint.deactivate([currentHeightConstraint])
            }
            return size
        case .height(let constraintHeight):
            var addtionalHeightConstraint: NSLayoutConstraint?
            var currentWidthConstraint: NSLayoutConstraint?
            if let constraintHeight = constraintHeight {
                addtionalHeightConstraint = .init(item: autoLayoutContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: constraintHeight)
                NSLayoutConstraint.activate([addtionalHeightConstraint!])
            }
            for constraint in constraints {
                if constraint.firstItem as! NSObject == autoLayoutContentView && constraint.firstAttribute == .width && constraint.secondItem == nil {
                    currentWidthConstraint = constraint
                    NSLayoutConstraint.deactivate([constraint])
                    break
                }
            }
            let size = autoLayoutContentView.systemLayoutSizeFitting(style.size)
            if let addtionalHeightConstraint = addtionalHeightConstraint {
                NSLayoutConstraint.deactivate([addtionalHeightConstraint])
            }
            if let currentWidthConstraint = currentWidthConstraint {
                NSLayoutConstraint.deactivate([currentWidthConstraint])
            }
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
    
    private var translatesAutoresizingMaskCondition: Bool {
        let conditions: [(UIView) -> (Bool)] = [
            { ($0 is UICollectionReusableView) && !($0 is UICollectionViewCell) },
            { $0 is UITableViewCell } ]
        return conditions.reduce(true) { $0 && !$1(self) }
    }
}
