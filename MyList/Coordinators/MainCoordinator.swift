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
    var childCoordinators: [Coordinator] = []
    lazy var navigationController: UINavigationController = UINavigationController()
    lazy var coreDataStack = CoreDataStack(modelName: "MyList")
    
    //MARK: Init
    init(window: UIWindow) {
        window.rootViewController = navigationController
        setupNavigationController()
    }
    
    //MARK: Methods
    func start() {
        let vc = ProjectController()
        vc.view.backgroundColor = .white
        vc.coordinator = self //assign vc's coordinator to self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToProjectEntry(project: Project?) {
        let vc = ProjectEntryController()
        vc.coordinator = self
        vc.view.backgroundColor = .white
        vc.delegate = self
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
        vc.coordinator = self
        vc.view.backgroundColor = .white
        vc.title = project.name
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: Private Methods
private extension MainCoordinator {
    func setupNavigationController() {
        self.navigationController.isNavigationBarHidden = false
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.navigationBar.backgroundColor = .white
        self.navigationController.navigationBar.tintColor = .red //button color
        //        navigationController.setStatusBarColor(backgroundColor: kMAINCOLOR)
    }
}

extension MainCoordinator: ProjectEntryDelegate {
    func didSaveProject(vc: ProjectEntryController, didSave: Bool) {
//        print(navigationController.viewControllers.last?.description)
        guard didSave, let context = vc.childContext, context.hasChanges else {
            navigationController.popViewController(animated: true)
            return
        }
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            self.coreDataStack.saveContext()
        }
        navigationController.popViewController(animated: true)
    }
}
