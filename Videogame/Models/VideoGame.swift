//
//  ServiceResponse.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

// Video game model
struct VideoGame: Codable {
    
    let name: String // title from the response
    let image: [String: String] // dictionary of image urls
    
    // icon image url string
    var iconImageURL: String {
        get {
            guard let urlForIcon = self.image["icon_url"] else { return "" }
            return urlForIcon
        }
    }
}
