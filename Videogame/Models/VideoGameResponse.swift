//
//  VideoGameResponse.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

// Video game response model
struct VideoGameResponse: Codable {
    
    let results: [VideoGame]
}
