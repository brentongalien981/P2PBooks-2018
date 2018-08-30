//
//  Book.swift
//  Library@home
//
//  Created by ops on 2018-06-14.
//  Copyright © 2018 ops. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON


class Book {
    
    var id: String?
    var pseudoId: Int?
    var title: String!
    var author: String!
    var description: String!
//    var photoDownloadUrl: String?
    var photos: [String]
    var createdAt: Double?
    var updatedAt: Double?
    var price: Int?
    
    
    private var image: UIImage!
    
    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
//        self.photos = [:]
        self.photos = []
    }
    
    
    init(_ id: String?, _ title: String, _ author: String, _ photos: [String], price: Int?, description: String, createdAt: Double?, updatedAt: Double?) {
        self.id = id
        self.title = title
        self.author = author
        self.photos = photos
        self.price = price
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
