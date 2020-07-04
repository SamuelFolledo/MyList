//
//  Project+CoreDataClass.swift
//  MyList
//
//  Created by Samuel Folledo on 6/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject {

}

extension Project {
    ///to section each project by day of lastOpenedDate
    @objc var isoDate: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            // insert settings for TimeZone and Calendar here
            return formatter.string(from: self.lastOpenedDate)
        }
    }
    
    @objc var toDoTasks: [Task] {
        get {
            guard let tasks = tasks.mutableCopy() as? [Task] else { return [] } //convert tasks to array of tasks
            return tasks.filter() { !$0.isDone } //return unfinished tasks
        }
    }
    
    @objc var doneTasks: [Task] {
        get {
            guard let tasks = tasks.mutableCopy() as? [Task] else { return [] } //convert tasks to array of tasks
            return tasks.filter() { $0.isDone } //return finished tasks
        }
    }
}
