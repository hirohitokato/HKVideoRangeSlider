//
//  StartEndBorder.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/04.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

class StartEndBorder: UIView {

    enum Role {
        case top, bottom
    }

    override var tintColor: UIColor! {
        didSet { backgroundColor = tintColor }
    }

    private let role: Role

    private unowned let startIndicator: StartEndIndicator
    private unowned let endIndicator: StartEndIndicator

    // MARK: - Initializer & setup methods
    init(topOrBottom: Role,
         startIndicator: StartEndIndicator,
         endIndicator: StartEndIndicator) {

        role = topOrBottom
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
    }

    // MARK: - APIs
    func redraw() {
        let x: CGFloat = startIndicator.frame.midX
        let y: CGFloat = (role == .top) ? 0.0 : startIndicator.frame.height - kRangeIndicatorBorderHeight
        let width = endIndicator.frame.midX - startIndicator.frame.midX
        let height = kRangeIndicatorBorderHeight

        frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
