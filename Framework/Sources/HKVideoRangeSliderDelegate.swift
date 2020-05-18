//
//  HKVideoRangeSliderDelegate.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/05.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit
import Photos

/// Represents the current result of time range data for the track,
/// which is decided by `HKVideoRangeSlider` object.
public struct HKVideoRange {
    /// An ordered number of this data. The origin is 0.
    ///
    /// The index of topmost track in the view is 0. The next track is 1. ...
    /// The order number is the same with that of `HKVideoRangeInput` array.
    public let trackID: Int

    /// The asset object for this value.
    public let asset: AVAsset

    /// The start time for the asset
    public var start: Double

    /// The duration of the range from the start time.
    public var duration: Double
}

public struct HKVideoPosition {
    /// A unique identifier for this data.
    ///
    /// The index of topmost track in the view is 0. The next track is 1. ...
    public let trackID: Int

    /// The asset for this data.
    public let asset: AVAsset

    /// The time for the asset, currently indicated by progress indicator object.
    public let time: Double
}

/// The methods declared by the HKVideoRangeSliderDelegate protocol allow
/// the adopting delegate to respond to messages from the HKVideoRangeSlider class
/// and thus respond to, and in some affect, operations such as changing range,
/// and current indicator moving.
public protocol HKVideoRangeSliderDelegate: class {

    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange])

    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double)
}

/// Default implementations for the delegate protocol.
public extension HKVideoRangeSliderDelegate {
    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange]) {}
    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double) {}
}
