//
//  Task+CoreDataClass.swift
//  MyList
//
//  Created by Samuel Folledo on 7/4/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    
}

extension Task {
    @objc var overDueStatus: String {
        get {
            if self.dueDate! < Date() { //if current date is greater than due date, it's overDue
                return "Overdue Tasks 🚨‼️"
            } else { //for upcoming tasks
                if Calendar.current.isDateInToday(dueDate!) { //if task is due today
                    return "Due Today"
                } else if Calendar.current.isDateInTomorrow(dueDate!) { //if due tomorrow
                    return "Due Tomorrow"
                } else { //if due past tomorrow
                    return "Upcoming Tasks"
                }
            }
        }
    }
}
