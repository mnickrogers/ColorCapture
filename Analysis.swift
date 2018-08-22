//
//  NRColorOps.swift
//  ColorData
//
//  Created by Nicholas Rogers on 5/13/16.
//  Copyright © 2016 Nicholas Rogers. All rights reserved.
//

import UIKit

// MARK: Types

enum ColorName: String
{
    case Red = "red"
    case Orange = "orange"
    case Yellow = "yellow"
    case Green = "green"
    case Blue = "blue"
    case Purple = "purple"
}

/// How bright the clothing color is from 1 (least) to 3 (most).
enum ClothingColorTemperature: Double
{
    case bright = 1.0
    case light = 2.0
    case dark = 3.0
}

// MARK: Classes and Structs

struct ColorNode
{
    var color: UIColor
    var colorCount: Int
}

class ImageAnalyzer: NSObject
{
    // MARK: Internal Structures and Variables
    
    internal var mainImage: UIImage?
    
    // MARK: Private Structures and Variables
    fileprivate var dominantColors = [ColorNode]()
    fileprivate let clusterSize = 35
    fileprivate let degreeVariance: Double = 35.0
    
    // MARK: Initializers
    override init()
    {
        super.init()
    }
    
    convenience init(withImage image: UIImage)
    {
        self.init()
        mainImage = image
    }
    
    // MARK: Internal Functions
    
    internal func getDominantColors() -> [ColorNode]
    {
        if mainImage == nil
        {
            return [ColorNode]()
        }
        let cgImage = mainImage!.cgImage
        let width = cgImage?.width
        let height = cgImage?.height
        
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = width! * bytesPerPixel
        let bitsPerComponent: Int = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let raw = malloc(bytesPerRow * height!)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        let ctx = CGContext(data: raw, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        ctx!.draw(cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!)))
        
        // Updated for Swift 3 and 4: cannot initialize UnsafePointer using an UnsafeRawPointer. Use "assumingMemoryBound" instead.
        // let data = UnsafePointer<UInt8>(ctx!.data!)
        let data = ctx!.data!.assumingMemoryBound(to: UInt8.self)
        
        func analyzeCluster(startX sX: Int, startY sY: Int)
        {
            for x in sX...sX + clusterSize
            {
                for y in sY...sY + clusterSize
                {
                    let pixel = ((width! * y) + x) * bytesPerPixel
                    let rgb = RGB(red: Double(data[pixel+1]), green: Double(data[pixel+2]), blue: Double(data[pixel+3]), alpha: 1.0)
                    let focusedColor = UIColor(red: CGFloat(rgb.r / 255.00), green: CGFloat(rgb.g / 255.00), blue: CGFloat(rgb.b / 255.00), alpha: 1.0)
                    
                    if dominantColors.isEmpty
                    {
                        let newNode = ColorNode(color: focusedColor, colorCount: 1)
                        dominantColors.append(newNode)
                        continue
                    }
                    
                    //1. Iterate through all dominant colors for this node
                    //2. If this color deviates from a specific color, add it to the colors list, otherwise, increase the count for that color and continue the outer loop
                    
                    var found = false
                    for i in 0 ..< dominantColors.count
                    {
                        if dominantColors[i].color.divergenceFromColor(Color: focusedColor) < degreeVariance
                        {
                            dominantColors[i].colorCount += 1
                            found = true
                            break
                        }
                    }
                    
                    if !found
                    {
                        let newNode = ColorNode(color: focusedColor, colorCount: 1)
                        dominantColors.append(newNode)
                    }
                }
            }
        }
        
        //Find cluster 1
        let c1StartX: Int = width! / 4 //Make sure the X and Y are whole numbers
        let c1StartY: Int = height! / 4
        
        let c2StartX: Int = width! / 2
        let c2StartY: Int = height! / 4
        
        let c3StartX: Int = width! - 100
        let c3StartY: Int = height! / 4
        
        let c4StartX: Int = width! / 4
        let c4StartY: Int = height! - 100
        
        let c5StartX: Int = width! / 2
        let c5StartY: Int = height! - 100
        
        let c6StartX: Int = width! - 100
        let c6StartY: Int = height! - 100
        
        analyzeCluster(startX: c1StartX, startY: c1StartY)
        analyzeCluster(startX: c2StartX, startY: c2StartY)
        analyzeCluster(startX: c3StartX, startY: c3StartY)
        analyzeCluster(startX: c4StartX, startY: c4StartY)
        analyzeCluster(startX: c5StartX, startY: c5StartY)
        analyzeCluster(startX: c6StartX, startY: c6StartY)
        
        free(raw)
        
        sortDominantColorsArray()
        
        return dominantColors
    }
    
    // MARK: Private Functions
    
    fileprivate func sortDominantColorsArray()
    {
        dominantColors.sort
            {
                return $0.0.colorCount > $0.1.colorCount
        }
    }
}

// MARK: Utility Functions

/// Convert a color hue into the name of the color.
func getColorName(hue h: Double) -> ColorName?
{
    if 345 <= h || h <= 15
    {
        return NRColorName.Red
    }
    else if 16 <= h && h <= 45
    {
        return NRColorName.Orange
    }
    else if 46 <= h && h <= 75
    {
        return NRColorName.Yellow
    }
    else if 76 <= h && h <= 165
    {
        return NRColorName.Green
    }
    else if 166 <= h && h <= 255
    {
        return NRColorName.Blue
    }
    else if 256 <= h && h <= 344
    {
        return NRColorName.Purple
    }
    else
    {
        return nil
    }
}

/// Get the color hue min and max range from a color name.
func getColorHueRanges(colorName name: ColorName) -> (min: Double, max: Double)
{
    switch name
    {
    case .Red:
        return (min: 345, max: 15)
    case .Orange:
        return (min: 16, max: 45)
    case .Yellow:
        return (min: 46, max: 75)
    case .Green:
        return (min: 76, max: 165)
    case .Blue:
        return (min: 166, max: 255)
    case .Purple:
        return (min: 256, max: 344)
    }
}

func colorDivergence(Color1 c1: UIColor, Color2 c2: UIColor) -> Double
{
    guard let rgb1 = c1.rgb()
        else { return -1.0 }
    guard let rgb2 = c2.rgb()
        else { return -1.0 }
    
    return colorDivergence(Color1RGB: rgb1, Color2RGB: rgb2)
}

func colorDivergence(Color1RGB c1: RGB, Color2RGB c2: RGB) -> Double
{
    let dR = abs(c1.r - c2.r)
    let dG = abs(c1.g - c2.g)
    let dB = abs(c1.b - c2.b)
    
    let dAvg = (dR + dG + dB) / 3.0
    
    return dAvg
}

func calculateColorDeviation(_ color: UIColor) -> Double
{
    let rgb = color.rgb()!
    return standardDeviation(values: [rgb.r, rgb.g, rgb.b], sample: false)
}

func calculateColorDeviation(red r: Double, green g: Double, blue b: Double) -> Double
{
    return standardDeviation(values: [r, g, b], sample: false)
}

func standardDeviation(values numbers: [Double], sample: Bool) -> Double {
    
    var arrAvg : Double = 0.0
    for items in numbers
    {
        arrAvg += items
    }
    arrAvg /= Double(numbers.count)
    
    var sumTotal = 0.0;
    for item in numbers
    {
        sumTotal += pow(item - arrAvg, 2)
    }
    
    var final : Double
    if sample {
        final = sqrt(sumTotal / (Double(numbers.count)-1))
    }
    else {
        final = sqrt(sumTotal / Double(numbers.count))
    }
    
    return final
}
