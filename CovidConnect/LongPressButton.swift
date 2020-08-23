//
//  LongPressButton.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/12/20.
//  Copyright © 2020 samsu. All rights reserved.
//
import Foundation
import UIKit

@objcMembers
class LongPressButton : UIControl {
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    ///
    /// A minimum duration that user has to press the button to start recongnizing long press. Otherwise
    /// it's a simple touch up.
    ///
    dynamic var minimumPressDuration: TimeInterval = 0.15 {
        didSet { gestureRecognizer.minimumPressDuration = minimumPressDuration }
    }
    
    ///
    /// A required duration that user has to press the button to trigger main event.
    ///
    dynamic var requiredPressDuration: TimeInterval = 5 {
        didSet { gestureRecognizer.requiredPressDuration = requiredPressDuration }
    }
    
    private var gestureRecognizer: PressGestureRecognizer!
    private var isEnabledToken: NSKeyValueObservation!
    private var progressView: ProgressView!
    private var titleLabel: UILabel!
    
    private var textAttributesForStates: [UInt: [NSAttributedString.Key: Any]] = [:]
    private var backgroundColorsForStates: [UInt: UIColor] = [:]
    
    private var titlesForStates: [UInt: String] = [:]
    private var titlesForEvents: [UInt: String] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        //
        gestureRecognizer = PressGestureRecognizer(target: self, action: #selector(gestureStateChanged(_:)))
        gestureRecognizer.pressDelegate = self
        gestureRecognizer.minimumPressDuration = minimumPressDuration
        gestureRecognizer.requiredPressDuration = requiredPressDuration
        addGestureRecognizer(gestureRecognizer)
        //
        
        progressView = ProgressView(frame: .zero)
        progressView.progressColor = progressColor
        addSubview(progressView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        addSubview(titleLabel)
        
        isEnabledToken = observe(\.isEnabled, changeHandler: { [weak self](object, _) in
            self?.updateTitleText()
            self?.updateTitleLabelAppearance()
            self?.updateBackgroundColor()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.layer.cornerRadius = Global.cornerR
        progressView.clipsToBounds = true
        progressView.frame = bounds
        titleLabel.frame = bounds
    }
    
    
    // MARK: - Appearance Methods
    
    ///
    /// Sets color of progress bar.
    ///
    dynamic var progressColor: UIColor? = UIColor.red {
        didSet {
            progressView.progressColor = progressColor
        }
    }
    
    ///
    /// Supported NSAttributedStringKey keys: .font, .foregroundColor
    ///
    dynamic func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any], forState: UIControl.State) {
        textAttributesForStates[forState.rawValue] = attributes
        updateTitleLabelAppearance()
    }
    
    ///
    /// Supported control states: .normal, .disabled
    ///
    dynamic func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        backgroundColorsForStates[forState.rawValue] = color
        updateBackgroundColor()
    }
    
    // MARK: - Configuration Methods
    
    ///
    /// Supported states are .normal, .disabled
    ///
    func setTitle(_ title: String?, forState: UIControl.State) {
        titlesForStates[forState.rawValue] = title
        updateTitleText()
    }
    
    ///
    /// Supported events are .valueChanged, .primaryActionTriggered
    ///
    func setTitle(_ title: String?, forEvent: UIControl.Event) {
        titlesForEvents[forEvent.rawValue] = title
        updateTitleText()
    }
    
    
    // MARK: - Transform Animation Methods
    
    ///
    /// Transform is used when user touches downt he control
    ///
    dynamic var touchDownTransform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    
    ///
    /// Touch down animation duration
    ///
    dynamic var touchDownDuration: TimeInterval = 0.05
    
    ///
    /// Touch up animation duration
    ///
    dynamic var touchUpDuration: TimeInterval = 0.1
    
    
    // MARK: - Private Methods
    
    @objc private func gestureStateChanged(_ recognizer: PressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            sendActions(for: .touchDown)
            feedbackGenerator.impactOccurred()
            touchedDown()
            updateTitleText()
        case .ended:
            sendActions(for: .primaryActionTriggered)
            touchedUp()
            updateTitleText()
        case .cancelled:
            sendActions(for: .touchCancel)
            touchedUp()
            progressView.setProgress(0, duration: recognizer.requiredPressDuration, delay: 0, animated: true)
            updateTitleText()
        case .failed:
            sendActions(for: .touchCancel)
            touchedUp()
            progressView.setProgress(0, duration: 0, delay: 0, animated: false)
            updateTitleText()
        default:
            break
        }
    }
    
    private func updateTitleLabelAppearance() {
        var attributes: [NSAttributedString.Key: Any]?
        if state.contains(.disabled), let disabledAttributes = textAttributesForStates[UIControl.State.disabled.rawValue] {
            attributes = disabledAttributes
        }
        else if let normalAttributes = textAttributesForStates[UIControl.State.normal.rawValue] {
            attributes = normalAttributes
        }
        
        titleLabel.font = attributes?[.font] as? UIFont
        titleLabel.textColor = attributes?[.foregroundColor] as? UIColor
    }
    
    private func updateBackgroundColor() {
        if state.contains(.disabled), let disabledBackgroundColor = backgroundColorsForStates[UIControl.State.disabled.rawValue] {
            backgroundColor = disabledBackgroundColor
        }
        else if let disabledBackgroundColor = backgroundColorsForStates[UIControl.State.normal.rawValue] {
            backgroundColor = disabledBackgroundColor
        }
        else {
            backgroundColor = nil
        }
    }
    
    private func updateTitleText() {
        titleLabel.text = titleForCurrentState()
    }
    
    private func titleForCurrentState() -> String {
        if state.contains(.disabled), let disabledTitle = titlesForStates[UIControl.State.disabled.rawValue] {
            return disabledTitle
        }
        else {
            if gestureRecognizer.state == .ended, let endedTitle = titlesForEvents[UIControl.Event.primaryActionTriggered.rawValue] {
                return endedTitle
            }
            else if gestureRecognizer.isTestingLongPress, let longPressTitle = titlesForEvents[UIControl.Event.valueChanged.rawValue] {
                return longPressTitle
            }
            else {
                return titlesForStates[UIControl.State.normal.rawValue] ?? ""
            }
        }
    }
    
    private func touchedDown() {
        transformButtonSizeAnimated(transform: touchDownTransform, duration: touchDownDuration)
    }
    
    private func touchedUp() {
        transformButtonSizeAnimated(transform: .identity, duration: touchUpDuration)
    }

    private func transformButtonSizeAnimated(transform: CGAffineTransform, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = transform
        }
    }
    
}

extension LongPressButton : PressGestureRecognizerDelegate {
    
    func gestureRecognizerDidRecognizeMinimumPressDuration(_ recognizer: PressGestureRecognizer) {
        sendActions(for: .valueChanged)
        progressView.setProgress(1, duration: recognizer.requiredPressDuration, delay: 0, animated: true)
        updateTitleText()
    }
    
}


