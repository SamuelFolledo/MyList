//
//  MainCoordinator.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

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
    
    func goToNewProject() {
        let vc = NewProjectController()
        vc.coordinator = self
        vc.view.backgroundColor = .white
        vc.title = "New Project"
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTask(project: Project) {
        let vc = TaskController()
        vc.coordinator = self
        vc.view.backgroundColor = .white
        vc.title = project.name
        navigationController.pushViewController(vc, animated: true)
    }
    
    fileprivate func setupNavigationController() {
        self.navigationController.isNavigationBarHidden = false
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.navigationBar.backgroundColor = .white
        self.navigationController.navigationBar.tintColor = .red
//        navigationController.navigationBar.tintColor = SettingsService.shared.grayColor //button color
//        navigationController.setStatusBarColor(backgroundColor: kMAINCOLOR)
    }
}
