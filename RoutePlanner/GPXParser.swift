//
//  GPXParser.swift
//  RoutePlanner
//
//  Created by Walter Campbell on 23/07/2024.
//

import Foundation

class GPXParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentWaypoint: Waypoint?
    private var waypoints: [Waypoint] = []
    private var routeName: String?
    
    func parse(data: Data) -> Route? {
        waypoints = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            return Route(name: routeName ?? "Unnamed Route", waypoints: waypoints)
        } else {
            print("Failed to parse GPX data")
            return nil
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "rtept" || elementName == "wpt" {
            let lat = Double(attributeDict["lat"] ?? "") ?? 0
            let lon = Double(attributeDict["lon"] ?? "") ?? 0
            currentWaypoint = Waypoint(name: "", latitude: lat, longitude: lon, elevation: 0)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "rtept" || elementName == "wpt" {
            if let waypoint = currentWaypoint {
                waypoints.append(waypoint)
            }
            currentWaypoint = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty {
            switch currentElement {
            case "name":
                if currentWaypoint != nil {
                    currentWaypoint?.name = data
                } else {
                    routeName = data
                }
            case "ele":
                currentWaypoint?.elevation = Double(data) ?? 0
            default:
                break
            }
        }
    }
}
