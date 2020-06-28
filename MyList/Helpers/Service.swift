//
//  Service.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class Service {
    static func dateFormatter() -> DateFormatter { // DateFormatter = A formatter that converts between dates and their textual representations.
        let dateFormatter = DateFormatter()
        let dateFormat = "yyyyMMddHHmmss"
        dateFormatter.dateFormat = dateFormat //dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }

    static func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void ) { //string to image method for imageURL
        var image: UIImage? //container for our image
        let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0)) //this will decode our string to an NSData
        image = UIImage(data: decodedData! as Data) //assign our image to our decodedData
        withBlock(image)
    }
}

