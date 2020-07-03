//
//  ProjectController.swift
//  MyList
//
//  Created by Samuel Folledo on 6/26/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import SnapKit
import CoreData

class ProjectController: UIViewController {
    
    //MARK: Properties
    weak var coordinator: MainCoordinator!
    weak var coreDataStack: CoreDataStack!
    var projects: [Project] = []
    var filteredProjects: [Project] = [] {
        didSet { tableView.reloadData() }
    }
    
    //MARK: Properties Views
    lazy var fetchedResultsController: NSFetchedResultsController<Project> = {
        //setup fetch request
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        let lastOpenedSort = NSSortDescriptor(key: "lastOpenedDate", ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true) //cleaner way
        let taskLeftSort = NSSortDescriptor(key: "taskLeft", ascending: false)
        fetchRequest.sortDescriptors = [lastOpenedSort, nameSort, taskLeftSort]
        fetchRequest.fetchBatchSize = 20
        //create fetchResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.mainContext,
                                                                  sectionNameKeyPath: #keyPath(Project.isoDate),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 100
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.register(ProjectCell.self, forCellReuseIdentifier: String(describing: ProjectCell.self))
        return table
    }()
    lazy var newProjectButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(self.handleNewProject))
        return barButton
    }()
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        return searchController
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintTableView()
        do {
            try fetchedResultsController.performFetch()
            projects = fetchedResultsController.fetchedObjects!
        } catch {
            print(error)
        }
    }
    
    fileprivate func constraintTableView() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setupNavigationBar() {
        self.title = "Projects"
        navigationItem.rightBarButtonItem = newProjectButton
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true //needed for searchController
    }
    
    //MARK: Helpers
    @objc func handleNewProject() {
        coordinator!.goToProjectEntry(project: nil)
    }
}

// MARK: NSFetchedResultsController Delegate
extension ProjectController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        //update projects
        guard let updatedProjects = controller.fetchedObjects as? [Project] else { return }
        projects = updatedProjects
        //update tableVie
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! ProjectCell
            configure(cell: cell, for: indexPath!)
        case .move: //not tested
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //Needed for updating sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        case .update: //not tested
            tableView.deleteSections(indexSet, with: .automatic)
            tableView.insertSections(indexSet, with: .automatic)
        case .move: //not tested
            tableView.deleteSections(indexSet, with: .automatic)
            tableView.insertSections(indexSet, with: .automatic)
        default: break
        }
    }
}

// MARK: TableViewDelegate
extension ProjectController: UITableViewDelegate {
    ///Did Select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project: Project!
        if searchController.isActive && searchController.searchBar.text != "" {
            project = filteredProjects[indexPath.row]
        } else {
            project = fetchedResultsController.object(at: indexPath)
        }
        coordinator.goToTask(project: project)
    }
    
    ///Swipe To Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let project = fetchedResultsController.object(at: indexPath)
            coreDataStack.mainContext.delete(project)
            coreDataStack.saveContext()
        case .insert:
            print("Insert Editing Style not implemented")
        default: break
        }
    }
    
    //MARK: Split Sections by Continent
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil //no section title when searching
        } else {
            return fetchedResultsController.sections?[section].name
        }
    }
}

// MARK: TableViewDataSource
extension ProjectController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredProjects.count > 0 ? 1 : 0 //one section if there is searched project, else 0 section
        } else {
            return fetchedResultsController.sections?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredProjects.count
        } else {
            return fetchedResultsController.sections![section].numberOfObjects //current section's number of rows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProjectCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProjectCell.self), for: indexPath) as! ProjectCell
        configure(cell: cell, for: indexPath)
        return cell
    }
}

// MARK: - Internal
extension ProjectController {
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? ProjectCell else { return }
        var project: Project!
        if searchController.isActive && searchController.searchBar.text != "" {
            project = filteredProjects[indexPath.row]
        } else {
            project = fetchedResultsController.object(at: indexPath)
        }
        cell.project = project
    }
}

//MARK: SearchController
extension ProjectController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    //MARK: Private Search Method
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredProjects = projects.filter({ (project) -> Bool in
            ////lower case both text then compare if searchText contains name or detail
            return project.name.lowercased().contains(searchText.lowercased())
                || project.detail.lowercased().contains(searchText.lowercased())
        })
    }
}
