//
//  CorePlant+CoreDataProperties.swift
//  Ness Gardens
//
//  Created by Edwald Einarsson, Helgi on 05/12/2025.
//
//

public import Foundation
public import CoreData


public typealias CorePlantCoreDataPropertiesSet = NSSet

extension CorePlant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CorePlant> {
        return NSFetchRequest<CorePlant>(entityName: "CorePlant")
    }

    @NSManaged public var recnum: String?
    @NSManaged public var acid: String?
    @NSManaged public var accsta: String?
    @NSManaged public var family: String?
    @NSManaged public var genus: String?
    @NSManaged public var species: String?
    @NSManaged public var infraspecificEpithet: String?
    @NSManaged public var vernacularName: String?
    @NSManaged public var cultivarName: String?
    @NSManaged public var donor: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var country: String?
    @NSManaged public var iso: String?
    @NSManaged public var sgu: String?
    @NSManaged public var loc: String?
    @NSManaged public var bed: String?
    @NSManaged public var memoriam: String?
    @NSManaged public var redlist: String?
    @NSManaged public var last_modified: String?
    @NSManaged public var alt: String?
    @NSManaged public var cnam: String?
    @NSManaged public var cid: String?
    @NSManaged public var cdat: String?

}

extension CorePlant : Identifiable {

}
