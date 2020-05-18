//
//  HKVideoRangeSlider.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/04/30.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

let kMainSliderAreaHeight: CGFloat = 35
let kMainSliderHeight: CGFloat = 30
let kTrackViweScrollMargin: CGFloat = 75
let kRangeIndicatorWidth: CGFloat = 20
let kRangeIndicatorBorderHeight: CGFloat = 4
let kProgressIndicatorWidth: CGFloat = 4

public class HKVideoRangeSlider: UIView {

    // MARK: 📍 Public properties

    /// An array of video assets to handle with.
    private (set) public var videoRanges = [HKVideoRange]()

    /// Current values that the progress indicator points in each track.
    private (set) public var currentProgresses = [HKVideoPosition]()

    /// A minimun space (in seconds) between the Start indicator and End indicator
    public var maxDuration: Double = 999.0

    /// A minimun space (in seconds) between the Start indicator and End indicator
    public var minDuration: Double = 2

    /// Current main slider value.
    ///
    /// Use this property when you want to update main slider value manually.
    var mainSliderValue: Float {
        get { mainSlider.value }
        set { setMainSliderValue(newValue) }
    }

    /// The first nondefault tint color value in the view’s hierarchy,
    /// ascending from and starting with the view itself.
    public override var tintColor: UIColor! {
        didSet { internalSetTintColor(tintColor) }
    }

    // TODO: startEndSliderのtintColor
    // TODO: startEndSliderのイメージ
    // TODO: mainSliderのThumbイメージ
    // TODO: mainSliderのtintColor
    // TODO: progressIndicatorのtintColor
    // TODO: progressIndicatorのイメージ

    /// The range slider's delegate.
    ///
    /// The delegate must conform to the HKVideoRangeSliderDelegate protocol.
    /// The `HKVideoRangeSlider` class, which does not retain the delegate,
    /// invokes each protocol method the delegate implements.
    /// Setting the delegate to nil causes these notifications to be disconnected.
    public weak var delegate: HKVideoRangeSliderDelegate?

    // MARK: Private properties

    /// An slider control to scroll whole tracks and range UI.
    private var mainSlider: MainSlider!
    /// An array of scrollviews for each track. The index is linked to assets' index.
    private var trackViews = [TrackView]()

    /// An indicator control which shows start time, is draggable.
    private var startIndicator: StartEndIndicator!
    /// An indicator control which shows end time, is draggable.
    private var endIndicator: StartEndIndicator!
    /// Top border view between start & end indicators
    private var topBorder: StartEndBorder!
    /// Bottom border view between start & end indicators
    private var bottomBorder: StartEndBorder!

    /// A Progress indicator control of tracks.
    private var progressIndicator: ProgressIndicator!

    /// Flag to check frame size with previous/current size when layoutSubviews() is called.
    /// To prevent duplicate layoutSubviews() calling.
    private var previousFrame = CGRect.zero

    // MARK: Initializers
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension HKVideoRangeSlider {

    // MARK: - 📍 Public APIs

    /// Set an array of asset & initial range data.
    ///
    /// `HKVideoRangeSlider` object rebuild its views after this method is called.
    ///
    /// - Attention: If you specify the different duration in each element,
    ///              the shortest value is used.
    public func setAssetData(_ inputData: [HKAssetInputData]) {
        videoRanges = inputData.enumerated().map {
            $1.convertToVideoRange(asTrackID: $0)
        }
        internalUpdateThumbnails()
    }

    /// Reconstruct thumbnails.
    ///
    /// If you need to update the thumbnails of the video,
    /// you can call this method manually.
    ///
    /// (By default it's called every time the view changes its bounds)
    public func updateThumbnails() {
        internalUpdateThumbnails()
    }

    /// Sets the current rate of progress indicator, allowing you to animate the change visually.
    ///
    /// - Parameter rate: The new rate(0.0-1.0) to assign to the value property
    /// - Parameter animated:
    ///  A Boolean value that determines whether the change is animated.
    ///  If true, the change is animated at a constant velocity.
    ///  If false, the change takes place immediately.
    public func setProgress(rate: Double, animated: Bool) {
        internalSetProgress(rate: rate, animated: animated)
    }
}

// MARK: - Internal & private methods/properties

extension HKVideoRangeSlider {

