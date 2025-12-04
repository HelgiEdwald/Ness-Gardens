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
    
    //MARK: Initialising Variables
    
    //outlets
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    //user location
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var userLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    //variables to populate with decoded json data
    var bedList: bedRecords? = nil
    var plantList: plantRecords? = nil
    var imageList: imageRecords? = nil
    var trailList: trailRecords? = nil
    var trailLocationList: trailLocatationRecords? = nil
    var allPlants: [Plant] = []
    var alivePlants: [Plant] = []
    var bedArray: [Bed] = []
    var bedIdArray: [String] = []
    var bedToPlantDict: [String: [Plant]] = [:]
    var trailIdToLocationsDict: [String: [trailLocatation]] = [:]
    
    var trailArray: [Trail] = []
    var trailLocationArray: [trailLocatation] = []
    
    var trailCoordinateDict: [String:[CLLocationCoordinate2D]] = [:]
    
    //Booleans to check if JSON data has been decoded
    var bedsDecoded = false
    var plantsDecoded = false
    var imagesDecoded = true
    var trailsDecoded = false
    var trailLocationsDecoded = false
    
    //Variables to pass along to detail view controller
    var selectedPlant: Plant?
    var selectedPlantImage: UIImage?
    var selectedPlantImageFileName: String?
    var selectedImageFileNameArray: [String] = []

    //MARK: Map and Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        
        //generally we always want the first one (usually there's only 1 anyway)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude

        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        userLocation = location
        if firstRun {
            firstRun = false

            let latDelta: CLLocationDegrees = 0.0020
            let lonDelta: CLLocationDegrees = 0.0020

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
    
        
        DispatchQueue.main.async {
            
            //create a new bed array that is sorted by proximity to user
            let newSortedBedArray = self.sortBedArrayByProximity(arrayOfBeds: self.bedArray, userLatitude: latitude, userLongitude: longitude)
            var newBedIdArray: [String] = []
        
            //add bed id strings from elements from sorted bed arrray to new bedidarray to ensure no empty beds are in new array
            for bed in newSortedBedArray {
                if self.bedToPlantDict[bed.bed_id] != nil {
                    newBedIdArray.append(bed.bed_id)
                }
                
            }
            
            self.bedIdArray = newBedIdArray
            
            if self.bedsDecoded && self.plantsDecoded && self.imagesDecoded {
                self.updateTheTable()
            }
        }

    }

    //this method sets the startTrackingTheUser boolean class property to true. Once it's true,
    //subsequent calls to didUpdateLocations will cause the map to centre on the user's location.
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }
    
    //render overlay in map view
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        switch overlay {
        case let polyline as MKPolyline:
            
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
            
        default:
            fatalError("Unexpected MKOverlay type")
        }
    }

    //MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //set number of rows in each section to strings in values of bed to plant dictionary
        let currentBedId = bedIdArray[section]
        return bedToPlantDict[currentBedId]?.count ?? 0
        
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return bedIdArray.count

    }

    // Create a standard header that includes the returned text.
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        //display name of bed in header
        if bedsDecoded {
            let bedNameString = bedList?.beds.first(where: {$0.bed_id == bedIdArray[section]})?.name ?? "no name"
            
            return "Bed: \(bedNameString)"
        }
        else {
            return ""
        }
    }

    // Create a standard footer that includes the returned text.
    func tableView(_ tableView: UITableView, titleForFooterInSection
                                section: Int) -> String? {
        
        //display name of bed in footer
        if bedsDecoded {
            let bedNameString = bedList?.beds.first(where: {$0.bed_id == bedIdArray[section]})?.name ?? "no name"
            return "Bed: \(bedNameString)"
        } else {
            return ""
        }
    }

    //configure and return cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //cast to cell to custom tableview cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! NessGardensTableViewCell
        
        //get bed id with current section as index, get plants in that section, display all plants in that section as rows
        let currentBedId = bedIdArray[indexPath.section]
        
        guard let plantInSection = bedToPlantDict[currentBedId] else {
            return cell
        }
        
        let cellPlant = plantInSection[indexPath.row]
        
        //set thumbnail image to question mark initially to prevent reuse of image and flickering caused by user location changing
        cell.thumbnailImageView.image = UIImage(named: "no plant image")
        
        //display initial plant information
        cell.familyLabel?.text = cellPlant.family ?? "no family"
        cell.speciesLabel?.text = cellPlant.species ?? "no species"
        cell.genusLabel?.text = cellPlant.genus ?? "no genus"
        
        //set filled star as image of button for favourited plants, empty star for non-favourited plants
        if UserDefaults.standard.bool(forKey: "\(cellPlant.recnum)") {
            cell.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        //when button of custom table view cell is pressed, change favorite boolean in userdefaults for that plant's recnum
        cell.favButtonPressed = { [ weak self ] in
            if UserDefaults.standard.bool(forKey: "\(cellPlant.recnum)"){
                cell.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                UserDefaults.standard.set(false, forKey: "\(cellPlant.recnum)")
            }
            else {
                cell.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                UserDefaults.standard.set(true, forKey: "\(cellPlant.recnum)")
            }
        }
        
        //set thumbnail image to image loaded from url with the cellplant's image file name found in the decoded image data
        let imageFileName = imageList?.images.first(where: { $0.recnum == cellPlant.recnum })?.img_file_name ?? ""
        let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_thumbnails/\(imageFileName)"
        let url = URL(string: urlString)!
        cell.thumbnailImageView.load(url:url)
        
        return cell
    }
    
    //go to detail view controller to view selected plant
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get values from selected row
        let currentBedId = bedIdArray[indexPath.section]
        let plantInSection = bedToPlantDict[currentBedId]
        let cellPlant = plantInSection?[indexPath.row]
        
        //set empty variables to selected plant's structure and image file names
        selectedPlant = cellPlant
        selectedImageFileNameArray = imageList?.images.filter({$0.recnum == selectedPlant?.recnum}).map(\.img_file_name) ?? []
                
        performSegue(withIdentifier: "toDetail", sender: cellPlant)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            
            let detailViewController = segue.destination as! DetailViewController
            
            //pass data from main view controller to detail view controller
            detailViewController.receivedImageFileNameArray = selectedImageFileNameArray
            detailViewController.plantReceived = selectedPlant
            
            
        }
    }
    
    @IBAction func unwindToMainView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    //MARK: Actions
    //display information about trails with an alert if button near segmented control tapped
    @IBAction func questionMarkButtonTapped(_ sender: Any) {
        let alertMessage = """
        \(trailArray[0].Trail_Name)

        Description: \(trailArray[0].Description)
        Duration: \(trailArray[0].Duration)
        Difficulty: \(trailArray[0].Difficulty)
        Distance: \(trailArray[0].Distance)
        
        \(trailArray[1].Trail_Name)
        
        Description: \(trailArray[1].Description)
        Duration: \(trailArray[1].Duration)
        Difficulty: \(trailArray[1].Difficulty)
        Distance: \(trailArray[1].Distance)
        
        \(trailArray[2].Trail_Name)
        
        Description: \(trailArray[2].Description)
        Duration: \(trailArray[2].Duration)
        Difficulty: \(trailArray[2].Difficulty)
        Distance: \(trailArray[2].Distance)
        """
        let alert = UIAlertController(title: "Trail Information", message: alertMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //swap trails using segmented control index
    @IBAction func trailDidChange(_ sender: UISegmentedControl) {
               
        let trailIndex = sender.selectedSegmentIndex - 1
        
        if trailIndex >= 0 {
            drawTrail(coordinateArray: trailCoordinateDict[trailArray[trailIndex].ID]!)
            
        }
        else {
            myMap.removeOverlays(myMap.overlays)
        }
        
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
                    
                    DispatchQueue.main.async {
                        
                        //keep decoded data, add beds to bed array and their bed_id properties to string array
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

                    DispatchQueue.main.async {

                        if let list = self.plantList {
                            
                            self.filterOutDeadPlants(list: list)
                            self.populateBedToPlantDict()
                            self.addBedsToMap(bedArray: self.bedArray)
                            
                        }

                        self.updateTheTable()

                    }

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
                    
                    if self.bedsDecoded && self.plantsDecoded && self.imagesDecoded {
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
    
    func decodeTrailData() {
        
        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=trails") {
            
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
                    let trailData = try decoder.decode(trailRecords.self, from: jsonData)
                    
                    self.trailList = trailData
                    self.trailLocationsDecoded = true

                    DispatchQueue.main.async {

                        if let list = self.trailList {
                            
                            for trail in list.trails {
                                
                                self.trailArray.append(trail)
                                
                            }
                            
                            
                        }

                        self.updateTheTable()

                    }

                }
                
                //catch error when data does not match structure
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("decoding trail data")
        }

    }

    func decodeTrailLocationData() {
        
        //set up the URL
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=trail_locations") {
            
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
                    let trailLocationData = try decoder.decode(trailLocatationRecords.self, from: jsonData)
                    
                    self.trailLocationList = trailLocationData
                    

                    DispatchQueue.main.async {

                        if let list = self.trailLocationList {
                          
                            //set values in coordinate dictionary to coordinates made from trail location lats and lons with trail id as keys
                            for trail_location in list.trail_locations {
                                if self.trailCoordinateDict[trail_location.Trail_ID] == nil {
                                    self.trailCoordinateDict[trail_location.Trail_ID] = [CLLocationCoordinate2D(latitude: Double(trail_location.Latitude)!, longitude: Double(trail_location.Longitude)!)]
                                } else {
                                    self.trailCoordinateDict[trail_location.Trail_ID]!.append(CLLocationCoordinate2D(latitude: Double(trail_location.Latitude)!, longitude: Double(trail_location.Longitude)!))
                                }
                                
                                
                                
                            }
                            self.trailLocationsDecoded = true
                            self.mySegmentedControl.isEnabled = true
                            
                        }

                        self.updateTheTable()

                    }

                }
                
                //catch error when data does not match structure
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("decoding trail location data")
        }
        
    }
    
    //MARK: helper functions
    
    //function to add plants to total array and to filtered array if they are still present and alive in Ness Gardens
    func filterOutDeadPlants(list: plantRecords) {
        
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
    }
    
    //function to populate a dictionary used for the table view so where beds are mapped to all the plants in that bed
    func populateBedToPlantDict() {
        
        for aPlant in self.alivePlants {
            let bedList = aPlant.bed ?? ""
            let bedArray = bedList.components(
                separatedBy: .whitespaces
            )

            for aBed in bedArray {
                if self.bedIdArray.contains(aBed) {
                    var currentBedPlantArray =
                        self.bedToPlantDict[aBed] ?? []
                    currentBedPlantArray.append(aPlant)
                    self.bedToPlantDict[aBed] =
                        currentBedPlantArray
                }

            }
            
        }
        
    }

    //function to add bed locations to map as annotations
    func addBedsToMap(bedArray: [Bed]) {

        for bed in bedArray {
            
            //filter out beds with no plants
            if bedToPlantDict[bed.bed_id] != nil {
                let coordinate = CLLocationCoordinate2D(latitude: Double(bed.latitude)! , longitude: Double(bed.longitude)!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = bed.name
                self.myMap.addAnnotation(annotation)
            }
            
        }
        
    }
    
    //function to sort a bed array by proximity to a locataion
    func sortBedArrayByProximity(arrayOfBeds: [Bed], userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees) -> Array<Bed>{
        
        //new array where parametered array is sorted by distance to parametered user location
        let sortedBedArray = arrayOfBeds.sorted { (bed1, bed2) -> Bool in
            
            let bed1location = CLLocation(latitude: Double(bed1.latitude)!, longitude: Double(bed1.longitude)!)
            let bed2location = CLLocation(latitude: Double(bed2.latitude)!, longitude: Double(bed2.longitude)!)
            
            let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
            
            return bed1location.distance(from: userLocation) < bed2location.distance(from: userLocation)
            
        }
        
        return sortedBedArray
        
    }
    
    //function to reload table data
    func updateTheTable() {
            myTable.reloadData()
        }
    
    //function to draw trail
    func drawTrail(coordinateArray: [CLLocationCoordinate2D]) {
        myMap.removeOverlays(myMap.overlays)
        let polyline = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        print("polyline", polyline)
        print("arrayLength: ", coordinateArray.count)
        myMap.addOverlay(polyline)
    }
    
    //MARK: View related stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mySegmentedControl.isEnabled = false
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

        //decode JSON data
        decodeBedData()
        decodePlantData()
        decodeImageData()
        decodeTrailData()
        decodeTrailLocationData()
        

    }
}
