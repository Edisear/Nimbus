//
//  WeatherData.swift
//  Nimbus
//
//  Created by Jacob Raeside on 3/10/24.
//

import Foundation
import WeatherKit
import CoreLocation

struct Location: Equatable {
    let city: String
    let state: String
}


class FavoritesData {
    
    static let shared = FavoritesData()
    
    private init() {}
    
    var favoritesList : [Location] = []
    var selectedLocation: Location?
    
    func addFavorite(city: String, state: String) {
        let location = Location(city: city, state: state)
        if !favoritesList.contains(location) {
            favoritesList.append(location)
        }
    }
    
    func removeFavorite(city: String, state: String) {
        let location = Location(city: city, state: state)
        favoritesList.removeAll { $0 == location }
    }
    
}
