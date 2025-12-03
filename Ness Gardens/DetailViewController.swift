//
//  DetailViewController.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 01/12/2025.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var plantImageView1: UIImageView!
    @IBOutlet weak var plantMapView: MKMapView!
    @IBOutlet weak var plantTextView: UITextView!
    @IBOutlet weak var previousImageButton: UIButton!
    @IBOutlet weak var nextImageButton: UIButton!
    
    //MARK: Variables passed along from main view controller
    var plantReceived: Plant?
    var selectedPlantImage: UIImage?
    var receivedImageFileNameArray: [String] = []
    
    //set image index to first element
    var currentImageIndex = 0

    //unwind to main view controller if back button pressed
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMain", sender: nil)
    }
    
    func disableAndHideButtons() {
        
        previousImageButton.isUserInteractionEnabled = false
        nextImageButton.isUserInteractionEnabled = false
        previousImageButton.isHidden = true
        nextImageButton.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plantTextView.text.append("\n\n")
        
        if let familyString = plantReceived?.family, !familyString.isEmpty {
            plantTextView.text.append("Family: \(familyString)\n\n")
        }
        else {
            plantTextView.text.append("Family: No family\n\n")
        }
        
        if let genusString = plantReceived?.genus, !genusString.isEmpty {
            plantTextView.text.append("Genus: \(genusString)\n\n")
        }
        else {
            plantTextView.text.append("Genus: No genus\n\n")
        }
        
        if let speciesString = plantReceived?.species, !speciesString.isEmpty {
            plantTextView.text.append("Species: \(speciesString)\n\n")
        }
        else {
            plantTextView.text.append("Species: No species\n\n")
        }
        
        
        if let countryString = plantReceived?.country, !countryString.isEmpty {
            plantTextView.text.append("Country: \(countryString)\n\n")
        }
        else {
            plantTextView.text.append("Country: No country\n\n")
        }
        
        
        //display images if image file name array has elements in it
        if !receivedImageFileNameArray.isEmpty {
            
            let imageFileName = receivedImageFileNameArray[currentImageIndex]
            let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(imageFileName)"
            let url = URL(string: urlString)!
            plantImageView1.load(url:url)
            
            //disable and hide buttons if there is only 1 image file name
            if receivedImageFileNameArray.count == 1 {
                disableAndHideButtons()
            }
        }
        
        //show question mark image if there are no elements in image file name array and disable/hide buttons
        else {
            
            plantImageView1.image = UIImage(named: "no plant image")
            
            disableAndHideButtons()
            
        }

        //show map view with annotation if received plant has non-nil latitude
        if let lat = plantReceived?.latitude, !lat.isEmpty {
            let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            guard let lon = plantReceived?.longitude else { return }
            guard let latitude = Double(lat) else { return }
            guard let longitude = Double(lon) else { return }
            let coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            plantMapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: coordinate, span: span)
            plantMapView.setRegion(region, animated: true)
        }
        else {
            plantMapView.isHidden = true
        }
        
    }
    
    @IBAction func previousImageButtonTapped(_ sender: Any) {
        
        //decrement array index, set to length of array minus one if index is equal to 0
        if currentImageIndex != 0 {
            currentImageIndex = currentImageIndex - 1
        } else {
            currentImageIndex = receivedImageFileNameArray.count - 1
        }
        
        let imageFileName = receivedImageFileNameArray[currentImageIndex]
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(imageFileName)") {
            
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
                    DispatchQueue.main.async {
                        self.plantImageView1.image = UIImage(data: jsonData)
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
    
    @IBAction func nextImageButtonTapped(_ sender: Any) {
        
        //increment array index, set to 0 if index is equal to length of array minus one
        if currentImageIndex != (receivedImageFileNameArray.count - 1) {
            currentImageIndex = currentImageIndex + 1
        } else {
            currentImageIndex = 0
        }
        
        let imageFileName = receivedImageFileNameArray[currentImageIndex]
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(imageFileName)") {
            
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
                    DispatchQueue.main.async {
                        self.plantImageView1.image = UIImage(data: jsonData)
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
    
}
