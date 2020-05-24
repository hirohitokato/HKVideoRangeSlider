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
    /// The topmost track in the view is 0. The next track is 1, 2, …
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
    /// An ordered number of this data. The origin is 0.
    ///
    /// The topmost track in the view is 0. The next track is 1, 2, …
    /// The order number is the same with that of `HKVideoRangeInput` array.
    public let trackID: Int

    /// The asset for this data.
    public let asset: AVAsset

    /// The time for the asset, currently indicated by the progress indicator object.
    public let time: Double
}

/// The methods declared by the HKVideoRangeSliderDelegate protocol allow
/// the adopting delegate to respond to messages from the HKVideoRangeSlider class
/// and thus respond to, and in some affect, operations such as changing range,
/// and current indicator moving.
public protocol HKVideoRangeSliderDelegate: class {

    /// Tells the delegate when the user scrolls one of the tracks, or drags
    /// the start or end slider. This is optional.
    ///
    /// The delegate typically implements this method to obtain the change in range data.
    ///
    /// - Parameters:
    ///   - rangeSlider: The slider object in which the event occurred.
    ///   - ranges: The array of current range status of all tracks.
    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange])

    /// Tells the delegate when the user drags the progress indicator. This is optional.
    ///
    /// - Parameters:
    ///   - rangeSlider: The slider object in which the event occurred.
    ///   - positions: The array of current positions of all tracks, indicated by the progress indicator.
    ///   - rate: 0.0-1.0 value as the position of the progress indicator.
    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double)
}

/// Default implementations for the delegate protocol.
public extension HKVideoRangeSliderDelegate {
    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange]) {}
    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double) {}
}
