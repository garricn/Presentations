//
//  PhlickrPhoto.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/21/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

struct PhlickrPhoto {
    let farmID: Int
    let serverID: String
    let photoID: String
    let secret: String
    let photoURL: NSURL
    let image: UIImage

    init?(dictionary: [String: AnyObject]) {
        guard
            let farmID = dictionary["farm"] as? Int,
            let serverID = dictionary["server"] as? String,
            let photoID = dictionary["id"] as? String,
            let secret = dictionary["secret"] as? String
            else { return nil }

        let resourceString = "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secret)_z.jpg"

        guard
            let encoded = resourceString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()),
            let url = NSURL(string: encoded),
            let data = NSData(contentsOfURL: url),
            let image = UIImage(data: data)
            else { return nil }

        self.farmID = farmID
        self.serverID = serverID
        self.photoID = photoID
        self.secret = secret
        self.photoURL = url
        self.image = image
    }
}
