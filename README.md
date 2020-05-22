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
// Instantiate an object.
// (If you use a storyboard, locate UIView and change the class to HKVideoRangeSlider)
videoRangeSlider = HKVideoRangeSlider(frame: someRect)
view.addSubview(videoRangeSlider)

// Set delegate object to receive events from slider.
videoRangeSlider.delegate = self

// Prepare AVAsset objects to show.
let url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "video1", ofType:"mp4")!)
let url2 = URL(fileURLWithPath: Bundle.main.path(forResource: "video2", ofType:"mp4")!)
let url3 = URL(fileURLWithPath: Bundle.main.path(forResource: "video3", ofType:"mp4")!)

// Construct tracks information by using HKAssetInputData.
let assets = [
    HKAssetInputData(asset: AVURLAsset(url: url1)),
    HKAssetInputData(asset: AVURLAsset(url: url2)),
    HKAssetInputData(asset: AVURLAsset(url: url3), startTime: 20, duration: 18) // you can set initial range.
]

// Set & display video range view
videoRangeSlider.setAssetData(assets)
```

## Usage

### Locate HKVideoRangeSlider

#### via storyboard (or xib)

1. put `UIView` to view.
2. Change the class from `UIView` to `HKVideoRangeSlider`.
3. Customize its appearance.

#### via code

```swift

```

### Show tracks & other controls

To display video tracks, just set the track information via `setAssetData(_:)` method with an array of  `HKAssetInputData`.

```swift
let assets = [
    HKAssetInputData(asset: AVURLAsset(url: videoUrl1)),
    HKAssetInputData(asset: AVURLAsset(url: videoUrl2)),
    // you can set initial range settings.
    HKAssetInputData(asset: AVURLAsset(url: videoUrl3), startTime: 20, duration: 18)
]

// Display video range view
videoRangeSlider.setAssetData(assets)
```

To remove assets, just set empty assets to range slider. The slider clears all contents and hide all UI.

```swift
// To clear the contents, just set empty assets to range slider.
videoRangeSlider.setAssetData([])
```

### Receive events

To receive events, set delegate object to `delegate` property. The object must adopt the `HKVideoRangeSliderDelegate` protocol.

```swift
videoRangeSlider.delegate = self
```

#### Changed the range status

```swift
func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange])
```

Tells the delegate when the user scrolls one of the tracks, or drags the start or end slider. This is optional.

* Parameters:
    * `rangeSlider`: The slider object in which the event occurred.
    * `ranges`: The array of current range status of all tracks.

The delegate typically implements this method to obtain the change in range data.

### Changed the indicator position

```swift
func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double)
```

Tells the delegate when the user drags the progress indicator. This is optional.

* Parameters:
    * `rangeSlider`: The slider object in which the event occurred.
    * `positions`: The array of current positions of all tracks, indicated by the progress indicator.
    * `rate`: 0.0-1.0 value as the position of the progress indicator.

### Customize

#### Behavior

##### Maximum/minimum range(in seconds)



#### Appearance

##### slider & scroll knob color

use tint color.

```swift
videoRangeSlider.tintColor = .systemYellow
```


## Author

Kato Hirohito, [hkato193](https://twitter.com/hkato193)

## License

HKVideoRangeSlider is available under the MIT license. See the LICENSE file for more info.
