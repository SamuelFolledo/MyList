//
//  UIFont+Extensions.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
    open class func font(size: CGFloat, weight: UIFont.Weight, design: UIFontDescriptor.SystemDesign) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = systemFont.fontDescriptor.withDesign(design) else {
            return systemFont
        }
        return UIFont(descriptor: descriptor, size: size)
    }
}
