//
//  ProgressIndicator.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/05.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

protocol ProgressIndicatorDelegate: class {
    func didChangeIndicatorPosition(_ position: Double)
}

class ProgressIndicator: UIView {

    weak var delegate: ProgressIndicatorDelegate?

    override var tintColor: UIColor! {
        didSet { backgroundColor = tintColor }
    }

    override var frame: CGRect {
        didSet { layer.cornerRadius = frame.width / 2 }
    }

    /// A progress indicator's current rate.
    var rate: Double {
        get { privateRate }
    }
    private var privateRate: Double = 0.0

    var position: CGFloat {
        get {
            (endIndicator.center.x - startIndicator.center.x) * CGFloat(privateRate) + startIndicator.center.x
        }
    }
    private var previousNotifiedRate: Double = -1.0

    private unowned let startIndicator: StartEndIndicator
    private unowned let endIndicator: StartEndIndicator

    // MARK: - Initializer & setup methods
    init(startIndicator: StartEndIndicator, endIndicator: StartEndIndicator) {
        self.startIndicator = startIndicator
        self.endIndicator = endIndicator

        super.init(frame: .zero)
        self.setup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override private init(frame: CGRect) {
        fatalError("init(frame:) is not supported. Use init(startOrEnd:frame:) instead.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not supported. Use init(startOrEnd:frame:) instead.")
    }

    private func setup(){
        backgroundColor = tintColor
        clipsToBounds = true

        layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        frame = CGRect(origin: .zero, size: CGSize(width: kProgressIndicatorWidth, height: 0))

        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 0.5
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let startPoint = convert(point, to: startIndicator)
        let endPoint = convert(point, to: endIndicator)

        let frame = CGRect(x: min(-15, -self.frame.size.width / 2),
                           y: 0,
                           width: max(30, self.frame.size.width * 2),
                           height: self.frame.size.height)

        // prefer start / end indicators
        if frame.contains(point)
            && startIndicator.hitTest(startPoint, with: event) == nil
            && endIndicator.hitTest(endPoint, with: event) == nil {
            return self
        }else{
            return nil
        }
    }

    // MARK: - APIs
    func set(position: CGFloat, animated: Bool, needsNotify: Bool) {
        let x = position.clipped(startIndicator.center.x, endIndicator.center.x)
        privateRate = Double((x - startIndicator.center.x) / (endIndicator.center.x - startIndicator.center.x))

        setCenter(CGPoint(x: x, y: 0), animated: animated, needsNotify: needsNotify)
    }

    func set(rate: Double, animated: Bool, needsNotify: Bool) {
        privateRate = rate.clipped(0, 1)

        setCenter(CGPoint(x: position, y: 0), animated: animated, needsNotify: needsNotify)
    }

    func updateCurrentPosition() {
        set(position: center.x, animated: false, needsNotify: true)
    }

    // MARK: private methods
    private func setCenter(_ newCenter: CGPoint, animated: Bool, needsNotify: Bool) {
        let action = { self.center = newCenter }

        if animated {
            UIView.animate(withDuration: 0.2, animations: action)
        } else {
            action()
        }

        // Notify the event even if the position is changed
        // by dragging start / end indicator. Therefore, below code is commented out.
        if needsNotify /* && !rate.isEqual(to: previousNotifiedRate, places: 4) */ {
            // Notify the current indicator position to delegate object.
            delegate?.didChangeIndicatorPosition(rate)
        }
        previousNotifiedRate = rate
    }
}
