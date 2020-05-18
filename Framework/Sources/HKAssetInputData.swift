//
//  HKAssetInputData.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/06.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import Foundation
import AVFoundation

/// Defines a structure that represents an input data for `HKVideoRangeSlider`.
///
/// You use an array of this structure with `HKVideoRangeSlider` object.
public struct HKAssetInputData {
    /// The asset object for this value.
    public let asset: AVAsset

    /// The initial start time for the asset. if the value is nil,
    /// `HKVideoRangeSlider` object uses 0.0 as the start time.
    public let start: Double?

    /// The duration of the range from the start time. if the value is nil,
    /// `HKVideoRangeSlider` object uses the asset duration as the duration.
    public let duration: Double?

    /// Makes a `HKAssetData` from an asset, `Double` number of start time, and a duration.
    ///
    /// The units of `Double` values are in seconds.
    /// `startTime` and `duration` parameters are optional.
    public init(asset: AVAsset, startTime: Double? = nil, duration: Double? = nil) {
        self.asset = asset
        self.start = startTime
        self.duration = duration
    }

    func convertToVideoRange(asTrackID trackId: Int) -> HKVideoRange {
        let videoRange = HKVideoRange(trackID: trackId,
                                      asset: asset,
                                      start: start ?? 0.0,
                                      duration: duration ?? asset.duration.seconds)
        return videoRange
    }
}
