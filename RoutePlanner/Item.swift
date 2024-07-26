//
//  Item.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 23/07/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
