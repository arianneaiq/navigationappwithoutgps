//
//  SwiftUIView.swift
//  NagivitionApp
//
//  Created by Arianne Xaing on 11/03/2023.
//

import SwiftUI
import MapKit
import Combine

struct MapView: UIViewRepresentable {
    
    // Declare a StateObject of the LocationManager class to handle location updates
    @StateObject var locationManager = LocationManager()
    
    // Declare a CLLocation object for the Klokgebouw location
    let klokgebouwLocation = CLLocation(latitude: 51.44896327756864, longitude: 5.458107710449188)
    

    // MARK: - UIViewRepresentable functions
    
    // A function that creates a new instance of MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.delegate = context.coordinator
        // Show the user's location with a blue dot and arrow
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isUserInteractionEnabled = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        // Create an instance of MKUserTrackingButton and add it to the map view
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        mapView.addSubview(userTrackingButton)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16)
        ])
        return mapView
    }
    
    // Define a function that creates a Coordinator object to handle map view events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Define a Coordinator class that conforms to the MKMapViewDelegate protocol
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.markerTintColor = annotation.title == "Klokgebouw" ? .red : .blue
            return pin
        }
        
        // Add renderer for the blue line
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        addAnnotations(to: mapView)
        locationManager.startUpdatingLocation { location in
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: true)
            //mapView.removeOverlays(mapView.overlays)
            displayRoute(from: location, to: klokgebouwLocation, on: mapView)
            
        }
    }
    
    func addAnnotations(to mapView: MKMapView) {
        let klokgebouwAnnotation = MKPointAnnotation()
        klokgebouwAnnotation.coordinate = klokgebouwLocation.coordinate
        klokgebouwAnnotation.title = "Klokgebouw"
        mapView.addAnnotation(klokgebouwAnnotation)
    }
    
    func displayRoute(from source: CLLocation, to destination: CLLocation, on mapView: MKMapView) {
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else { return }
            mapView.addOverlay(route.polyline)
        }
    }
    
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
