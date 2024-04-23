//
//  FavoritesViewController.swift
//  Nimbus
//
//  Created by Jacob Raeside on 3/9/24.
//

import UIKit
import CoreLocation
import WeatherKit

class FavoritesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var locationLabel1: UILabel!
    @IBOutlet weak var tempLabel1: UILabel!
    @IBOutlet weak var hiTempLabel1: UILabel!
    @IBOutlet weak var loTempLabel1: UILabel!
    @IBOutlet weak var conditionImage1: UIImageView!
    @IBOutlet weak var chooseForecastButton1: UIButton!
    
    @IBOutlet weak var locationLabel2: UILabel!
    @IBOutlet weak var tempLabel2: UILabel!
    @IBOutlet weak var hiTempLabel2: UILabel!
    @IBOutlet weak var loTempLabel2: UILabel!
    @IBOutlet weak var conditionImage2: UIImageView!
    @IBOutlet weak var chooseForecastButton2: UIButton!
    
    @IBOutlet weak var locationLabel3: UILabel!
    @IBOutlet weak var tempLabel3: UILabel!
    @IBOutlet weak var hiTempLabel3: UILabel!
    @IBOutlet weak var loTempLabel3: UILabel!
    @IBOutlet weak var conditionImage3: UIImageView!
    @IBOutlet weak var chooseForecastButton3: UIButton!
    
    @IBOutlet weak var locationLabel4: UILabel!
    @IBOutlet weak var tempLabel4: UILabel!
    @IBOutlet weak var hiTempLabel4: UILabel!
    @IBOutlet weak var loTempLabel4: UILabel!
    @IBOutlet weak var conditionImage4: UIImageView!
    @IBOutlet weak var chooseForecastButton4: UIButton!
    
    @IBOutlet weak var locationLabel5: UILabel!
    @IBOutlet weak var tempLabel5: UILabel!
    @IBOutlet weak var hiTempLabel5: UILabel!
    @IBOutlet weak var loTempLabel5: UILabel!
    @IBOutlet weak var conditionImage5: UIImageView!
    @IBOutlet weak var chooseForecastButton5: UIButton!
    
    @IBOutlet var locationLabels: [UILabel]!
    @IBOutlet var tempLabels: [UILabel]!
    @IBOutlet var hiLabels: [UILabel]!
    @IBOutlet var loLabels: [UILabel]!
    @IBOutlet var conditionImages: [UIImageView]!
    
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var deleteFavoriteButton: UIButton!
    
    let locationManager = CLLocationManager()
    let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationPicker.dataSource = self
        locationPicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationPicker.reloadAllComponents()
        updateWeatherForFavorites()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FavoritesData.shared.favoritesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let location = FavoritesData.shared.favoritesList[row]
        return "\(location.city), \(location.state)"
    }
    
    @IBAction func chooseForecastButton(_ sender: UIButton) {
        let buttonIndex = sender.tag
        guard buttonIndex < FavoritesData.shared.favoritesList.count else { return }
        
        let selectedLocation = FavoritesData.shared.favoritesList[buttonIndex]
        FavoritesData.shared.selectedLocation = selectedLocation
    }
    
    @IBAction func deleteFavoritesButton(_ sender: UIButton) {
        let selectedRow = locationPicker.selectedRow(inComponent: 0)
        guard selectedRow < FavoritesData.shared.favoritesList.count else { return }
        
        let location = FavoritesData.shared.favoritesList[selectedRow]
        FavoritesData.shared.removeFavorite(city: location.city, state: location.state)
        
        locationPicker.reloadAllComponents()
        
        updateWeatherForFavorites()
    }
    
    func updateWeatherForFavorites() {
        let favorites = FavoritesData.shared.favoritesList
        for index in 0..<5 {
            if index < favorites.count {
                let locationName = "\(favorites[index].city), \(favorites[index].state)"
                searchLocationAndGetWeather(for: locationName, index: index)
            } else {
                DispatchQueue.main.async {
                    self.hideUIElements(index: index)
                }
            }
        }
    }
    
    func hideUIElements(index: Int) {
        let locationLabels = [locationLabel1, locationLabel2, locationLabel3, locationLabel4, locationLabel5]
        let tempLabels = [tempLabel1, tempLabel2, tempLabel3, tempLabel4, tempLabel5]
        let hiTempLabels = [hiTempLabel1, hiTempLabel2, hiTempLabel3, hiTempLabel4, hiTempLabel5]
        let loTempLabels = [loTempLabel1, loTempLabel2, loTempLabel3, loTempLabel4, loTempLabel5]
        let conditionImages = [conditionImage1, conditionImage2, conditionImage3, conditionImage4, conditionImage5]
        let chooseForecastButtons = [chooseForecastButton1, chooseForecastButton2, chooseForecastButton3, chooseForecastButton4, chooseForecastButton5]
        
        locationLabels[index]?.isHidden = true
        tempLabels[index]?.isHidden = true
        hiTempLabels[index]?.isHidden = true
        loTempLabels[index]?.isHidden = true
        conditionImages[index]?.isHidden = true
        chooseForecastButtons[index]?.isHidden = true
    }
    
    func searchLocationAndGetWeather(for locationName: String, index: Int) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            guard let location = placemarks?.first?.location else { return }
            self.getWeather(for: location, index: index)
        }
    }
    
    func getWeather(for location: CLLocation, index: Int) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let currentWeather = weather.currentWeather
                let dayWeather = weather.dailyForecast
                let neededDayForecasts = ArraySlice(dayWeather.prefix(1))
                DispatchQueue.main.async {
                    self.updateUI(with: currentWeather, and: neededDayForecasts, at: index)
                    }
                } catch {
                print("Error getting weather data: \(error)")
            }
        }
    }
    
    func updateUI(with currForecast: CurrentWeather, and dayForecast: ArraySlice<DayWeather>, at index: Int) {
        let locationLabels = [locationLabel1, locationLabel2, locationLabel3, locationLabel4, locationLabel5]
        let tempLabels = [tempLabel1, tempLabel2, tempLabel3, tempLabel4, tempLabel5]
        let hiTempLabels = [hiTempLabel1, hiTempLabel2, hiTempLabel3, hiTempLabel4, hiTempLabel5]
        let loTempLabels = [loTempLabel1, loTempLabel2, loTempLabel3, loTempLabel4, loTempLabel5]
        let conditionImages = [conditionImage1, conditionImage2, conditionImage3, conditionImage4, conditionImage5]
        let chooseForecastButtons = [chooseForecastButton1, chooseForecastButton2, chooseForecastButton3, chooseForecastButton4, chooseForecastButton5]
        
        let location = FavoritesData.shared.favoritesList[index]
        locationLabels[index]?.text = "\(location.city), \(location.state)"
        let tempF = currForecast.temperature.value * 9 / 5 + 32
        let tempHiF = dayForecast[0].highTemperature.value * 9 / 5 + 32
        let tempLoF = dayForecast[0].lowTemperature.value * 9 / 5 + 32
        tempLabels[index]?.text = String(format: "%.0f°F", tempF)
        hiTempLabels[index]?.text = String(format: "Hi: %.0f°F", tempHiF)
        loTempLabels[index]?.text = String(format: "Lo: %.0f°F", tempLoF)
        conditionImages[index]?.image = UIImage(systemName: currForecast.symbolName)
        
        locationLabels[index]?.isHidden = false
        tempLabels[index]?.isHidden = false
        hiTempLabels[index]?.isHidden = false
        loTempLabels[index]?.isHidden = false
        conditionImages[index]?.isHidden = false
        chooseForecastButtons[index]?.isHidden = false
    }
}
