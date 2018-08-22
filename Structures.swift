//
//  NRColorOps.swift
//  ColorData
//
//  Created by Nicholas Rogers on 5/13/16.
//  Copyright © 2016 Nicholas Rogers. All rights reserved.
//

import UIKit

struct RGB
{
    init(red : Double = 0.0, green : Double = 0.0, blue : Double = 0.0, alpha : Double = 1.0)
    {
        r = red
        g = green
        b = blue
        a = alpha
    }
    var r : Double
    var g : Double
    var b : Double
    var a : Double
}

struct HSL
{
    var hue : Double
    var saturation : Double
    var luminance : Double
    
    init(h : Double = 0, s : Double = 0, l : Double = 0)
    {
        hue = s
        saturation = s
        luminance = l
    }
}
