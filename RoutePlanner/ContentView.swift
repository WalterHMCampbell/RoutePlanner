//
//  ContentView.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 23/07/2024.
//
import SwiftUI
import UniformTypeIdentifiers
import CoreLocation

struct ContentView: View {
    @State private var route: Route?
    @State private var isFilePickerPresented = false
    @State private var startTime = Date(timeIntervalSince1970: 1722438000) // Default to July 31, 2024, 11:00 AM
    @StateObject private var locationManager = LocationManager()
    @State private var waypointStatuses: [WaypointStatus] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Load GPX File") {
                    isFilePickerPresented = true
                }
                .padding()
                
                if let route = route {
                    // Top Table
                    VStack(alignment: .leading) {
                        Text("Route: \(route.name)")
                        Text("Total Distance: \(route.totalDistance, specifier: "%.2f") km")
                        Text("Ups Total: \(route.totalUps, specifier: "%.2f") m")
                        Text("Total Time: \(formatTime(route.totalTime))")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    // Bottom Table
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<route.waypoints.count - 1, id: \.self) { index in
                                WaypointRowView(
                                    startTime: startTime,
                                    from: route.waypoints[index],
                                    to: route.waypoints[index + 1],
                                    cumulativeTime: calculateCumulativeTime(upToIndex: index + 1),
                                    remainingTime: TimeInterval(route.totalTime - calculateCumulativeTime(upToIndex: index + 1)),
                                    status: waypointStatuses[safe: index] ?? .notReached
                                )
                            }
                        }
                        .padding()
                    }
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding()
                } else {
                    Text("No route loaded")
                        .padding()
                }
            }
            .navigationTitle("Route Planner")
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.xml, UTType(filenameExtension: "gpx")!],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                locationManager.startUpdatingLocation()
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let location = newLocation, let route = route {
                    waypointStatuses = updateWaypointStatuses(userLocation: location, waypoints: route.waypoints, radius: 20)
                }
            }
        }
    }
 // meaningless pagging git test
 // another comment
    
    private func calculateCumulativeTime(upToIndex index: Int) -> TimeInterval {
        guard let route = route else { return 0 }
        return zip(route.waypoints.prefix(index), route.waypoints.dropFirst().prefix(index))
            .reduce(0) { total, waypointPair in
                total + calculateTime(from: waypointPair.0, to: waypointPair.1)
            }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            urls.first.map(loadGPXFile)
        case .failure(let error):
            print("File selection failed: \(error.localizedDescription)")
        }
    }

    private func loadGPXFile(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let parser = GPXParser()
            if let parsedRoute = parser.parse(data: data) {
                DispatchQueue.main.async {
                    self.route = parsedRoute
                }
            }
        } catch {
            print("Error loading GPX file: \(error)")
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct WaypointRowView: View {
    let startTime: Date
    let from: Waypoint
    let to: Waypoint
    let cumulativeTime: TimeInterval
    let remainingTime: TimeInterval
    let status: WaypointStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: From and To
            HStack {
                Text("From: \(from.name)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("To: \(to.name)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.headline)
            
            // Row 2: Bearing, Distance, and Elevation
            HStack {
                Text("TBrng: \(bearingTrue(from: from, to: to), specifier: "%.1f")°")
                Text("Dist: \(calculateDistance(from: from, to: to), specifier: "%.2f") km")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Elev: \((to.elevation - from.elevation), specifier: "%+.1f") m")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Row 3: Time, ETA, and Remaining Time
            HStack {
                Text("Time: \(formatTime(calculateTime(from: from, to: to)))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("ETA: \(estimatedTimeOfDay(startTime: startTime, cumulativeTime: cumulativeTime))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Rem: \(formatTime(remainingTime))")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .font(.system(size: 14))
        .padding(10)
        .background(backgroundColorForStatus(status))
        .cornerRadius(8)
    }
    
    private func backgroundColorForStatus(_ status: WaypointStatus) -> Color {
        switch status {
        case .notReached: return Color.gray.opacity(0.1)
        case .approaching: return Color.red.opacity(0.2)
        case .reached: return Color.green.opacity(0.2)
        case .passed: return Color.blue.opacity(0.2)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private func estimatedTimeOfDay(startTime: Date, cumulativeTime: TimeInterval) -> String {
        let arrivalTime = startTime.addingTimeInterval(cumulativeTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: arrivalTime)
    }
    
    private func bearingTrue(from: Waypoint, to: Waypoint) -> Double {
        // Implement bearing calculation here
        return 0.0 // Placeholder
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    
    
    
    
    
    
    
    
    
    
}
