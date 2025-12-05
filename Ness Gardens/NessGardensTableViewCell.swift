//
//  NessGardensTableViewCell.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 27/11/2025.
//

import UIKit

class NessGardensTableViewCell: UITableViewCell {
    
    //outlets
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var familyLabel: UILabel?
    @IBOutlet weak var speciesLabel: UILabel?
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var genusLabel: UILabel!
    
    //variables
    var favButtonPressed : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func favButtonPressed(_ sender: Any) {
        favButtonPressed()
    }
    
}
