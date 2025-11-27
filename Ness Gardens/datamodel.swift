//
//  datamodel.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 25/11/2025.
//

import Foundation

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

nonisolated
struct imageRecords: Decodable {
    let images: [Image]
}

nonisolated
struct Image: Decodable {
    let recnum: String
    let imgid: String?
    let img_file_name: String
    let imgtitle: String?
    let photodt: String?
    let copy: String?
    let last_modified: String
}
