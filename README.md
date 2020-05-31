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
iOS video range slider for trimming it, supporting multiple tracks.

![](https://raw.githubusercontent.com/hirohitokato/HKVideoRangeSlider/master/assets/demo.gif)

## 💘 Features

- [x] Scrollable thumbnails
- [x] Support **multiple** video tracks
- [x] Includes position indicator
- [x] Support portlait & landscape, and device rotation
- [x] Customize appearances

##  🗒 Requirements

HKVideoRangeSlider is written in Swift 5. Compatible with iOS 11.0+

## 📥 Installation

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

## 🚀 Getting Started

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

## 🤲 Usage

### 🖼 Place HKVideoRangeSlider

#### via storyboard (or xib)

1. put `UIView` to view.
2. Change the class from `UIView` to `HKVideoRangeSlider`.
3. Customize its appearance.
4. Connect the outlet to its view controller.

#### via code

```swift
let videoRangeSlider = HKVideoRangeSlider(frame: targetFrame)

self.addSubview(videoRangeSlider)
```


---

### 🎞 Show tracks & other controls

To display video tracks, just set the track information via `setAssetData(_:)` method with an array of  `HKAssetInputData`.

```swift
// Create an array of contents.
let assets = [
    HKAssetInputData(asset: AVURLAsset(url: videoUrl1)),
    HKAssetInputData(asset: AVURLAsset(url: videoUrl2)),
    // you can set initial range settings.
    HKAssetInputData(asset: AVURLAsset(url: videoUrl3), startTime: 20, duration: 18)
]

// Display video range view
videoRangeSlider.setAssetData(assets)
```

You also can force redraw the tracks as follows.

```swift
videoRangeSlider.updateThumbnails()
```

To remove assets, just set empty assets to range slider. The slider clears all contents and hide all UI.

```swift
// To clear the contents, just set empty assets to range slider.
videoRangeSlider.setAssetData([])
```

---

### 🎮 Control HKVideoRangeSlider

#### 🕹 Main slider

To set the scroll position of whole contents, use `mainSliderValue` property with 0.0 - 1.0 value.

```swift
// Scroll to the center.
videoRangeSlider.mainSliderValue = 0.5
```

#### 🕹 Progress indicator

To set a current position of the progress indicator, use `setProgress(rate:animated:)` method, with 0.0 - 1.0.

```swift
// Reset the progress. 
videoRangeSlider.setProgress(rate: 0.0, animated: true)
```

---

### 🔌 Receive events

To receive events, set delegate object to `delegate` property. The object must adopt the `HKVideoRangeSliderDelegate` protocol.

```swift
videoRangeSlider.delegate = self
```

#### ⚡️ Changed the range status

```swift
func didChangeRangeData(rangeSlider: HKVideoRangeSlider, ranges: [HKVideoRange])
```

Tells the delegate when the user scrolls one of the tracks, or drags the start or end slider. This is optional.

Parameters are as follows:

|name|description|
|---|---|
|`rangeSlider`|The slider object in which the event occurred.|
|`ranges`|The array of current range status of all tracks.|

The delegate typically implements this method to obtain the change in range data.

#### ⚡️ Changed the indicator position

```swift
func didChangeIndicatorPosition(rangeSlider: HKVideoRangeSlider, positions: [HKVideoPosition], rate: Double)
```

Tells the delegate when the user drags the progress indicator. This is optional.

Parameters are as follows:

|name|description|
|---|---|
|`rangeSlider`|The slider object in which the event occurred.|
|`positions`|The array of current positions of all tracks, indicated by the progress indicator.|
|`rate`|0.0-1.0 value as the position of the progress indicator.|

---

### 🛠 Customize

#### 🏃‍♀️ Behavior

##### ▶ Maximum/minimum range(in seconds)

To limit the range, use `maxDuration` and `minDuration` properties.

```swift
// Limit the range to 10 - 180 seconds.
videoRangeSlider.maxDuration = 180.0
videoRangeSlider.minDuration = 10
```

The default values are 3600 and 2 (seconds).

#### 🎨 Appearance

##### ▶ Change the color of start/end indicator & the scroll knob color

![](https://raw.githubusercontent.com/hirohitokato/HKVideoRangeSlider/master/assets/tintColor1.png)　![](https://raw.githubusercontent.com/hirohitokato/HKVideoRangeSlider/master/assets/tintColor2.png)　![](https://raw.githubusercontent.com/hirohitokato/HKVideoRangeSlider/master/assets/dimpleColor.png)

Use `tintColor` and `startEndSliderDimpleColor` property.

```swift
videoRangeSlider.tintColor = .systemYellow
videoRangeSlider.startEndSliderDimpleColor = .darkGray
```

##### ▶ Use an original image as slider.

Use `startEndSliderImage` property.

```swift
videoRangeSlider.startEndSliderImage = UIImage(named: "mySlider")
```

If you set `nil`,  HKVideoRangeSlider uses default image.

HKVideoRangeSlider uses the rightmost / leftmost side as the position for indicating start and end position.

Furthermore, you can show / hide borders laid between start / end slider by using `isStartEndBorderHidden` property.

```swift
// Hide borders between start / end slider
videoRangeSlider.isStartEndBorderHidden = true
```

## 💪 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hirohitokato/HKVideoRangeSlider.

## 🖋 Author

Kato Hirohito, twitter account is [hkato193](https://twitter.com/hkato193).

## 📜 License

HKVideoRangeSlider is available under the MIT license. See the LICENSE file for more info.
