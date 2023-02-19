//
//  Category.swift
//  Todoey
//
//  Created by Alikhan Tursunbekov on 13/2/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorCell: String = ""
    var items = List<Item>()
}
