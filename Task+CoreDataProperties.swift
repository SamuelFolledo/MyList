//
//  Task+CoreDataProperties.swift
//  MyList
//
//  Created by Samuel Folledo on 6/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var details: String
    @NSManaged public var dueDate: Date
    @NSManaged public var name: String
    @NSManaged public var status: Bool
    @NSManaged public var project: Project?

}
