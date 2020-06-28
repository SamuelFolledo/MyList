//
//  UIColor+Extensions.swift
//  MyList
//
//  Created by Samuel Folledo on 6/28/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
