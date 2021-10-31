//
//  downloadImage.swift
//  Flickr_image
//
//  Created by Mohan Kurera on 2021/10/29.
//

import Foundation

struct ImageData: Codable {
    var title: String = ""
    var url: String = ""
    var details: Content? = nil
    
    mutating func reset() {
        self = ImageData()
    }
}
//
//struct Content: Codable {
//    var author: String
//    var publishDate: Date
//    var dateTaken: Date
//}
