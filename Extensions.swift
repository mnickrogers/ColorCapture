//
//  NRColorOps.swift
//  ColorData
//
//  Created by Nicholas Rogers on 5/13/16.
//  Copyright © 2016 Nicholas Rogers. All rights reserved.
//

import UIKit

extension UIImage
{
    func getDominantColors() -> [ColorNode]
    {
        let analyzer = ImageAnalyzer(withImage: self)
        return analyzer.getDominantColors()
    }
    
    func croppedImage(crop cropRect: CGRect) -> UIImage
    {
        var finalCropRect = cropRect
        if self.scale > 1.0
        {
            finalCropRect = CGRect(x: cropRect.origin.x * self.scale,
                                   y: cropRect.origin.y * self.scale,
                                   width: cropRect.size.width * self.scale,
                                   height: cropRect.size.height * self.scale)
        }
        
        guard let imgRef = self.cgImage?.cropping(to: finalCropRect)
            else { return UIImage() }
        let finalImage = UIImage(cgImage: imgRef,
                                 scale: self.scale,
                                 orientation: self.imageOrientation)
        
        return finalImage
    }
    
    func scaledImageToHeight(height h2: CGFloat) -> UIImage
    {
        let w2 = (self.size.width * h2) / self.size.height
        let newSize = CGSize(width: w2, height: h2)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0) //Pass 0.0 to account for retina display or 1.0 to remain pixel accuracy
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIColor
{
    func rgb() -> RGB?
    {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        {
            let red = fRed * 255.0
            let green = fGreen * 255.0
            let blue = fBlue * 255.0
            let alpha = fAlpha * 255.0
            
            return RGB(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func temperature() -> Double
    {
        guard let color = self.rgb()
            else { return 0.0 }
        
        //Convert RGB to CIE (XYZ) values
        var x = (-0.14282 * color.r) + (1.54924 * color.g) + (-0.95641 * color.b)
        var y = (-0.32466 * color.r) + (1.57837 * color.g) + (-0.73191 * color.b)
        let z = (-0.68202 * color.r) + (0.77073 * color.g) + (0.56332 * color.b)
        
        //Normalize chromaticity
        x = x / (x + y + z)
        y = y / (x + y + z)
        
        //Compute correlated color temperature (CCT)
        let n = (x - 0.3320) / (0.1858 - y)
        let cct = (449 * pow(n, 3)) + (3525 * pow(n, 2)) + (6823.3 * n) + 5520.33
        
        return cct
    }
    
    /// Returns hue (in degrees), saturation (out of 1) and luminance (average of min and max RGB)
    func hsl() -> HSL
    {
        guard let colors = self.rgb()
            else { return HSL(h: 0, s: 0, l: 0) }
        
        let r = colors.r / 255.0
        let g = colors.g / 255.0
        let b = colors.b / 255.0
        
        let minimum = min(min(r, g), b)
        let maximum = max(max(r, g), b)
        
        // Find luminance
        let l = (maximum + minimum) / 2.0
        
        if minimum == maximum || (r == g) && (r == b) //No saturation / no hue
        {
            return HSL(h: 0, s: 0, l: l)
        }
        
        var s : Double!
        
        if l < 0.5
        {
            s = (maximum - minimum) / (maximum + minimum)
        }
        else if l >= 0.5
        {
            s = (maximum - minimum) / (2.0 - maximum - minimum)
        }
        else // Just to make sure l has a value - this should never happen
        {
            s = 0
        }
        
        var h : Double!
        
        if r >= max(g, b)
        {
            h = (g - b) / (maximum - minimum)
        }
        else if g >= max(r, b)
        {
            h = (2.0 + (b - r)) / (maximum - minimum)
        }
        else if b >= max(r, g)
        {
            h = (4.0 + (r - g)) / (maximum - minimum)
        }
        else // Just to make sure h has a value - this should never happen
        {
            h = 0
        }
        
        return HSL(h: h, s: s, l: l)
    }
    
    func divergenceFromColor(Color c2: UIColor) -> Double
    {
        return colorDivergence(Color1: self, Color2: c2)
    }
    
    func getColorCategory(fromHSL hsl: HSL) -> ClothingColorTemperature
    {
        if 0.00 <= hsl.luminance && hsl.luminance < 0.35
        {
            return ClothingColorTemperature.dark
        }
        else if 0.35 <= hsl.luminance && hsl.luminance < 0.55
        {
            return ClothingColorTemperature.light
        }
        else if 0.55 <= hsl.luminance && hsl.luminance <= 1.0
        {
            return ClothingColorTemperature.bright
        }
        else
        {
            return ClothingColorTemperature.bright
        }
    }
    
    func getColorCatagory() -> ClothingColorTemperature
    {
        let hsl = self.hsl()
        return self.getColorCategory(fromHSL: hsl)
    }
}
