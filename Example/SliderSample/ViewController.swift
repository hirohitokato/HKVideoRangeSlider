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

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var positionIndicatorSlider: UISlider!

    let gradientLayer = CAGradientLayer()

    private var videoTracks = [HKAssetInputData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        videoRangeSlider.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        videoRangeSlider.delegate = self
        videoRangeSlider.tintColor = .systemBlue
        videoRangeSlider.layer.cornerRadius = 11

        view.backgroundColor = .clear
        setGradientBackground(colorTop: .orange, colorBottom: .yellow)

        let nib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
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

        // Since HKVideoRangeSlider doesn't call didChangeIndicatorPosition(rangeSlider:positions:rate:)
        // delegate method if you set the progress manually,
        // you should update manually the labels.
        for (i, position) in videoRangeSlider.currentProgresses.enumerated() {
            updatePositionCellLabel(at: i, with: position)
        }
    }

    @IBAction func addAsset(_ sender: Any) {
        // In actual situation, you can use different videos for each track.
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo", ofType:"mp4")!)

        // If you want to set asset with an initial range,
        // use `HKAssetInputData(asset:startTime:duration:)` method instead.
        videoTracks.append(HKAssetInputData(asset: AVURLAsset(url: url)))

        // Rebuild tracks, and the table.
        videoRangeSlider.setAssetData(videoTracks)
        tableView.reloadData()
    }

    @IBAction func removeAssets(_ sender: Any) {
        videoTracks.removeAll()
        videoRangeSlider.setAssetData([])
        tableView.reloadData()
    }

    private func updateRangeCellLabel(at i: Int, with range: HKVideoRange) {
        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TrackCell {
            cell.setRange(range)
        }
    }

    private func updatePositionCellLabel(at i: Int, with position: HKVideoPosition) {
        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TrackCell {
            cell.setProgress(position)
        }
    }
}

// MARK: - HKVideoRangeSliderDelegate

extension ViewController: HKVideoRangeSliderDelegate {
    func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange]) {

        for (i, range) in ranges.enumerated() {
            updateRangeCellLabel(at: i, with: range)
        }
    }

    func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider,
                                    positions: [HKVideoPosition],
                                    rate: Double) {

        for (i, position) in positions.enumerated() {
            updatePositionCellLabel(at: i, with: position)
        }
        positionIndicatorSlider.value = Float(rate)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoTracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { fatalError() }
        cell.backgroundColor = .clear

        cell.setTrackNo(indexPath.row)
        cell.setRange(videoRangeSlider.videoRanges[indexPath.row])
        cell.setProgress(videoRangeSlider.currentProgresses[indexPath.row])

        return cell
    }
}

extension ViewController: UITableViewDelegate {
}
