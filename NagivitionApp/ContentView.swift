//
//  ContentView.swift
//  NagivitionApp
//
//  Created by Arianne Xaing on 09/03/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
            
            if let location = locationManager.lastKnownLocation {
                let klokgebouwLocation = CLLocation(latitude: 51.44896327756864, longitude: 5.458107710449188)
                let distance = Int(location.distance(from: klokgebouwLocation))
                Text("Distance to Klokgebouw: \(distance) meters")
                
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
