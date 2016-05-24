//
//  TBVPullRefreshProtocol.swift
//  TBVAnimatePullView
//
//  Created by tripleCC on 16/5/17.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

private enum TBVObserverKeyPath: String {
    case ContentOffset = "contentOffset"
    case ContentSize = "contentSize"
    case ContentInset = "contentInset"
    static func keyPaths() -> [TBVObserverKeyPath] {
        return [.ContentOffset, .ContentSize, .ContentInset]
    }
}

public enum TBVRefreshState: Int {
    case None
    case Triggering
    case Triggered
    case Loading
    case CanFinish
}

public enum TBVPullViewType: Int {
    case Header
    case Footer
}

private let TBVPullViewHeight = CGFloat(54.0)
private let TBVPullViewRequiredTriggledPercent = CGFloat(0.95)
private let TBVPullViewRecoverNoneDuration = NSTimeInterval(0.25)
private let TBVPullViewRecoverLoadingDuration = NSTimeInterval(0.25)
private let TBVPullViewChangeVisualityDurantion = NSTimeInterval(0.3)

private func dispatchSeconds(second: NSTimeInterval, action: () -> ()) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(second * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        action()
    }
}

public class TBVPullView: UIView {
    public var showPullView: Bool = true {
        didSet {
            if oldValue == showPullView { return }
            hidden = !showPullView
            removeAllObservers()
            if showPullView {
                addAllObservers()
                resetScrollViewContentInset()
            } else {
                recoverScrollViewContentInset()
            }
//            guard let scrollView = scrollView else { return }
//            originEdgeInset = scrollView.contentInset
            print(#function, contentOffsetY, originEdgeInset, showPullView, self.frame)
        }
    }
    
    internal var pullViewType: TBVPullViewType?
    internal var pullViewHeight: CGFloat {
        return TBVPullViewHeight
    }
    internal var requiredTriggledPercent: CGFloat {
        return TBVPullViewRequiredTriggledPercent
    }
    internal var recoverNoneDuration: NSTimeInterval {
        return TBVPullViewRecoverNoneDuration
    }
    internal var recoverLoadingDuration: NSTimeInterval {
        return TBVPullViewRecoverLoadingDuration
    }
    internal var changeVisualityDurantion: NSTimeInterval {
        return TBVPullViewChangeVisualityDurantion
    }
    internal var refreshState: TBVRefreshState = .None {
        didSet {
            let triggerPercent = refreshState == .Triggering ? triggerPercentHeight / frame.height : 0
            if refreshState != oldValue {
                print(refreshState)
            }
            adjustInterfaceByRefreshState(refreshState, triggerPercent: min(triggerPercent, 1.0))
        }
    }
    // Superview must be UIScrollView or it's subclass
    internal var scrollView: UIScrollView?
    internal var refreshingCallBack: ((refreshView: TBVPullView) -> Void)?
    private var hadAddObservers = Bool(false)
    private var originEdgeInset = UIEdgeInsets()
    private var isHeader: Bool {
        if pullViewType == nil {
            fatalError("pullViewType must be set by subclass in order to get right type")
        }
        return pullViewType == .Header
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else { return }
        self.scrollView = scrollView
        originEdgeInset = scrollView.contentInset
        frame.size = CGSize(width: scrollView.frame.width, height: pullViewHeight)
        removeAllObservers()
        addAllObservers()
        resetScrollViewContentInset()
//        print(self.frame)
    }
    
    deinit {
        removeAllObservers()
        print("deinit  \(self)")
    }
    
    // Subclass must overwrite this method to observer changes of refresh state and adjust interface
    // TrigglePercent is progress of state from Triggering to triggered
    internal func adjustInterfaceByRefreshState(refreshState: TBVRefreshState,
                                                triggerPercent: CGFloat) {
        fatalError("\(#function) must be overwrited by subclass")
    }

    private func runRefreshStateMachine() {
        guard let scrollView = scrollView else { return }
        // State machine
        switch refreshState {
        case .None:
            if triggeringCondition && scrollView.dragging {
                refreshState = .Triggering
            }
        case .Triggering:
            refreshState = triggeredCondition ? .Triggered :
                (triggeringCondition ? .Triggering : .None)
        case .Triggered:
            if loadingCondition {
                if !scrollView.dragging {
                    refreshState = .Loading
                    setScrollViewContentOffsetY(adjustedLoadingOffset,
                                                duration: recoverLoadingDuration)
                    refreshingCallBack?(refreshView: self)
                }
            } else {
                refreshState = .Triggering
            }
        case .CanFinish:
            if !scrollView.dragging && canFinishCondition {
                setScrollViewContentOffsetY(adjustedNoneOffset, duration: recoverNoneDuration)
                dispatchSeconds(recoverNoneDuration, action: {
                    self.refreshState = .None
                })
            }
        default:
            break
        }
    }
    
    public func endRefreshing() {
        refreshState = .CanFinish
        runRefreshStateMachine()
    }
}

typealias TBVPullViewStateMachineHelper = TBVPullView
extension TBVPullViewStateMachineHelper {
    private func setScrollViewEdgeInset(inset: UIEdgeInsets) {
        UIView.animateWithDuration(changeVisualityDurantion) {
            self.scrollView?.contentInset = inset
        }
    }
    
    private func setScrollViewContentOffsetY(offsetY: CGFloat, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration) {
            if self.isHeader {
                self.scrollView?.contentInset.top = -offsetY
            }
            self.scrollView?.contentOffset.y = offsetY
            print(offsetY, self.isHeader)
        }
    }
    
    private func resetScrollViewContentInset() {
        setScrollViewEdgeInsetWithOffset(frame.height)
        resetOriginY()
    }
    
