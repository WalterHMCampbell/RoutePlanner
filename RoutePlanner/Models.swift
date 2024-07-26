//
//  Models.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 23/07/2024.
//

import Foundation
import CoreLocation

struct Waypoint: Identifiable {
    let id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var elevation: Double
}

struct Route {
    let name: String
    let waypoints: [Waypoint]
    
    var totalDistance: Double {
        zip(waypoints, waypoints.dropFirst()).reduce(0) { total, pair in
            total + calculateDistance(from: pair.0, to: pair.1)
        }
    }
    
    var totalUps: Double {
        zip(waypoints, waypoints.dropFirst()).reduce(0) { total, pair in
            total + max(0, pair.1.elevation - pair.0.elevation)
        }
    }
    
    var totalTime: TimeInterval {
        zip(waypoints, waypoints.dropFirst()).reduce(0) { total, pair in
            total + calculateTime(from: pair.0, to: pair.1)
        }
    }
}

enum WaypointStatus {
    case notReached, approaching, reached, passed
}

func calculateDistance(from: Waypoint, to: Waypoint) -> Double {
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return from.distance(from: to) / 1000 // Convert to kilometers
}

func calculateTime(from: Waypoint, to: Waypoint) -> TimeInterval {
    let distance = calculateDistance(from: from, to: to)
    let speed = 5.0 // Assume 5 km/h walking speed
    return distance / speed * 3600 // Convert to seconds
}
