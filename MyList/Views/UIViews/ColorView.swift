//
//  ColorView.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class ColorView: UIView {
    
    enum Shape {
        case round, square
    }
    
    var shape: Shape
    var color: UIColor { didSet { backgroundColor = color } }
    var isFilled: Bool {
        didSet {
            backgroundColor = isFilled ? color : .clear //add background color if filled
            layer.borderColor = isFilled ? UIColor.clear.cgColor : color.cgColor //add border if not filled
        }
    }
    var height: CGFloat
    var isSelected: Bool = false {
        didSet { isSelected ? addOuterRoundedBorder(borderWidth: 4, borderColor: UIColor.label) : removeOuterBorders() }
    }
    var hasError: Bool = false {
        didSet { hasError ? addOuterRoundedBorder(borderWidth: 4, borderColor: UIColor.systemRed) : removeOuterBorders() }
    }
    
    //init with parameters
    required init(shape: Shape, color: UIColor, isFilled: Bool, height: CGFloat) {
        self.shape = shape
        self.color = color
        self.isFilled = isFilled
        self.height = height
        super.init(frame: .zero)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        switch shape {
        case .round:
            layer.cornerRadius = height / 2
        case .square:
            layer.cornerRadius = 5
        }
        backgroundColor = isFilled ? color : .clear
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
    }
}
