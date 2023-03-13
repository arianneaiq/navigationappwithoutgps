import Foundation
import CoreLocation
import AVFoundation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    private var audioPlayer: AVAudioPlayer?
    
    
    @Published var lastKnownLocation: CLLocation? = nil
    @Published var heading: Double? = nil
    private var locationCallback: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10.0
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.startMonitoringSignificantLocationChanges()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func startUpdatingLocation(withCallback callback: @escaping (CLLocation) -> Void) {
        self.locationCallback = callback
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
        
    func stopUpdatingLocation() {
        self.locationCallback = nil
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastKnownLocation = location
        self.locationCallback?(location)
        
        // Calculate the distance from the Klokgebouw
        let klokgebouwLocation = CLLocation(latitude: 51.44896327756864, longitude: 5.458107710449188)
        let distance = location.distance(from: klokgebouwLocation)
        
        // Adjust the tempo of the audio based on the distance
        var beatsPerMinute = 60.0
        if distance < 100 {
            beatsPerMinute = 120.0
        } else if distance < 500 {
            beatsPerMinute = 90.0
        } else {
            beatsPerMinute = 60.0
        }
        
        // Play the audio with the adjusted tempo
        if let audioURL = Bundle.main.url(forResource: "AppleAirtagSoundEffect", withExtension: "mp3") {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.enableRate = true
                audioPlayer.rate = Float(beatsPerMinute / 60.0)
                audioPlayer.play()
                self.audioPlayer = audioPlayer
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.trueHeading)
        heading = newHeading.trueHeading
    }
}
