//
//  helpers.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 28/11/2025.
//

import Foundation
import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.image = UIImage(named: "no plant image")
                    }
                }
            }
            
        }
    }
}

