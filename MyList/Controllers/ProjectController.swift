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
        let lastOpenedSort = NSSortDescriptor(key: "lastOpenedDate", ascending: false) //sort by lastOpenedDate, most recent first
        let nameSort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true) //cleaner way
        let taskLeftSort = NSSortDescriptor(key: "taskLeft", ascending: false) //sorts by amount of tasks left
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
        let table = UITableView.init(frame: .zero, style: .grouped)
        table.sectionHeaderHeight = 40
        table.backgroundColor = .systemBackground
        table.rowHeight = 100
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.allowsMultipleSelection = false
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
        searchController.obscuresBackgroundDuringPresentation = false //needed to select row and not reset search text
        self.definesPresentationContext = true
        return searchController
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintTableView()
        fetchProjects()
    }
    fileprivate func fetchProjects() {
        do {
            try fetchedResultsController.performFetch() //perform fetch
            projects = fetchedResultsController.fetchedObjects! //update projects array
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
        coordinator.goToProjectEntry(fromVC: self, project: nil)
    }
}

// MARK: NSFetchedResultsController Delegate
extension ProjectController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if !searchController.isActive || searchController.searchBar.text == "" { //if searchController is not active or empty text
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
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    //Needed for updating sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if !searchController.isActive || searchController.searchBar.text == "" { //if searchController is not active or empty text
            let indexSet = IndexSet(integer: sectionIndex)
            switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .automatic)
            case .delete:
                tableView.deleteSections(indexSet, with: .automatic)
            case .update: //not tested/used
                tableView.deleteSections(indexSet, with: .automatic)
                tableView.insertSections(indexSet, with: .automatic)
            case .move: //not tested/used
                tableView.deleteSections(indexSet, with: .automatic)
                tableView.insertSections(indexSet, with: .automatic)
            default: break
            }
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
        project.lastOpenedDate = Date() //update project's lastOpenedDate when tapped
        coreDataStack.saveContext()
        coordinator.goToTask(project: project)
    }
    
    ///Newer Swipe To Delete or Edit
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var selectedProject: Project! //get the project to update or delete
        if self.searchController.isActive && !self.searchController.searchBar.text!.isEmpty {
            selectedProject = self.filteredProjects[indexPath.row]
        } else {
            selectedProject = self.fetchedResultsController.object(at: indexPath)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion: @escaping ( Bool) -> Void) in
            self.coreDataStack.mainContext.delete(selectedProject)
            self.coreDataStack.saveContext()
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion: @escaping ( Bool) -> Void) in
            self.coordinator.goToProjectEntry(fromVC: self, project: selectedProject)
        }
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    ///view for header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil //no section title when searching
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = UIColor.systemBackground
            let label = UILabel()
            label.frame = CGRect(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            let lastOpenedDate = fetchedResultsController.sections?[section].name
            label.text = "Last Opened: \(lastOpenedDate!)"
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold) //UIFont().futuraPTMediumFont(16) // my custom font
            label.textColor = UIColor.label
            headerView.addSubview(label)
            return headerView
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
        cell.selectionStyle = .none
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

//MARK: Project Entry Delegate
extension ProjectController: ProjectEntryDelegate {
    func didSaveProject(vc: ProjectEntryController, didSave: Bool) {
        coordinator.navigationController.popViewController(animated: true)
        guard didSave, let context = vc.childContext, context.hasChanges else { return }
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            self.coreDataStack.saveContext()
        }
    }
}
