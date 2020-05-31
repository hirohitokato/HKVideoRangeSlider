Pod::Spec.new do |spec|
  spec.name         = "HKVideoRangeSlider"
  spec.version      = "1.0.0"
  spec.summary      = "A range slider for trimming **multiple** videos. (swift 5)"
  spec.description  = <<-DESC
                   Full configurable video thumbnails view for trimming multiple videos.
                   You can easily specify the video range with this framework.

                   Features
                   - Scrollable thumbnails
                   - Support multiple video tracks
                   - Includes position indicator
                   - Customize appearances
                   DESC
  spec.homepage     = "https://github.com/hirohitokato/HKVideoRangeSlider"
  spec.screenshots  = "https://raw.githubusercontent.com/hirohitokato/HKVideoRangeSlider/master/assets/demo.gif"
  spec.platform     = :ios, "11.0"
  spec.swift_version = "5.0"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author    = "Kato Hirohito"
  spec.social_media_url   = "https://twitter.com/hkato193"
  spec.source       = { :git => "https://github.com/hirohitokato/HKVideoRangeSlider.git", :tag => "#{spec.version}" }
  spec.source_files  = "Framework/Sources/**/*.{h,swift}"
  spec.frameworks = 'UIKIt'
  spec.resource  = "Framework/Sources/**/*.xcassets"

end
