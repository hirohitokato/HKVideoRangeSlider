//
//  StartEndIndicator.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/03.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

class StartEndIndicator: UIView {

    enum IndicatorRole {
        case start, end
    }

    let role: IndicatorRole

    var position: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    override var frame: CGRect {
        didSet {
            imageView.frame = CGRect(origin: .zero, size: frame.size)
        }
    }

    override var tintColor: UIColor! {
        didSet { imageView.tintColor = tintColor }
    }

    var dimpleColor: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }

    var image: UIImage? {
        get { imageView.image }
        set { setImage(image: newValue) }
    }

    private var imageView = UIImageView()

    // MARK: - Initializer & setup methods
    init(startOrEnd: IndicatorRole, frame: CGRect) {
        role = startOrEnd

        super.init(frame: frame)
        self.setup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private override init(frame: CGRect) {
        fatalError("init(frame:) is not supported. Use init(startOrEnd:frame:) instead.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not supported. Use init(startOrEnd:frame:) instead.")
    }

    private func setup(){
        dimpleColor = .white
        clipsToBounds = true
        layer.cornerRadius = 4

        addSubview(imageView)

        setImage(image: nil)
    }

    // MARK: - APIs
    private func setImage(image: UIImage?) {
        guard let image = image else {
            // if nil is set, use default image.
            let bundle = Bundle(for: StartEndIndicator.self)
            setImage(image: UIImage(named: "startEndIndicator",
                                    in: bundle, compatibleWith: nil)!)
            return
        }

        imageView.image = image
        imageView.frame = bounds

        // set anchor point again.
        switch role {
        case .start:
            layer.anchorPoint = CGPoint(x: 1, y: 0)
        case .end:
            layer.anchorPoint = CGPoint(x: 0, y: 0)
        }
    }

    // MARK: others
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let x: CGFloat
        switch role {
        case .start:
            x = -self.frame.size.width
        case .end:
            x = 0
        }

        let frame = CGRect(x: x, y: 0,
                           width: self.frame.size.width * 2,
                           height: self.frame.size.height)
        if frame.contains(point){
            return self
        }else{
            return nil
        }
    }

}
