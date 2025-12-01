//
//  ViewController.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 20/11/2025.
//

import MapKit
import UIKit

class ViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate
{

    //MARK: Outlets
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var myMap: MKMapView!

    //MARK: Variables
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var plantList: plantRecords? = nil
    var allPlants: [Plant] = []
    var alivePlants: [Plant] = []
    var imageList: imageRecords? = nil
    var bedList: bedRecords? = nil
    var bedArray: [Bed] = []
    var bedsDecoded = false
    var plantsDecoded = false
    var imagesDecoded = true

    var plantDict: [String: String] = [:]
    var imageDict: [String: UIImage] = [:]
    var bedDict: [String: [String]] = [:]

    var bedIdArray: [String] = []

    var bedToRecnumDict: [String: [Plant]] = [:]

    //MARK: Map and Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        
        //generally we always want the first one (usually there's only 1 anyway)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude

        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun {
            firstRun = false

            let latDelta: CLLocationDegrees = 0.0010
            let lonDelta: CLLocationDegrees = 0.0010

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

    //MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentBedId = bedIdArray[section]
        return bedToRecnumDict[currentBedId]?.count ?? 0
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return bedIdArray.count

    }

    // Create a standard header that includes the returned text.
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        return "Bed Name: \(bedList?.beds[section].bed_id ?? "no id")"
    }

//    // Create a standard footer that includes the returned text.
//    func tableView(_ tableView: UITableView, titleForFooterInSection
//                                section: Int) -> String? {
//        return "Bed Name: \(bedList?.beds[section].bed_id ?? "no id")"
//    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! NessGardensTableViewCell
        cell.thumbnailImageView.image = nil

        let currentBedId = bedIdArray[indexPath.section]
        
        guard let plantInSection = bedToRecnumDict[currentBedId] else {
            return cell
        }
        
        let cellPlant = plantInSection[indexPath.row]
        
        cell.recnumLabel.text = cellPlant.recnum
        cell.familyLabel.text = cellPlant.family
        cell.speciesLabel.text = cellPlant.species
        
        let imageFileName = imageList?.images.first(where: { $0.recnum == cellPlant.recnum })?.img_file_name ?? ""
        
        let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_thumbnails/\(imageFileName)"
        let url = URL(string: urlString)!
        
        cell.thumbnailImageView.load(url:url)
        
        return cell
    }

    //MARK: Decoding JSON data
    func decodeBedData() {
        
        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=beds") {
            
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
                    let bedData = try decoder.decode(bedRecords.self, from: jsonData)
                    self.bedList = bedData
                    
                    self.bedsDecoded = true
                    print(
                        "B",
                        self.bedsDecoded,
                        "P",
                        self.plantsDecoded,
                        "I",
                        self.imagesDecoded
                    )
                    DispatchQueue.main.async {
                        
                        if let list = self.bedList {
                            for bed in list.beds {
                                if self.bedArray.isEmpty {
                                    self.bedArray.insert(bed, at: 0)
                                } else {
                                    self.bedArray.append(bed)
                                }
                                if self.bedIdArray.isEmpty {
                                    self.bedIdArray.insert(bed.bed_id, at: 0)
                                } else {
                                    self.bedIdArray.append(bed.bed_id)
                                }
                                
                            }
                            self.updateTheTable()
                        }
                    }
                    
                }
                
                //catch error when data does not match structure
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                
            }.resume()
            print("decoding bed data")
        }
        
    }

    ///

    func decodePlantData() {

        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=plants") {
            
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
                    
                    self.plantList = plantData
                    self.plantsDecoded = true
                    print(
                        "B",
                        self.bedsDecoded,
                        "P",
                        self.plantsDecoded,
                        "I",
                        self.imagesDecoded
                    )

                    DispatchQueue.main.async {

                        if let list = self.plantList {
                            for plant in list.plants {
                                if self.allPlants.isEmpty {
                                    self.allPlants.insert(plant, at: 0)
                                } else {
                                    self.allPlants.append(plant)
                                }
                                if plant.accsta == "C" {
                                    if self.alivePlants.isEmpty {
                                        self.alivePlants.insert(plant, at: 0)

                                    } else {
                                        self.alivePlants.append(plant)
                                    }

                                }
                            }
                            for aPlant in self.alivePlants {
                                let bedList = aPlant.bed ?? ""
                                let bedArray = bedList.components(
                                    separatedBy: .whitespaces
                                )

                                for aBed in bedArray {
                                    if self.bedIdArray.contains(aBed) {
                                        var currentBedPlantArray =
                                            self.bedToRecnumDict[aBed] ?? []
                                        currentBedPlantArray.append(aPlant)
                                        self.bedToRecnumDict[aBed] =
                                            currentBedPlantArray
                                    }

                                }

                            }

                        }

                        self.updateTheTable()

                    }
                    print("processing completed")

                }
                
                //catch error when data does not match structure
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("decoding plant data")
        }

    }

    func decodeImageData() {
        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=images") {
            
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
                    let imageData = try decoder.decode(
                        imageRecords.self,
                        from: jsonData
                    )
                    self.imageList = imageData

                    self.imagesDecoded = true
                    print(
                        "B",
                        self.bedsDecoded,
                        "P",
                        self.plantsDecoded,
                        "I",
                        self.imagesDecoded
                    )
                    if self.bedsDecoded && self.plantsDecoded
                        && self.imagesDecoded
                    {
                        DispatchQueue.main.async {
                            self.updateTheTable()
                        }
                    }

                    
                }
                
                //catch error when data does not match structure
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("decoding image data")
        }
    }

    func retrieveImageData(imageFileName: String) {
        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_thumbnails/\(imageFileName)") {
            
            //create a URL session running on a background thread
            let session = URLSession.shared

            //create a data task supplied with the URL returning a tuple of the data we want, a response code from the data server, and any error message
            session.dataTask(with: url) { (data, response, err) in
                //try to get at data
                guard let imageData = data else {
                    return
                }

                //decode data if accessed ok
                do {
                    let imageRetrieved = UIImage(data: imageData)
                    self.imageDict[imageFileName] = imageRetrieved

                    DispatchQueue.main.async {
                        self.updateTheTable()
                    }

                }
            }.resume()
            print("You are here!")
        }
    }

    func updateTheTable() {
        myTable.reloadData()
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

        decodeBedData()

        decodePlantData()

        decodeImageData()

    }
}
