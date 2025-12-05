//
//  CoreBed+CoreDataProperties.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 05/12/2025.
//
//

public import Foundation
public import CoreData


public typealias CoreBedCoreDataPropertiesSet = NSSet

extension CoreBed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreBed> {
        return NSFetchRequest<CoreBed>(entityName: "CoreBed")
    }

    @NSManaged public var bed_id: String?
    @NSManaged public var name: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var last_modified: String?

}

extension CoreBed : Identifiable {

}
