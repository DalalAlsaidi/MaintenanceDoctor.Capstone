//
//  MapVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2022/1/4.
//

import UIKit
import GoogleMaps

class MapVC: BaseViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map".localized
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func onClickOK(_ sender: Any) {
        if my_address.isEmpty {
            showToast("Please select your location".localized)
            return
        }
        doDismiss()
    }
}
//MARK: -- LocaitonManager delegate Extension
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        guard status == .authorizedWhenInUse else {
          return
        }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animate(to: mapView.camera)
        locationManager.stopUpdatingLocation()
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
        guard let address = response?.firstResult(), let lines = address.lines else {
            return
        }
//            myAddress = lines.joined(separator: "\n")
//            serviceLocation = lines.joined(separator: "\n")
//            myLat = address.coordinate.latitude
//            myLng = address.coordinate.longitude
            
        }
    }
    
    func locationManager( _ manager: CLLocationManager, didFailWithError error: Error ) {
        print(error)
      }
}
//MARK: --Google Map delegate Extension
extension MapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
        
        print("position: ", position)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Clicked")
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        //Creating Marker
        let marker = GMSMarker(position: coordinate)

        let decoder = CLGeocoder()

        //This method is used to get location details from coordinates
        decoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, err in
            if let placeMark = placemarks?.first {

                let placeName = placeMark.name ?? placeMark.subThoroughfare ?? placeMark.thoroughfare!   ///Title of Marker
                //Formatting for Marker Snippet/Subtitle
                var address : String! = ""
                if let subLocality = placeMark.subLocality ?? placeMark.name {
                    address.append(subLocality)
                    address.append(", ")
                }
                if let city = placeMark.locality ?? placeMark.subAdministrativeArea {
                    address.append(city)
                    address.append(", ")
                }
                if let state = placeMark.administrativeArea, let country = placeMark.country {
                    address.append(state)
                    address.append(", ")
                    address.append(country)
                }
                // Adding Marker Details
                marker.title = placeName
                marker.snippet = address
                marker.appearAnimation = .pop
                marker.map = mapView
                my_address = address
                my_lat = coordinate.latitude
                my_long = coordinate.longitude
            }
        }
    }
}

