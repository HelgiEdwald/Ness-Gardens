//
//  CoreImage+CoreDataProperties.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 05/12/2025.
//
//

public import Foundation
public import CoreData


public typealias CoreImageCoreDataPropertiesSet = NSSet

extension CoreImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreImage> {
        return NSFetchRequest<CoreImage>(entityName: "CoreImage")
    }

    @NSManaged public var recnum: String?
    @NSManaged public var imgid: String?
    @NSManaged public var img_file_name: String?
    @NSManaged public var imgtitle: String?
    @NSManaged public var photodt: String?
    @NSManaged public var copyOfImage: String?
    @NSManaged public var last_modified: String?

}

extension CoreImage : Identifiable {

}
