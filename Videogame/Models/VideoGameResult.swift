//
//  VideoGameResult.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

// video game result model
struct VideoGameResult {
    
    let videoGames: [VideoGame]?
    let error: Error?
    let currentPage: Int // keep current page count to support pagination
    let pageCount: Int // page count to support pagination
    
    // check if headend supports pagination and return if the response has more pages to load
    var hasMorePages: Bool {
        return currentPage < pageCount
    }
    
    // returns the next page number, so we can make a server call to fetch the next page data from headend
    var nextPage: Int {
        return hasMorePages ? currentPage + 1 : currentPage
    }
}
