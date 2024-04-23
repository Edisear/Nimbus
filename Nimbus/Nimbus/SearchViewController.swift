//
//  SearchViewController.swift
//  Nimbus
//
//  Created by Jacob Raeside on 3/9/24.
//

import UIKit
import WeatherKit
import CoreLocation

class SearchViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsTempLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var uvLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    @IBOutlet weak var weatherAlertLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    let locationManager = CLLocationManager()
    let weatherService = WeatherService()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            getWeather(for: location)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let placemark = placemarks?.first,
                   let city = placemark.locality,
                   let state = placemark.administrativeArea {
                    DispatchQueue.main.async {
                        self?.locationTitleLabel.text = "\(city), \(state)"
                        }
                    }
                }
            }
        }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            searchLocationAndGetWeather(for: searchText)
        }
    }
    
    func searchLocationAndGetWeather(for locationName: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let location = placemarks?.first?.location {
                self.getWeather(for: location)
            }
            
            if let placemark = placemarks?.first,
                let city = placemark.locality,
                let state = placemark.administrativeArea {
                DispatchQueue.main.async {
                    self.locationTitleLabel.text = "\(city), \(state)"
                }
            }
        }
    }
    
    func getWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let weatherAlerts = weather.weatherAlerts
                let currentWeather = weather.currentWeather
                let dayWeather = weather.dailyForecast
                let neededDayForecasts = ArraySlice(dayWeather.prefix(1))
                DispatchQueue.main.async {
                    self.updateLabels(with: currentWeather, and: neededDayForecasts, and: weatherAlerts)
                    }
                } catch {
                print("Error getting weather data: \(error)")
            }
        }
    }
    
    func updateLabels(with currForecast: CurrentWeather, and dayForecast: ArraySlice<DayWeather>, and weatherAlerts: [WeatherAlert]?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = TimeZone.current
        
        let tempF = currForecast.temperature.value * 9 / 5 + 32
        let tempFeelF = currForecast.apparentTemperature.value * 9 / 5 + 32
        let tempString = String(format: "%.0f°F", tempF)
        let feelsTempString = String(format: "%.0f°F", tempFeelF)
        let precipitationString = String(format: "%.0f%%", dayForecast[0].precipitationChance * 100)
        let uvString = String(currForecast.uvIndex.value)
        let humidityString = String(format: "%.0f%%", currForecast.humidity * 100)
        let windSpeedString = String(currForecast.wind.speed.value)
        
        tempLabel.text = tempString
        feelsTempLabel.text = feelsTempString
        precipLabel.text = precipitationString
        uvLabel.text = uvString
        humidityLabel.text = humidityString
        windSpeedLabel.text = windSpeedString
        conditionImage.image = UIImage(systemName: currForecast.symbolName)
        if let weatherAlerts = weatherAlerts?.first {
            weatherAlertLabel.text = weatherAlerts.summary
        } else {
            weatherAlertLabel.text = "Currently there are no weather alerts for this location."
        }
        
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if FavoritesData.shared.favoritesList.count == 5 {
            let alert = UIAlertController(title: "Favorites Limit Reached", message: "Please delete a favorite before adding any more.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            guard let locationText = locationTitleLabel.text,
                  let commaRange = locationText.range(of: ", ") else { return }
            
            let city = String(locationText[..<commaRange.lowerBound])
            let state = String(locationText[commaRange.upperBound...])
            
            FavoritesData.shared.addFavorite(city: city, state: state)
        }
    }
}
