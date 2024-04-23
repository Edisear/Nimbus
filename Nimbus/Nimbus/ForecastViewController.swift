//
//  ForecastViewController.swift
//  Nimbus
//
//  Created by Jacob Raeside on 3/9/24.
//

import UIKit
import CoreLocation
import WeatherKit

class ForecastViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var currentTempLabel1: UILabel!
    @IBOutlet weak var precipLabel1: UILabel!
    @IBOutlet weak var timeLabel1: UILabel!
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var currentTempLabel2: UILabel!
    @IBOutlet weak var precipLabel2: UILabel!
    @IBOutlet weak var timeLabel2: UILabel!
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var currentTempLabel3: UILabel!
    @IBOutlet weak var precipLabel3: UILabel!
    @IBOutlet weak var timeLabel3: UILabel!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var currentTempLabel4: UILabel!
    @IBOutlet weak var precipLabel4: UILabel!
    @IBOutlet weak var timeLabel4: UILabel!
    @IBOutlet weak var image4: UIImageView!
    
    @IBOutlet weak var currentTempLabel5: UILabel!
    @IBOutlet weak var precipLabel5: UILabel!
    @IBOutlet weak var timeLabel5: UILabel!
    @IBOutlet weak var image5: UIImageView!
    
    
    @IBOutlet var currentTempLabels: [UILabel]!
    @IBOutlet var precipitationChanceLabels: [UILabel]!
    @IBOutlet var timeLabels: [UILabel]!
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var dayLabel1: UILabel!
    @IBOutlet weak var hi1: UILabel!
    @IBOutlet weak var lo1: UILabel!
    @IBOutlet weak var precip1: UILabel!
    @IBOutlet weak var dayImage1: UIImageView!
    
    @IBOutlet weak var dayLabel2: UILabel!
    @IBOutlet weak var hi2: UILabel!
    @IBOutlet weak var lo2: UILabel!
    @IBOutlet weak var precip2: UILabel!
    @IBOutlet weak var dayImage2: UIImageView!
    
    @IBOutlet weak var dayLabel3: UILabel!
    @IBOutlet weak var hi3: UILabel!
    @IBOutlet weak var lo3: UILabel!
    @IBOutlet weak var precip3: UILabel!
    @IBOutlet weak var dayImage3: UIImageView!
    
    @IBOutlet weak var dayLabel4: UILabel!
    @IBOutlet weak var hi4: UILabel!
    @IBOutlet weak var lo4: UILabel!
    @IBOutlet weak var precip4: UILabel!
    @IBOutlet weak var dayImage4: UIImageView!
    
    @IBOutlet weak var dayLabel5: UILabel!
    @IBOutlet weak var hi5: UILabel!
    @IBOutlet weak var lo5: UILabel!
    @IBOutlet weak var precip5: UILabel!
    @IBOutlet weak var dayImage5: UIImageView!
    
    @IBOutlet weak var dayLabel6: UILabel!
    @IBOutlet weak var hi6: UILabel!
    @IBOutlet weak var lo6: UILabel!
    @IBOutlet weak var precip6: UILabel!
    @IBOutlet weak var dayImage6: UIImageView!
    
    @IBOutlet weak var dayLabel7: UILabel!
    @IBOutlet weak var hi7: UILabel!
    @IBOutlet weak var lo7: UILabel!
    @IBOutlet weak var precip7: UILabel!
    @IBOutlet weak var dayImage7: UIImageView!
    
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet var hiLabels: [UILabel]!
    @IBOutlet var loLabels: [UILabel]!
    @IBOutlet var precipLabels: [UILabel]!
    @IBOutlet var dayImageViews: [UIImageView]!
    
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let weatherService = WeatherService()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViews.sort(by: { $0.tag < $1.tag })
        currentTempLabels.sort(by: { $0.tag < $1.tag })
        precipitationChanceLabels.sort(by: { $0.tag < $1.tag })
        timeLabels.sort(by: { $0.tag < $1.tag })
        
        dayLabels.sort(by: { $0.tag < $1.tag })
        hiLabels.sort(by: { $0.tag < $1.tag })
        loLabels.sort(by: { $0.tag < $1.tag })
        precipLabels.sort(by: { $0.tag < $1.tag })
        dayImageViews.sort(by: { $0.tag < $1.tag })
        
        getUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedLocation = FavoritesData.shared.selectedLocation {
            let locationName = "\(selectedLocation.city), \(selectedLocation.state)"
            searchLocationAndGetWeather(for: locationName)
        } else {
            getUserLocation()
        }
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func currentLocationForecastButton(_ sender: UIButton) {
        FavoritesData.shared.selectedLocation = nil
        getUserLocation()
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
                self.getHourlyWeather(for: location)
                self.getDailyWeather(for: location)
            }
            
            if let placemark = placemarks?.first,
                let city = placemark.locality,
                let state = placemark.administrativeArea {
                DispatchQueue.main.async {
                    self.locationLabel.text = "\(city), \(state)"
                }
            }
        }
    }
    
    func getHourlyWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let hourlyForecasts = weather.hourlyForecast
                let now = Date()
                let upcomingForecasts = hourlyForecasts.filter {$0.date >= now}
                let neededForecasts = ArraySlice(upcomingForecasts.prefix(5))
                DispatchQueue.main.async {
                    self.updateHourlyLabels(with: neededForecasts)
                }
            } catch {
                print("Error fetching weather data: \(error)")
            }
        }
    }
    
    func getDailyWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let dailyForecasts = weather.dailyForecast
                let neededForecasts = ArraySlice(dailyForecasts.prefix(7))
                DispatchQueue.main.async {
                    self.updateDailyLabels(with: neededForecasts)
                }
            } catch {
                print("Error fetching daily weather data: \(error)")
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            reverseGeocode(for: location)
            getHourlyWeather(for: location)
            getDailyWeather(for: location)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func reverseGeocode(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error)")
                return
            }
            
            if let placemark = placemarks?.first,
               let city = placemark.locality,
               let state = placemark.administrativeArea {
                DispatchQueue.main.async {
                    self?.locationLabel.text = "\(city), \(state)"
                }
            }
        }
    }
    
    func updateHourlyLabels(with forecasts: ArraySlice<HourWeather>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = TimeZone.current
        
        for (index, forecast) in forecasts.enumerated() {
            let tempF = forecast.temperature.value * 9 / 5 + 32
            let tempString = String(format: "%.0f°F", tempF)
            let precipitationString = String(format: "%.0f%%", forecast.precipitationChance * 100)
            let timeString = formatter.string(from: forecast.date)
            
            imageViews[index].image = UIImage(systemName: forecast.symbolName)
            currentTempLabels[index].text = tempString
            precipitationChanceLabels[index].text = precipitationString
            timeLabels[index].text = timeString
        }
    }
    
    func updateDailyLabels(with forecasts: ArraySlice<DayWeather>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        for (index, forecast) in forecasts.enumerated() {
            guard index < hiLabels.count else {break}
            
            let dayOfWeek = formatter.string(from: forecast.date)
            let tempHiF = forecast.highTemperature.value * 9 / 5 + 32
            let tempLoF = forecast.lowTemperature.value * 9 / 5 + 32
            let tempHi = String(format: "%.0f°F", tempHiF)
            let tempLo = String(format: "%.0f°F", tempLoF)
            let precipitationString = String(format: "%.0f%%", forecast.precipitationChance * 100)
            
            dayLabels[index].text = dayOfWeek
            hiLabels[index].text = tempHi
            loLabels[index].text = tempLo
            precipLabels[index].text = precipitationString
            dayImageViews[index].image = UIImage(systemName: forecast.symbolName)
            
        }
    }
}
