//
//  MainSlider.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/03.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

class MainSlider: UISlider {

    /// Indicates the slider is scrubbing or not.
    var isScrubbing = false

    // MARK: - Initializer & setup methods
    init() {
        super.init(frame: .zero)

        self.setup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private override init(frame: CGRect) {
        fatalError("init(frame:) is not supported. Use init() instead.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not supported. Use init() instead.")
    }

    private func setup(){
        let bundle = Bundle(for: StartEndIndicator.self)
        let image = UIImage(named: "mainSliderThumb", in: bundle, compatibleWith: nil)
        setThumbImage(image, for: .normal)

        setMinimumTrackImage(UIImage(), for: .normal)
        setMaximumTrackImage(UIImage(), for: .normal)

        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(touchUp(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchUp(_:)), for: .touchUpOutside)
        addTarget(self, action: #selector(touchUp(_:)), for: .touchCancel)
    }

    // MARK: - APIs
    func addValueChangedEventTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .valueChanged)
    }

    @objc func touchDown(_ sender: UISlider) {
        // Ignore scrollview events to prevent updating slider properties
        isScrubbing = true
    }

    @objc func touchUp(_ sender: UISlider) {
        // Activate scrollview events to prevent updating slider properties
        isScrubbing = false
    }
}
