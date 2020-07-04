//
//  MainCoordinator.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import CoreData

class MainCoordinator: Coordinator {
    
    //MARK: Properties
    weak var coreDataStack: CoreDataStack!
    var childCoordinators: [Coordinator] = []
    lazy var navigationController: UINavigationController = UINavigationController()
    
    //MARK: Init
    init(window: UIWindow) {
        window.rootViewController = navigationController
        guard let coreDataStack = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else { fatalError("No Core Data Stack") }
        self.coreDataStack = coreDataStack
        setupNavigationController()
    }
    
    //MARK: Methods
    func start() {
        let vc = ProjectController()
        vc.coreDataStack = self.coreDataStack
        vc.coordinator = self //assign vc's coordinator to self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToProjectEntry(fromVC: UIViewController, project: Project?) {
        let vc = ProjectEntryController()
        vc.delegate = (fromVC as! ProjectEntryDelegate)
        vc.coordinator = self
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = coreDataStack.mainContext
        vc.childContext = childContext
        if project == nil { //new project
            let newProject = Project(context: childContext)
            vc.project = newProject
            vc.title = "New Project"
        } else { //edit project
            let projectToEdit = childContext.object(with: project!.objectID) as? Project
            vc.project = projectToEdit
            vc.title = "Edit Project"
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTask(project: Project) {
        let vc = TaskController()
        vc.project = project
        vc.coreDataStack = coreDataStack
        vc.coordinator = self
        vc.title = project.name
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTaskEntry(fromVC: UIViewController, task: Task?) {
        let vc = TaskEntryController()
        vc.delegate = (fromVC as! TaskEntryDelegate)
        vc.coordinator = self
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = coreDataStack.mainContext
        vc.childContext = childContext
        if task == nil { //new project
            let newTask = Task(context: childContext)
            vc.task = newTask
            vc.title = "New Task"
        } else { //edit project
            let taskToEdit = childContext.object(with: task!.objectID) as? Task
            vc.task = taskToEdit
            vc.title = "Edit Task"
        }
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: Private Methods
private extension MainCoordinator {
    func setupNavigationController() {
        self.navigationController.isNavigationBarHidden = false
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.navigationBar.backgroundColor = .systemBackground
        self.navigationController.navigationBar.tintColor = .systemBlue //button color
        //        navigationController.setStatusBarColor(backgroundColor: kMAINCOLOR)
    }
}
