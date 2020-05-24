//
//  CommonExtensions.swift
//  HKVideoRangeSlider
//
//  Created by Hirohito Kato on 2020/05/04.
//  Copyright © 2020 Hirohito Kato. All rights reserved.
//

import UIKit

extension BinaryFloatingPoint {
    func clipped(_ minValue: Self, _ maxValue: Self) -> Self {
        guard minValue < maxValue else {
            fatalError("BUG: min value(\(minValue)) must be smaller than max(\(maxValue)) value.")
        }
        return max(minValue, min(maxValue, self))
    }

    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Self {
        let divisor = pow(10.0, Double(places))
        return (self * Self(divisor)).rounded() / Self(divisor)
    }

    /// Compare two values with decimal places.
    /// - Parameters:
    ///   - other: another value
    ///   - places: decimal places
    /// - Returns: Returns true if the two is the almost same, false if not.
    func isEqual(to other: Self, places: Int) -> Bool {
        return self.rounded(toPlaces: places) == other.rounded(toPlaces: places)
    }
}

extension UIView {
    func convert(_ xPoint: CGFloat, to coordinateSpace: UICoordinateSpace) -> CGFloat {
        let point = CGPoint(x: xPoint, y: 0)
        return convert(point, to: coordinateSpace).x
    }

    func convert(_ xPoint: CGFloat, from coordinateSpace: UICoordinateSpace) -> CGFloat {
        let point = CGPoint(x: xPoint, y: 0)
        return convert(point, from: coordinateSpace).x
    }
}

extension CGRect {
    var x: CGFloat { origin.x }
    var y: CGFloat { origin.y }
}

extension UIColor {
    var hue: CGFloat {
        var h: CGFloat = -1.0
        _ = get(&h, s: nil, b: nil, a: nil)
        return h
    }

    var saturation: CGFloat {
        var s: CGFloat = -1.0
        _ = get(nil, s: &s, b: nil, a: nil)
        return s
    }

    var brightness: CGFloat {
        var b: CGFloat = -1.0
        _ = get(nil, s: nil, b: &b, a: nil)
        return b
    }

    private func get(_ h: UnsafeMutablePointer<CGFloat>?,
                     s: UnsafeMutablePointer<CGFloat>?,
                     b: UnsafeMutablePointer<CGFloat>?,
                     a: UnsafeMutablePointer<CGFloat>?) -> Bool {

        if cgColor.numberOfComponents == 2 {
            h?.pointee = 0
            s?.pointee = 0
            b?.pointee = cgColor.components![0]
            a?.pointee = cgColor.components![1]
            return true
        } else {
            return self.getHue(h, saturation: s, brightness: b, alpha: a)
        }
    }
}
// MARK: - For debugging

extension BinaryFloatingPoint {
    var s: String { String(format: "%.1f", Double(self)) }
}
extension CGPoint {
    var s: String { String(format: "(%.0f, %.0f)", x, y) }
}
extension CGRect {
    var s: String { String(format: "(%.0f,%.0f,%.0f,%.0f)", origin.x,origin.y,width,height)}
}

