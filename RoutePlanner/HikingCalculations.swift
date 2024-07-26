//
//  HikingCalculations.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 24/07/2024.
//
import SwiftUI
import Foundation
import CoreLocation
//import UniformTypeIdentifiers

/*
func calculateTime(from: Waypoint, to: Waypoint) -> TimeInterval {
    let distance = calculateDistance(from: from, to: to)
    let speed = calculateSpeed(from: from, to: to)
    
    let time = (distance / speed) * 1.4 // time in hours, scaled by 1.4
    return time * 3600 // convert to seconds
}

func calculateSpeed(from: Waypoint, to: Waypoint) -> Double {
    let distance = calculateDistance(from: from, to: to) // in kilometers
    let elevationChange = to.elevation - from.elevation // in meters
    let slope = elevationChange / (distance * 1000) // convert distance to meters for slope calculation
    
    // Tobler's hiking function
    let speed = 6 * exp(-3.5 * abs(slope + 0.05))
    
    return speed // in km/h
}


func calculateDistance(from: Waypoint, to: Waypoint) -> Double {
    // Haversine formula for distance calculation
    let R = 6371.0 // Earth's radius in km
    
    let lat1 = from.latitude * .pi / 180
    let lat2 = to.latitude * .pi / 180
    let dLat = (to.latitude - from.latitude) * .pi / 180
    let dLon = (to.longitude - from.longitude) * .pi / 180
    
    let a = sin(dLat/2) * sin(dLat/2) +
            cos(lat1) * cos(lat2) *
            sin(dLon/2) * sin(dLon/2)
    let c = 2 * atan2(sqrt(a), sqrt(1-a))
    
    return R * c // Distance in km
}
 */

func estimatedTimeOfDay(startTime: Date, route: [Waypoint]) -> String {
    let cumulativeTime = zip(route, route.dropFirst())
        .map { calculateTime(from: $0, to: $1) }
        .reduce(0, +)
    
    let arrivalTime = startTime.addingTimeInterval(cumulativeTime)
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: arrivalTime)
}
