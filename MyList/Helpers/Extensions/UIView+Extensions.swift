//
//  UIView+Extensions.swift
//  MyList
//
//  Created by Samuel Folledo on 7/3/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit.UIView

extension UIView {
    fileprivate struct Constants {
        static let externalBorderName = "externalBorder"
    }

    func addOuterRoundedBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = UIColor.white) {
        let externalBorder = CALayer()
        //Note: If you want extra space
        externalBorder.frame = CGRect(x: -borderWidth*1.5, y: -borderWidth*1.5, width: frame.size.width + 3 * borderWidth, height: frame.size.height + 3 * borderWidth) //1.5 * 2 = 3
        externalBorder.cornerRadius = (frame.size.width + 3 * borderWidth) / 2
        //Note: If you dont want extra space outside the border
//        externalBorder.frame = CGRect(x: -borderWidth, y: -borderWidth, width: frame.size.width + 2 * borderWidth, height: frame.size.height + 2 * borderWidth)
//        externalBorder.cornerRadius = (frame.size.width + 2 * borderWidth) / 2
        externalBorder.borderColor = borderColor.cgColor
        externalBorder.borderWidth = borderWidth
        externalBorder.name = Constants.externalBorderName
        layer.insertSublayer(externalBorder, at: 0)
        layer.masksToBounds = false
//        return externalBorder
    }

    func removeOuterBorders() {
        layer.sublayers?.filter() { $0.name == Constants.externalBorderName }.forEach() {
            $0.removeFromSuperlayer()
        }
    }

    func removeOuterBorder(externalBorder: CALayer) {
        guard externalBorder.name == Constants.externalBorderName else { return }
        externalBorder.removeFromSuperlayer()
    }
}