    private func recoverScrollViewContentInset() {
        setScrollViewEdgeInsetWithOffset(-frame.height)
    }
    
    private func setScrollViewEdgeInsetWithOffset(offset: CGFloat) {
        guard let scrollView = scrollView else { return }
        var edgeInset = scrollView.contentInset
        if isHeader {
            edgeInset.top = originEdgeInset.top
        } else {
            edgeInset.bottom = originEdgeInset.bottom + offset
        }
        print(#function, edgeInset, isHeader)
        setScrollViewEdgeInset(edgeInset)
    }
    
    private func resetOriginY() {
        guard let scrollView = scrollView else { return }
        frame.origin.y = isHeader ? -frame.size.height : scrollView.contentSize.height
    }
    
    private var contentOffsetY: CGFloat {
        return scrollView?.contentOffset.y ?? 0
    }
    
    private var absoluteContentSizeHeight: CGFloat {
        guard let scrollView = scrollView else { return 0 }
        return scrollView.contentSize.height - scrollView.bounds.height + originEdgeInset.bottom + originEdgeInset.top
    }
    
    private var footerAppearOffsetY: CGFloat {
        return absoluteContentSizeHeight > 0 ? absoluteContentSizeHeight - originEdgeInset.top : 0
    }
    
    private var headerAppearOffsetY: CGFloat {
        return -originEdgeInset.top
    }
    
    private var triggerPercentHeight: CGFloat {
//        print(#function, contentOffsetY, footerAppearOffsetY)
        return isHeader ?
            -contentOffsetY + headerAppearOffsetY :
            contentOffsetY - footerAppearOffsetY
    }
    
    private var triggeringCondition: Bool {
        return isHeader ?
            contentOffsetY < headerAppearOffsetY :
            contentOffsetY > footerAppearOffsetY
    }
    
    private var triggeredCondition: Bool {
        return isHeader ?
            contentOffsetY <= headerAppearOffsetY - frame.height * requiredTriggledPercent :
            contentOffsetY >= footerAppearOffsetY + frame.height * requiredTriggledPercent
    }
    
    private var loadingCondition: Bool {
        return triggeredCondition
    }
    
    private var canFinishCondition: Bool {
        return isHeader ?
            contentOffsetY <= headerAppearOffsetY :
            contentOffsetY <= footerAppearOffsetY
    }
    
    private var adjustedLoadingOffset: CGFloat {
        return isHeader ?
            headerAppearOffsetY - frame.height :
            footerAppearOffsetY
    }
    
    private var adjustedNoneOffset: CGFloat {
        return isHeader ?
            headerAppearOffsetY :
            contentOffsetY
    }
}

typealias TBVPullViewObserver = TBVPullView
extension TBVPullViewObserver {
    private func removeAllObservers() {
        if !hadAddObservers { return }
        TBVObserverKeyPath.keyPaths().forEach {
            self.removeObserverForKeyPath($0)
        }
        hadAddObservers = false
    }
    
    private func addAllObservers() {
        if hadAddObservers { return }
        TBVObserverKeyPath.keyPaths().forEach {
            self.addObserverForKeyPath($0)
        }
        hadAddObservers = true
    }
    
    private func removeObserverForKeyPath(keyPath: TBVObserverKeyPath) {
        scrollView?.removeObserver(self, forKeyPath: keyPath.rawValue)
    }
    
    private func addObserverForKeyPath(keyPath: TBVObserverKeyPath) {
        scrollView?.addObserver(self, forKeyPath: keyPath.rawValue, options: [.New, .Old], context: nil)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let change = change,
            let keyPathString = keyPath else { return }
        
        guard let keyPath = TBVObserverKeyPath(rawValue: keyPathString) else { return }
        switch keyPath {
        case .ContentOffset:
            guard let new = change[NSKeyValueChangeNewKey]?.CGPointValue,
                  let old = change[NSKeyValueChangeOldKey]?.CGPointValue else { return }
            guard new != old else { return }
            runRefreshStateMachine()
        case .ContentSize:
            guard let new = change[NSKeyValueChangeNewKey]?.CGSizeValue(),
                  let old = change[NSKeyValueChangeOldKey]?.CGSizeValue() else { return }
            guard new != old else { return }
            resetOriginY()
        case .ContentInset:
            // Don't change edgeInsets when pullView is in loading state ,
            // otherwise the observer would't record this change
            guard let edgeInsets = change[NSKeyValueChangeNewKey]?.UIEdgeInsetsValue()
                where refreshState != .Loading else { return }
            originEdgeInset = edgeInsets
        }
    }
}

extension UIScrollView {
    private struct Static {
        static var TBVRefreshHeaderKey = "TBVRefreshHeaderKey"
        static var TBVLoadMoreFooterKey = "TBVLoadMoreFooterKey"
    }
    
    var header: TBVPullView? {
        set {
            header?.removeFromSuperview()
            print(header)
            guard let header = newValue else { return }
            guard header.pullViewType == .Header else {
                fatalError("the header's pullViewType should be Header")
            }
            addSubview(header)
            objc_setAssociatedObject(self, &Static.TBVRefreshHeaderKey, header, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &Static.TBVRefreshHeaderKey) as? TBVPullView
        }
    }
    
    var footer: TBVPullView? {
        set {
            footer?.removeFromSuperview()
            guard let footer = newValue else { return }
            guard footer.pullViewType == .Footer else {
                fatalError("the footer's pullViewType should be Footer")
            }
            addSubview(footer)
            objc_setAssociatedObject(self, &Static.TBVLoadMoreFooterKey, footer, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &Static.TBVLoadMoreFooterKey) as? TBVPullView
        }
    }
}