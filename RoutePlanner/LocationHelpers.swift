//
//  LocationHelpers.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 25/07/2024.
//

import CoreLocation

func isWithinProximity(userLocation: CLLocation, waypoint: Waypoint, radius: Double) -> Bool {
    let waypointLocation = CLLocation(latitude: waypoint.latitude, longitude: waypoint.longitude)
    return userLocation.distance(from: waypointLocation) <= radius
}

func updateWaypointStatuses(userLocation: CLLocation, waypoints: [Waypoint], radius: Double) -> [WaypointStatus] {
    return waypoints.enumerated().map { index, waypoint in
        if isWithinProximity(userLocation: userLocation, waypoint: waypoint, radius: radius) {
            return .approaching
        } else if index > 0 && isWithinProximity(userLocation: userLocation, waypoint: waypoints[index - 1], radius: radius) {
            return .reached
        } else if index > 0 && userLocation.distance(from: CLLocation(latitude: waypoints[index - 1].latitude, longitude: waypoints[index - 1].longitude)) > radius {
            return .passed
        } else {
            return .notReached
        }
    }
}
