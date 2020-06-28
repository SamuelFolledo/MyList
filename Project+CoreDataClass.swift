//
//  Project+CoreDataClass.swift
//  MyList
//
//  Created by Samuel Folledo on 6/28/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject {

}

extension Project {
    func stringForDate() -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .short
      return dateFormatter.string(from: lastOpenedDate)
    }
}
