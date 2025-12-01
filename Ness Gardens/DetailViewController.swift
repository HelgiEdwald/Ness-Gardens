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
    
    //MARK: Variables passed along from main view controller
    var plantReceived: Plant?
    var selectedPlantRecnum: String?
    var selectedPlantFamily: String?
    var selectedPlantSpecies: String?
    var selectedPlantImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Detail received: \(plantReceived?.recnum ?? "No recnum")")
        
        recnumLabel.text = plantReceived?.recnum
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
