//
//  FlickrImage.swift
//  Flickr_image
//
//  Created by Mohan Kurera on 2021/10/28.
//

import Foundation

/// To keep image data
struct Flickr {
    var imageUrl: String = ""
    var imageTitle: String = ""
    var details: Content? = nil
    
    mutating func reset() {
        self = Flickr()
    }
}

struct Content: Codable {
    var author_name: String = ""
    var publishDate: Date?
    var dateTaken: Date?
    
    mutating func reset() {
        self = Content()
    }
}

