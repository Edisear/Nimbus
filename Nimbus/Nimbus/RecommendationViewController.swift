//
//  RecommendationViewController.swift
//  Nimbus
//
//  Created by Jacob Raeside on 3/9/24.
//

import UIKit
import WeatherKit
import CoreLocation

class RecommendationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var recLabel: UILabel!
    @IBOutlet weak var recImage: UIImageView!
    
    let weatherService = WeatherService()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            getWeatherRec(for: location)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let placemark = placemarks?.first,
                   let city = placemark.locality,
                   let state = placemark.administrativeArea {
                    DispatchQueue.main.async {
                        self?.locationTitleLabel.text = "Recommendations for \(city), \(state)"
                        }
                    }
                }
            }
        }
    
    func getWeatherRec(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let currentWeather = weather.currentWeather
                DispatchQueue.main.async {
                    self.updateLabels(with: currentWeather)
                }
            } catch {
                print("Error fetching weather data: \(error)")
            }
        }
    }
    
    func updateLabels(with currForecast: CurrentWeather) {
        let conditionString = currForecast.condition.description.lowercased()
        var recString = ""
        var imageChoice = "clear"
        
        switch currForecast.condition {
        case .clear, .mostlyClear:
             recString = "Enjoy the beautiful clear skies today! It's a perfect time for outdoor activities like hiking, biking, or simply taking a leisurely walk in the park. Don't forget to apply sunscreen if you plan to be out for long."
            imageChoice = "clear"
        case .cloudy, .mostlyCloudy, .partlyCloudy:
             recString = "With the sky covered in clouds, today might feel a bit cooler. It's a great opportunity to explore outdoor markets or enjoy a coffee at an outdoor café without the worry of direct sunlight."
            imageChoice = "cloudy"
        case .drizzle, .rain, .heavyRain, .sunShowers:
             recString = "Looks like it's a rainy day. A good time to catch up on indoor activities. Consider visiting a museum, enjoying a good book at your favorite café, or having a movie marathon at home. If you're out, don't forget your umbrella!"
            imageChoice = "rain"
        case .flurries, .snow, .heavySnow, .blowingSnow, .sunFlurries, .wintryMix, .sleet, .freezingRain, .freezingDrizzle:
             recString = "Snow is falling! Whether it's light flurries or a heavy snowfall, consider winter sports like skiing or snowboarding if you're near suitable locations. In the city? Snowy days are perfect for building snowmen or having snowball fights. Dress warmly!"
            imageChoice = "snow"
        case .blizzard, .hurricane, .tropicalStorm, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
             recString = "Extreme weather conditions are expected. It's best to stay indoors if possible and follow any advisories from local weather stations and on the search page of Nimbus. Keep emergency kits ready and stay informed on the latest weather updates."
            imageChoice = "extreme"
        case .breezy, .windy:
             recString = "With the wind picking up, it might be a good day for flying kites at the park. However, be mindful of stronger gusts which could make some outdoor activities less enjoyable. Secure any loose items if you're at home."
            imageChoice = "wind"
        case .foggy, .haze, .smoky, .blowingDust:
             recString = "Fog, haze, or dust might reduce visibility today. If driving, ensure your lights are on and maintain a safe distance from other vehicles. It could be a mystical time for photography or a quiet day for reflection indoors."
            imageChoice = "fog"
        case .frigid:
             recString = "With frigid temperatures, it's important to stay warm. A great day for warm beverages, cozying up with a blanket, or enjoying indoor activities. Ensure you're dressed in layers if you need to step outside."
            imageChoice = "cold"
        case .hot:
             recString = "The heat is on! Stay hydrated, wear light clothing, and try to stay indoors during peak sun hours. It's a perfect time for swimming or enjoying chilled treats like ice cream."
            imageChoice = "hot"
        case .hail:
             recString = "Hail can be both fascinating and dangerous. Best to stay indoors to avoid injury. It's a rare opportunity to witness this kind of weather, so watch safely from a window and protect any vehicles if possible."
            imageChoice = "hail"
        default:
            print("Unkown value")
        }

        
        recLabel.text = "The current weather condition is \(conditionString). \(recString)"
        recImage.image = UIImage(named: imageChoice)
                
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
                self.getWeatherRec(for: location)
            }
            
            if let placemark = placemarks?.first,
                let city = placemark.locality,
                let state = placemark.administrativeArea {
                DispatchQueue.main.async {
                    self.locationTitleLabel.text = "Recommendations for \(city), \(state)"
                }
            }
        }
    }
}
