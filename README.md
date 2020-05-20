# 🎞 HKVideoRangeSlider

<p align="left">
    <a href="https://cocoapods.org/pods/HKVideoRangeSlider">
        <img src="https://img.shields.io/cocoapods/v/HKVideoRangeSlider.svg?style=flat"
             alt="Pods Version">
    </a>
    <a href="http://cocoapods.org/pods/HKVideoRangeSlider/">
        <img src="https://img.shields.io/cocoapods/p/HKVideoRangeSlider.svg?style=flat"
             alt="Platforms">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat"
             alt="Carthage Compatible">
    </a>
</p>

---
iOS video range slider for trimming it, .

## Features

- [x] Scrollable thumbnails
- [x] Support **multiple** video tracks
- [x] Includes position indicator
- [x] Customize appearances

## Requirements

HKVideoRangeSlider is written in Swift 5. Compatible with iOS 11.0+

## Installation

### CocoaPods

HKVideoRangeSlider is available through [CocoaPods](https://cocoapods.org/). To install it, simply add the following line to your Podfile:

```rb
pod 'HKVideoRangeSlider'
```

### Carthage

For [Carthage](https://github.com/Carthage/Carthage), add the following to your Cartfile: 

```
github "hirohitokato/HKVideoRangeSlider"
```

## Getting Started

```swift
// Prepare AVAsset objects to show.
let url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo1", ofType:"mp4")!)
let url2 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo2", ofType:"mp4")!)
let url3 = URL(fileURLWithPath: Bundle.main.path(forResource: "SampleVideo3", ofType:"mp4")!)

let assets = [
    HKAssetInputData(asset: AVURLAsset(url: url1)),
    HKAssetInputData(asset: AVURLAsset(url: url2)),
    HKAssetInputData(asset: AVURLAsset(url: url3), startTime: 20, duration: 18) // you can set initial range.
]
// Set & display video range view
videoRangeSlider.setAssetData(assets)
```

## Usage

## Author

Kato Hirohito, [hkato193](https://twitter.com/hkato193)

## License

HKVideoRangeSlider is available under the MIT license. See the LICENSE file for more info.
