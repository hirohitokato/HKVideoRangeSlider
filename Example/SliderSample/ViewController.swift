//
//  ViewController.swift
//  SliderSample
//
//  Created by Hirohito Kato on 2020/04/30.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import AVFoundation
import UIKit
import HKVideoRangeSlider

class ViewController: UIViewController {

    @IBOutlet weak var videoRangeSlider: HKVideoRangeSlider!

    @IBOutlet weak var track0MinLabel: UILabel!
    @IBOutlet weak var track1MinLabel: UILabel!
    @IBOutlet weak var track2MinLabel: UILabel!
    @IBOutlet weak var track0MaxLabel: UILabel!
    @IBOutlet weak var track1MaxLabel: UILabel!
    @IBOutlet weak var track2MaxLabel: UILabel!

    @IBOutlet weak var positionIndicatorSlider: UISlider!

    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        videoRangeSlider.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        videoRangeSlider.delegate = self
        videoRangeSlider.tintColor = .systemBlue
        videoRangeSlider.layer.cornerRadius = 11

        view.backgroundColor = .clear
        setGradientBackground(colorTop: .orange, colorBottom: .yellow)
    }

    override func viewDidLayoutSubviews() {
        // You don't need to call videoRangeSlider.updateThumbnails(),
        // because HKVideoRangeSlider implements its layoutSubviews().

        setGradientBackground(colorTop: .yellow, colorBottom: .orange)
    }

    private func setGradientBackground(colorTop: UIColor, colorBottom: UIColor){
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: IBActions

    @IBAction func positionIndicatorSliderValueChanged(_ sender: UISlider) {
        videoRangeSlider.setProgress(rate: Double(sender.value),
                                     animated: false)
    }

    @IBAction func setAssets(_ sender: Any) {
        // In actual situation, you can use different videos for each track.
        let url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo", ofType:"mp4")!)
        let url2 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo", ofType:"mp4")!)
        let url3 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo", ofType:"mp4")!)

        let assets = [
            HKAssetInputData(asset: AVURLAsset(url: url1)),
            HKAssetInputData(asset: AVURLAsset(url: url2)),
            HKAssetInputData(asset: AVURLAsset(url: url3), startTime: 20, duration: 18) // can set initial range.
        ]
        videoRangeSlider.setAssetData(assets)
    }

    @IBAction func removeAssets(_ sender: Any) {
        let assets = [HKAssetInputData]()
        videoRangeSlider.setAssetData(assets)
    }
}

// MARK: - HKVideoRangeSliderDelegate

extension ViewController: HKVideoRangeSliderDelegate {
    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange]) {

        guard ranges.count == 3 else {
            return
        }

        track0MinLabel.text = formattedString(ranges[0].start)
        track0MaxLabel.text = formattedString(ranges[0].start + ranges[0].duration)
        track1MinLabel.text = formattedString(ranges[1].start)
        track1MaxLabel.text = formattedString(ranges[1].start + ranges[1].duration)
        track2MinLabel.text = formattedString(ranges[2].start)
        track2MaxLabel.text = formattedString(ranges[2].start + ranges[2].duration)
    }

    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider,
                                    positions: [HKVideoPosition],
                                    rate: Double) {

        guard positions.count == 3 else {
            return
        }

        track0MinLabel.text = formattedString(positions[0].time)
        track0MaxLabel.text = "---"
        track1MinLabel.text = formattedString(positions[1].time)
        track1MaxLabel.text = "---"
        track2MinLabel.text = formattedString(positions[2].time)
        track2MaxLabel.text = "---"

        positionIndicatorSlider.value = Float(rate)
    }

    private func formattedString(_ seconds: Double) -> String {
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let dsec = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%02d:%02d.%d", min, sec, dsec)
    }
}
