//
//  Task+CoreDataProperties.swift
//
//
//  Created by Samuel Folledo on 6/27/20.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var status: Bool
    @NSManaged public var name: String?
    @NSManaged public var details: NSObject?
    @NSManaged public var project: Project?

}
