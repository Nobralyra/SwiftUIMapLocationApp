//
//  ContentView.swift
//  SwiftUIMapLocationApp
//
//  Created by admin on 28/09/2020.
//

import SwiftUI
import MapKit

struct ContentView: View
{
    
    var body: some View
    {
        // $ er en binidng, som sørger for at update @State region, mens man bruger kortet
        //Map(coordinateRegion: $region)
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// First with Full Accuracy

struct Home: View
{
    // @State to directs the center of the map and how much of the area around is visible around the map (zoom level)
    // MKCoordinateRegion(center:span:) - hvor centrum er og hvor meget der kan ses rundt om det
    // For center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
    // For span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
   
    @State var tracking : MapUserTrackingMode = .follow
    
    @State var manager = CLLocationManager()
    
    @StateObject var managerDelegate = locationDelegate()
    
    var body: some View
    {
        VStack
        {
            //Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking)
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: managerDelegate.pins)
            {
                pin in
                MapPin(coordinate: pin.location.coordinate, tint: .red)
            }
        }
        .onAppear
        {
            manager.delegate = managerDelegate
        }
    }
}


// Location manager delegate
// Now when precise location is not turned on
class locationDelegate : NSObject, ObservableObject, CLLocationManagerDelegate
{
    @Published var pins : [Pin] = []
    // Checking authorization status
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        // we're going to use only when in use Key only
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            print("Authorized..")
            
            // setting reduced accuracy to false and updating locations
            
            // checking whether precise location is turned on
            if manager.accuracyAuthorization != .fullAccuracy
            {
                print("reduced accuracy")
                
                // requesting temporary accuracy
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location")
                {
                    (error) in
                    if error != nil
                    {
                        print(error!)
                        return
                    }
                }
            }
            manager.startUpdatingLocation()
        }
        else
        {
            print("No authorized")
            // requesting acces
            
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        pins.append(Pin(location: locations.last!))
    }
}

//Map pins for updates

struct Pin: Identifiable
{
    var id = UUID().uuidString
    var location: CLLocation
}
