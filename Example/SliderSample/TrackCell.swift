//
//  TrackCell.swift
//  SliderSample
//
//  Created by Hirohito Kato on 2020/05/27.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit
import HKVideoRangeSlider

class TrackCell: UITableViewCell {

    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var rangeLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!

    func setTrackNo(_ trackNo: Int) {
        trackNameLabel.text = "Track #\(trackNo)"
    }

    func setRange(_ range: HKVideoRange) {
        rangeLabel.text = formattedRangeString(range)
    }

    func setProgress(_ progress: HKVideoPosition) {
        progressLabel.text = formattedString(progress.time)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func formattedRangeString(_ range: HKVideoRange) -> String {
        return "\(formattedString(range.start)) 〜 \(formattedString(range.start + range.duration))"
    }

    private func formattedString(_ seconds: Double) -> String {
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let dsec = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%02d:%02d.%d", min, sec, dsec)
    }
}
