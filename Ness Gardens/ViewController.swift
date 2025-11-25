//
//  ViewController.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 20/11/2025.
//

import UIKit
import MapKit

nonisolated
struct plantRecords : Decodable {
    let plants: [Plant]
}

//MARK: Create decodable structure matching JSON data
nonisolated
struct Plant : Decodable {
    let recnum : String
    let acid : String?
    let accsta : String?
    let family: String?
    let genus : String?
    let species : String?
    let infraspecificEpithet : String?
    let vernacularName: String?
    let cultivarName : String?
    let donor : String?
    let latitude, longitude: String?
    let country, iso, sgu, loc: String?
    let alt, cnam, cid, cdat: String?
    let bed, memoriam: String?
    let redlist: String?
    let last_modified: String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    //MARK: Outlets
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var myMap: MKMapView!
    
    //MARK: Variables
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        
        //generally we always want the first one (usually there's only 1 anyway)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        
        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun {
            firstRun = false
        
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            
            //a span defines how large an area is depicted on the map.
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            //a region defines a centre and a size of area covered.
            let region = MKCoordinateRegion(center: location, span: span)
            
            //make the map show that region we just defined.
            self.myMap.setRegion(region, animated: true)
            
            //the following code is to prevent a bug which affects the zooming of the map to the user's location.
            //We have to leave a little time after our initial setting of the map's location and span,
            //before we can start centering on the user's location, otherwise the map never zooms in because the
            //intial zoom level and span are applied to the setCenter( ) method call, rather than our "requested" ones,
            //once they have taken effect on the map.
            //we setup a timer to set our boolean to true in 5 seconds.
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:
                                        #selector(startUserTracking), userInfo: nil, repeats: false)
            
        }
        
        if startTrackingTheUser == true {
            myMap.setCenter(location, animated: true)
        }
        
    }
    
    //this method sets the startTrackingTheUser boolean class property to true. Once it's true,
    //subsequent calls to didUpdateLocations will cause the map to centre on the user's location.
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = "testing"
        content.secondaryText = "more testing"
        cell.contentConfiguration = content
        return cell
    }
    
    func decodeDataFromURL(String: String) {
        
        //set up the URL
        if let url = URL(string: String) {
            
            //create a URL session running on a background thread
            let session = URLSession.shared
            
            //create a data task supplied with the URL returning a tuple of the data we want, a response code from the data server, and any error message
            session.dataTask(with: url) { (data, response, err) in
                //try to get at data
                guard let jsonData = data else {
                    return
                }
                //decode data if accessed ok
                do {
                    let decoder = JSONDecoder()
                    let plantData = try decoder.decode(plantRecords.self, from: jsonData)
                    var count = 0
                    for aPlant in plantData.plants {
                        count += 1
                        let theFamily = aPlant.family ?? "no family"
                        let theSpecies = aPlant.species ?? "no species"
                        print("\(count) + \(theFamily) + \(theSpecies)")
                    }
                
                //catch error when data does not match structure
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("You are here!")
        }
        
    }
    
    //MARK: View related stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        // Make this view controller a delegate of the Location Manager, so that it
        //is able to call functions provided in this view controller.
        locationManager.delegate = self as CLLocationManagerDelegate
        
        //set the level of accuracy for the user's location.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //Ask the location manager to request authorisation from the user. Note that this
        //only happens once if the user selects the "when in use" option. If the user
        //denies access, then your app will not be provided with details of the user's
        //location.
        locationManager.requestWhenInUseAuthorization()
        
        //Once the user's location is being provided then ask for updates when the user
        //moves around.
        locationManager.startUpdatingLocation()
        
        //configure the map to show the user's location (with a blue dot).
        myMap.showsUserLocation = true
        
        let url = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=plants"
        
        decodeDataFromURL(String: url)
        

    }
}