    // MARK: Setup

    private func setup(){
        isUserInteractionEnabled = true
        isOpaque = false
        clipsToBounds = true

        // main slider
        mainSlider = MainSlider()
        mainSlider.addValueChangedEventTarget(self, action: #selector(mainSliderValueChanged(_:)))

        // start & end indicators
        startIndicator = StartEndIndicator(startOrEnd: .start, frame: .zero)
        endIndicator = StartEndIndicator(startOrEnd: .end, frame: .zero)

        let startDragging = UIPanGestureRecognizer(target:self,
                                                   action: #selector(draggedStartIndicator(recognizer:)))
        let endDragging = UIPanGestureRecognizer(target:self,
                                                 action: #selector(draggedEndIndicator(recognizer:)))
        startIndicator.addGestureRecognizer(startDragging)
        endIndicator.addGestureRecognizer(endDragging)

        topBorder = StartEndBorder(topOrBottom: .top,
                                   startIndicator: startIndicator,
                                   endIndicator: endIndicator)
        bottomBorder = StartEndBorder(topOrBottom: .bottom,
                                      startIndicator: startIndicator,
                                      endIndicator: endIndicator)

        // progress indicator
        progressIndicator = ProgressIndicator(startIndicator: startIndicator,
                                              endIndicator: endIndicator)
        progressIndicator.tintColor = .white
        progressIndicator.delegate = self
        let progressDragging = UIPanGestureRecognizer(target: self,
                                                      action: #selector(draggedProgressIndicator(recognizer:)))
        progressIndicator.addGestureRecognizer(progressDragging)

        addSubview(mainSlider)
        addSubview(startIndicator)
        addSubview(endIndicator)
        addSubview(topBorder)
        addSubview(bottomBorder)
        addSubview(progressIndicator)
    }

    private func internalSetTintColor(_ color: UIColor!) {
        guard let color = color else { return }

        mainSlider.tintColor = color
        startIndicator.tintColor = color
        endIndicator.tintColor = color
        topBorder.tintColor = color
        bottomBorder.tintColor = color
    }

    override public func layoutSubviews() {
        guard frame != previousFrame else {
            // The new frame size is equal to previous one. ignore the event.
            return
        }
        previousFrame = frame

        // re-layout all controls inside this view.
        mainSlider.frame = CGRect(x: 0, y: frame.height - kMainSliderHeight,
                                  width: frame.width, height: kMainSliderHeight)

        progressIndicator.frame = CGRect(x: 0, y: 0,
                                         width: kProgressIndicatorWidth,
                                         height: frame.height - kMainSliderAreaHeight + kRangeIndicatorBorderHeight)

        // rebuild track views and coordinate other controls
        internalUpdateThumbnails()
    }
}

extension HKVideoRangeSlider {

    // MARK: Managing contents

    private func internalUpdateThumbnails() {
        guard frame != .zero else {
            return
        }

        // rebuild track views.
        rebuildTrackViews()

        if !videoRanges.isEmpty {
            // relocate indicators
            updateStartEndIndicators()
            updateProgressIndicator()

            mainSlider.isHidden = false
            startIndicator.isHidden = false
            endIndicator.isHidden = false
            topBorder.isHidden = false
            bottomBorder.isHidden = false
            progressIndicator.isHidden = false

            // arrange order of controls.
            bringSubviewToFront(startIndicator)
            bringSubviewToFront(endIndicator)
            bringSubviewToFront(topBorder)
            bringSubviewToFront(bottomBorder)
            bringSubviewToFront(progressIndicator)
        } else {
            mainSlider.isHidden = true
            startIndicator.isHidden = true
            endIndicator.isHidden = true
            topBorder.isHidden = true
            bottomBorder.isHidden = true
            progressIndicator.isHidden = true
        }

        // reposition whole track so that user can see the start indicator.
        if !trackViews.isEmpty {
            let left = trackViews.leftMostPosition(in: self)
            let right = trackViews.rightMostPosition(in: self)
            guard right - left > 0 else { return }

            mainSliderValue = Float((startIndicator.position - left) / (right - left))
        }
    }

    // Re-create all track views.
    private func rebuildTrackViews() {
        trackViews.forEach{ $0.removeFromSuperview() }
        trackViews.removeAll()

        guard !videoRanges.isEmpty else { return }

        let trackCount = videoRanges.count
        let trackHeight = (frame.height - kMainSliderAreaHeight - kRangeIndicatorBorderHeight) / CGFloat(trackCount)

        let assetDurations = videoRanges.map{ $0.asset.duration.seconds }
        let shortestAssetDuration = assetDurations.min()!
        let longestAssetDuration = assetDurations.max()!

        // Change the logic to get each track width, in order to improve UI.
        // Too long track is inconvenience.
        let trackWidths: [CGFloat]
        if shortestAssetDuration * 3 < longestAssetDuration {
            // The size of longest track is the 2x size of frame,
            // and the other track lengths are decided by the ratio of it.
            let longestAssetWidth = 2 * frame.width

            trackWidths = assetDurations
                .map{ CGFloat($0 / longestAssetDuration) * longestAssetWidth }
        } else {
            // The width of shortest track is the 0.75x size of current bounds,
            // and the other track lengths are decided by the ratio of it.
            let shortestAssetWidth = 1.25 * bounds.width

            trackWidths = assetDurations
                .map{ CGFloat($0 / shortestAssetDuration) * shortestAssetWidth }
        }

        let contentViewWidth = 4 * trackWidths.max()!

        let userSpecifiedDuration = videoRanges.compactMap { $0.duration }.min() ?? Double.infinity
        let shortestDuration = min(userSpecifiedDuration, shortestAssetDuration)

        for i in 0..<trackCount {

            let trackView = TrackView(trackID: i, asset: videoRanges[i].asset)
            let trackFrame = CGRect(x: 0, y: (trackHeight * CGFloat(i)) + kRangeIndicatorBorderHeight,
                                    width: frame.width, height: trackHeight - 1)
            trackView.frame = trackFrame
            trackView.delegate = self

            let contentViewFrame = CGRect(x: contentViewWidth/2 - trackWidths[i]/2, y: 0,
                                          width: trackWidths[i], height: trackHeight - 1)
            let contentView = UIView(frame: contentViewFrame)
            trackView.contentView = contentView
            trackView.contentSize = CGSize(width: contentViewWidth,
                                           height: trackHeight - 1)

            trackView.startTime = videoRanges[i].start
            trackView.endTime = videoRanges[i].start + shortestDuration

            trackView.buildThumbnails()
            trackViews.append(trackView)
            addSubview(trackView)

            do /* for debug use */ {
                trackView.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
            }
        }

        trackViews.forEach {
            $0.contentOffset = $0.getContentOffset(at: $0.startTime)
        }
        updateMainSliderRange()
    }
}

public extension HKVideoRangeSlider {

    // MARK: Managing main slider

    private func setMainSliderValue(_ value: Float) {
        mainSlider.isScrubbing = true
        mainSlider.value = value
        mainSliderValueChanged(mainSlider)
        mainSlider.isScrubbing = false
    }

    /// Returns actual main slider value, not clipped 0.0-1.0.
    private var actualMainSliderValue: Float {
        guard let trackView = trackViews.first else {
            fatalError("BUG: updateMainSliderValue() called before ")
        }
        let value = (trackView.contentOffset.x - trackView.minOffset.x)
            / (trackView.maxOffset.x - trackView.minOffset.x)
        return Float(value)
    }

    @objc private func mainSliderValueChanged(_ sender: UISlider) {
        // scroll all track and controls
        trackViews.setAllContentOffsets(ratio: sender.value, animated: false)
        updateStartEndIndicators(onlyMovePosition: true)
        updateProgressIndicator(onlyMovePosition: true)
    }

    private func updateMainSliderRange() {
        // Check the whole scrolling status, and calculate the range for
        // the main slider.
        let leftMostTrack = trackViews.leftMostTrack(in: self)!
        let rightMostTrack = trackViews.rightMostTrack(in: self)!

        trackViews.forEach {
            let leftMostX = leftMostTrack.convert(leftMostTrack.contentView!.frame.x, to: $0)
            $0.minOffset = CGPoint(x: leftMostX - kTrackViweScrollMargin, y: 0)

            let rightX = rightMostTrack.contentView!.frame.x
                + rightMostTrack.contentView!.frame.width
                - self.frame.width
            let rightMostX = rightMostTrack.convert(rightX, to: $0)
            $0.maxOffset = CGPoint(x: rightMostX + kTrackViweScrollMargin, y: 0)
        }
    }
}

extension HKVideoRangeSlider: UIScrollViewDelegate {

    // MARK: Managing track scrollview

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let trackView = scrollView as? TrackView else { return }

        trackView.isManuallyDragging = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let trackView = scrollView as? TrackView else { return }

        handleScroll(trackView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let trackView = scrollView as? TrackView else { return }

        if !decelerate {
            stoppedScrolling(trackView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let trackView = scrollView as? TrackView else { return }

        stoppedScrolling(trackView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // do nothing
    }

    private func stoppedScrolling(_ trackView: TrackView) {
        // split the following procedure, in order to be reset scrollview's isDragging property.
        DispatchQueue.main.async {
            trackView.isManuallyDragging = false

            let value = self.actualMainSliderValue

            // if the main slider position is out of range after scrolling,
            // relocate track views.
            if value < 0.0 || value > 1.0 {
                let newValue = self.actualMainSliderValue.clipped(0, 1)

                self.trackViews.setAllContentOffsets(ratio: newValue, animated: true)
            }
        }
    }

    private func handleScroll(_ trackView: TrackView) {
        guard let contentView = trackView.contentView else { return }

        // Ignore the event during scrubbing the main slider.
        if mainSlider.isScrubbing {
            return
        }

        if !trackViews.contains(where: { $0.isManuallyDragging }) {
            // Only update the indicators' position following to current tracks position
            updateStartEndIndicators()
            updateProgressIndicator()
            return
        }

        let contentViewFrame = trackView.convert(contentView.frame, to: self)

        // Stop scrolling(if needed) to avoid creating a gap between videos.
        let startPoint = startIndicator.position
        let endPoint = endIndicator.position
        if contentViewFrame.minX > startPoint {
            var offset = trackView.contentOffset
            offset.x = contentView.frame.x - startPoint

            trackView.contentOffset = offset
        } else if contentViewFrame.maxX < endPoint {
            var offset = trackView.contentOffset
            offset.x = contentView.frame.x + contentView.frame.width - endPoint

            trackView.contentOffset = offset
        }

        // Update start & end time of the track
        let start = convert(startIndicator.center, to: trackView)
        let end = convert(endIndicator.center, to: trackView)
        trackView.updateStartEndTime(startPosition: start.x, endPosition: end.x)

        // Update main slider's range and its value
        updateMainSliderRange()

        mainSlider.value = actualMainSliderValue

        // Notify current data to delegate object
        videoRanges = trackViews.createVideoRanges()
        delegate?.didChangeRangeData(rangeSlider: self, ranges: videoRanges)
    }
}

extension HKVideoRangeSlider {

    // MARK: Managing start/end indicators

    // Crop Handle Drag Functions
    @objc private func draggedStartIndicator(recognizer: UIPanGestureRecognizer){
        handleStartEndDrag(recognizer: recognizer, with: startIndicator)
    }

    @objc private func draggedEndIndicator(recognizer: UIPanGestureRecognizer){
        handleStartEndDrag(recognizer: recognizer, with: endIndicator)
    }

    private func handleStartEndDrag(recognizer: UIPanGestureRecognizer, with indicator: StartEndIndicator) {
        let translation = recognizer.translation(in: self)
        let newX = indicator.position + translation.x
        recognizer.setTranslation(.zero, in: self)

        // update indicator position and each track's start time, if all values are valid.
        let times = trackViews.compactMap { trackView -> Double? in
            let x = self.convert(newX, to: trackView)
            return trackView.assetTime(atX: x)
        }

        // if some of time is invalid, do nothing and return.
        if times.isEmpty || times.count != trackViews.count {
            return
        }

        // concerns minimum/maximum duration.
        let durationBetweenStartEnd: Double
        switch indicator.role {
        case .start:
            durationBetweenStartEnd = trackViews.first!.endTime - times[0]
        case .end:
            durationBetweenStartEnd = times[0] - trackViews.first!.startTime
        }

        if  durationBetweenStartEnd < minDuration || durationBetweenStartEnd > maxDuration {
            return
        }

        indicator.position = newX
        topBorder.redraw()
        bottomBorder.redraw()

        // update progress indicator position.
        progressIndicator.updateCurrentPosition()

        let tuples = zip(trackViews, times)
        tuples.forEach { (trackView, t) in
            switch indicator.role {
            case .start:
                trackView.startTime = t
            case .end:
                trackView.endTime = t
            }
        }

        // Notify current data to delegate object
        videoRanges = trackViews.createVideoRanges()
        delegate?.didChangeRangeData(rangeSlider: self, ranges: trackViews.createVideoRanges())
    }

    private func updateStartEndIndicators(onlyMovePosition: Bool = false) {
        guard let trackView = trackViews.first else { return }

        let size = CGSize(width: kRangeIndicatorWidth,
                          height: frame.height - kMainSliderAreaHeight + kRangeIndicatorBorderHeight)
        startIndicator.frame.size = size
        endIndicator.frame.size = size

        startIndicator.position = trackView.contentView!.convert(trackView.startTimePosition, to: self)
        endIndicator.position = trackView.contentView!.convert(trackView.endTimePosition, to: self)

        topBorder.redraw()
        bottomBorder.redraw()

        if onlyMovePosition {
            // do nothing.
        } else {
            // Notify current data to delegate object
            videoRanges = trackViews.createVideoRanges()
            delegate?.didChangeRangeData(rangeSlider: self, ranges: trackViews.createVideoRanges())
        }
    }
}

extension HKVideoRangeSlider: ProgressIndicatorDelegate {

    // MARK: Managing Progress Indicator

    // Crop Handle Drag Functions
    @objc private func draggedProgressIndicator(recognizer: UIPanGestureRecognizer){
        handleProgressDrag(recognizer: recognizer, with: startIndicator)
    }

    private func handleProgressDrag(recognizer: UIPanGestureRecognizer, with indicator: StartEndIndicator) {
        let translation = recognizer.translation(in: self)
        let newCenter = CGPoint(x: progressIndicator.center.x + translation.x, y: 0)
        recognizer.setTranslation(.zero, in: self)

        // draggable between start and end indicators
        progressIndicator.set(position: newCenter.x, animated: false)
    }

    private func updateProgressIndicator(onlyMovePosition: Bool = false) {
        guard let trackView = trackViews.first else { return }

        let size = CGSize(width: kProgressIndicatorWidth,
                          height: frame.height - kMainSliderAreaHeight + kRangeIndicatorBorderHeight)

        progressIndicator.frame.size = size

        // calculate new position.
        let newX = (trackView.endTimePosition - trackView.startTimePosition)
            * CGFloat(progressIndicator.rate) + trackView.startTimePosition
        let xInView = trackView.contentView!.convert(newX, to: self)

        if onlyMovePosition {
            // only move the position
            progressIndicator.center.x = xInView
        } else {
            // update the value
            progressIndicator.set(position: xInView, animated: false)
        }
    }

    private func internalSetProgress(rate: Double, animated: Bool) {
        progressIndicator.set(rate: rate, animated: animated)
    }

    func didChangeIndicatorPosition(_ position: Double) {
        let videoPositions = trackViews.createVideoPositions(atX: progressIndicator.position,
                                                             inParentView: self)
        currentProgresses = videoPositions
        delegate?.didChangeIndicatorPosition(rangeSlider: self,
                                             positions: videoPositions,
                                             rate: position)
    }
}
