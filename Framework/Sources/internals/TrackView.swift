//
//  TrackView.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/01.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit
import AVFoundation

/// The tag used so that the parent can get each track
let kContentViewTag: Int = 100

class TrackView: UIScrollView {

    // MARK: - Properties
    let trackID: Int

    let asset: AVAsset

    // left/right edge that represent the scrollable range.
    var minOffset: CGPoint = .zero
    var maxOffset: CGPoint = .zero

    var startTime: Double = 0.0
    var endTime: Double = 0.0

    /// The view for displaying thumbnails
    var contentView: UIView? {
        get {
            viewWithTag(kContentViewTag)
        }
        set {
            if let view = newValue {
                view.clipsToBounds = true
                view.tag = kContentViewTag
                addSubview(view)
            } else {
                contentView?.removeFromSuperview()
            }
        }
    }

    var assetDuration: Double {
        asset.duration.seconds
    }

    var isManuallyDragging = false

    /// The asset for this track.
    private var videoSize = CGSize.zero
    private var imageGenerator: AVAssetImageGenerator!

    // MARK: - Initializer & setup methods
    init(trackID: Int, asset: AVAsset) {
        self.trackID = trackID
        self.asset = asset

        super.init(frame: .zero)

        self.imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        self.setup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private override init(frame: CGRect) {
        fatalError("init(frame:) is not supported. Use init(trackID:asset:) instead.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not supported. Use init(trackID:asset:) instead.")
    }

    private func setup(){
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            fatalError("BUG: asset must have at least one video track.")
        }

        startTime = 0.0
        endTime = assetDuration

        // Consider video dimension
        let s = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        videoSize = CGSize(width: abs(s.width), height: abs(s.height))

        bounces = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    // MARK: - APIs
    func buildThumbnails() {
        guard let contentView = contentView else {
            fatalError("BUG: You must set contentView before callilng buildThumbnails().")
        }

        let aspectRatio = videoSize.width / videoSize.height

        let estimatedThumbnailSize = CGSize(width: contentView.bounds.height * aspectRatio,
                                            height: contentView.bounds.height)
        let estimatedThumbnailCount = Int((contentView.bounds.width / estimatedThumbnailSize.width).rounded(.up))

        // limit the maximum number of thumbnail images
        // for displaying performance.
        let thumbnailCount: Int
        switch estimatedThumbnailCount {
        case Int.min ..< kMinThumbnailCount:
            thumbnailCount = kMinThumbnailCount
        case kMaxThumbnailCount ... Int.max:
            let a = (contentView.bounds.width / CGFloat(kMaxThumbnailCount)) / contentView.bounds.height
            if a > 2 {
                thumbnailCount = Int((contentView.bounds.width / contentView.bounds.height).rounded(.up))
            } else {
                thumbnailCount = kMaxThumbnailCount
            }
        default:
            thumbnailCount = estimatedThumbnailCount
        }

        // Calculate a thumbnail size based on the count.
        let thumbnailSize = CGSize(width: contentView.bounds.width / CGFloat(thumbnailCount),
                                   height: contentView.bounds.height)

        let thumbnails = (0 ..< thumbnailCount).map { i -> ThumbnailView in
            return createThumbnailView(atIndex: i, size: thumbnailSize)
        }

        thumbnails.forEach{ thumbnail in
            contentView.addSubview(thumbnail)
        }

        // IMPORTANT:
        // AVAssetImageGenerator consumes huge memory(over GB!)
        // when UIImage keeps the obtained CGImage object directly.
        // To avoid the problem, create UIImage object by not the obtained
        // object but **the copy of it**.
        let scale = UIScreen.main.scale * 2
        let maxSize = CGSize(width: thumbnailSize.width * scale,
                             height: thumbnailSize.height * scale)
        imageGenerator.maximumSize = maxSize

        let times = thumbnails.map { NSValue(time: $0.time) }
        imageGenerator.generateCGImagesAsynchronously(forTimes: times)
        { (time, cgImage, actualTime, result, error) in
            DispatchQueue.main.async {
                guard result == .succeeded, let image = cgImage else { return }
                guard let imageView = thumbnails.first(where: { $0.time == time}) else { return }

                imageView.image = UIImage(cgImage: image.copy()!)
            }
        }
    }

    func assetTime(atX x: CGFloat) -> Double? {
        guard let contentView = contentView else {
            fatalError("BUG: You must set contentView before callilng assetTime(atX:).")
        }

        let positioninContentView = contentView.convert(x, from: self)

        let ratio = Double(positioninContentView / contentView.frame.width).rounded(toPlaces: 3)

        if ratio < 0.0 || ratio > 1.0 {
            return nil
        }

        return assetDuration * ratio
    }

    func getContentOffset(at seconds: Double) -> CGPoint {
        guard let contentView = contentView else {
            fatalError("BUG: You must set contentView before callilng getContentOffset(at:).")
        }
        return CGPoint(x: contentViewPosition(at: seconds).x + contentView.frame.x,
                       y:0)
    }

    func contentViewPosition(at seconds: Double) -> CGPoint {
        guard let contentView = contentView else {
            fatalError("BUG: You must set contentView before callilng contentViewPosition(at:).")
        }

        let ratio = seconds / assetDuration
        return CGPoint(x: contentView.frame.width * CGFloat(ratio), y: 0)
    }

    var startTimePosition: CGFloat {
        contentViewPosition(at: startTime).x
    }

    var endTimePosition: CGFloat {
        contentViewPosition(at: endTime).x
    }

    func updateStartEndTime(startPosition start: CGFloat, endPosition end: CGFloat) {
        if let t = assetTime(atX: start) {
            startTime = t
        }
        if let t = assetTime(atX: end) {
            endTime = t
        }
    }

    // MARK: Private methods
    private func createThumbnailView(atIndex index: Int, size: CGSize) -> ThumbnailView {
        guard let contentView = contentView else {
            fatalError("BUG: You must set contentView before callilng buildThumbnails().")
        }

        let rect = CGRect(x: size.width * CGFloat(index) , y: 0,
                          width: size.width, height: size.height)
        let imageView = ThumbnailView(frame: rect)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        let rate = rect.width / contentView.bounds.width * CGFloat(index)
        let imageTime = CMTime(seconds: assetDuration * Double(rate), preferredTimescale: 30)
        imageView.time = imageTime

        return imageView
    }
}

class ThumbnailView: UIImageView {
    var time = CMTime.zero
}
