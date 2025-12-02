//
//  DetailViewController.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 01/12/2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var recnumLabel: UILabel!
    @IBOutlet weak var plantImageView1: UIImageView!
    
    
    
    //MARK: Variables passed along from main view controller
    var plantReceived: Plant?
    var selectedPlantImage: UIImage?
    var receivedPlantImageFileName: String?


    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMain", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Detail received: \(plantReceived?.recnum ?? "No recnum")")
        
        recnumLabel.text = plantReceived?.recnum
        
        let imageFileName = receivedPlantImageFileName
        
        let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(imageFileName ?? "Error")"
        let url = URL(string: urlString)!
        
        plantImageView1.load(url:url)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
