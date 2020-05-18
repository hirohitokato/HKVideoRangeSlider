//
//  TrackViewsExtensions.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/03.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

extension Array where Element == TrackView {

    /// returns the track view laid on the leftmost side.
    func leftMostTrack(in view: UIView) -> TrackView? {
        return self.min { (t1, t2) -> Bool in
            let l1 = t1.convert(t1.contentView!.frame, to: view).minX
            let l2 = t2.convert(t2.contentView!.frame, to: view).minX
            return l1 < l2
        }
    }
    
    /// returns the track view laid on the rightmost side.
    func rightMostTrack(in view: UIView) -> TrackView? {
        return self.max { (t1, t2) -> Bool in
            let l1 = t1.convert(t1.contentView!.frame, to: view).maxX
            let l2 = t2.convert(t2.contentView!.frame, to: view).maxX
            return l1 < l2
        }
    }

    /// returns minX value of the leftmost track's content view frame.
    func leftMostPosition(in view: UIView) -> CGFloat {
        return self.map {
            $0.convert($0.contentView!.frame, to: view).minX
        }.min()!
    }

    /// returns maxX value of the rightmost track's content view frame.
    func rightMostPosition(in view: UIView) -> CGFloat {
        return self.map {
            $0.convert($0.contentView!.frame, to: view).maxX
        }.max()!
    }

    /// Update all contentOffset of tracks with new value
    /// - Parameters:
    ///   - ratio: 0.0-1.0 value between min/max offsets.
    ///   - animated: Specify true to animate the change in value;
    ///     otherwise, specify false to update the tracks’ appearance immediately.
    ///     Animations are performed asynchronously and do not block the calling thread.
    func setAllContentOffsets(ratio: Float, animated: Bool) {
        let value = CGFloat(ratio)
        self.forEach {
            let offset = CGPoint(x: ($0.maxOffset.x - $0.minOffset.x) * value + $0.minOffset.x, y: 0)
            $0.setContentOffset(offset, animated: animated)
        }
    }


    /// Create all tracks' video range data and return the array contains them.
    /// - Returns: the array contains HKVideoRange data.
    func createVideoRanges() -> [HKVideoRange] {

        // Normalize a duration in order to hide the calculation error.
        let duration = self.map { $0.endTime - $0.startTime }.min()!

        let ranges = self.map { trackView -> HKVideoRange in
            HKVideoRange(trackID: trackView.trackID,
                         asset: trackView.asset,
                         start: trackView.startTime,
                         duration: duration)
        }
        return ranges
    }

    /// Create all tracks' video position data, indicated by x. And return the array contains them.
    ///
    /// HKVideoRangeSlider coordinate space is the space of x.
    func createVideoPositions(atX x: CGFloat, inParentView: UIView) -> [HKVideoPosition] {
        let positions = self.map { trackView -> HKVideoPosition in
            let xInTrackView = inParentView.convert(x, to: trackView)
            return HKVideoPosition(trackID: trackView.trackID,
                                   asset: trackView.asset,
                                   time: trackView.assetTime(atX: xInTrackView) ?? -1.0)
        }
        return positions
    }
}
