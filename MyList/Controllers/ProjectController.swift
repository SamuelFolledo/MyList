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
    
    weak var coordinator: MainCoordinator! {
        didSet { fetchedResultsController = projectListFetchedResultsController() }
    }
    var projects: [Project] = [] {
        didSet { tableView.reloadData() }
    }
    var filteredProjects: [Project] = [] {
        didSet { tableView.reloadData() }
    }
    
    //MARK: Properties Views
    lazy var fetchedResultsController: NSFetchedResultsController<Project> = NSFetchedResultsController()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        projects.removeAll()
        guard let fetchedProjects = fetchedResultsController.fetchedObjects else { return }
        projects = fetchedProjects
    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        setupNavigationBar()
        constraintTableView()
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

// MARK: NSFetchedResultsController
private extension ProjectController {
    func projectListFetchedResultsController() -> NSFetchedResultsController<Project> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: projectFetchRequest(),
                                                                 managedObjectContext: coordinator.coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        return fetchedResultController
    }
    
    func projectFetchRequest() -> NSFetchRequest<Project> {
        let fetchRequest:NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.lastOpenedDate), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
}

// MARK: NSFetchedResultsController Delegate
extension ProjectController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: TableView Delegate
extension ProjectController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project: Project!
        if searchController.isActive && searchController.searchBar.text != "" {
            project = filteredProjects[indexPath.row]
        } else {
            project = projects[indexPath.row]
        }
        print(project.name)
    }
}

// MARK: TableView DataSource
extension ProjectController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredProjects.count
        } else {
            return projects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProjectCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProjectCell.self), for: indexPath) as! ProjectCell
        let project: Project!
        if searchController.isActive && searchController.searchBar.text != "" {
            project = filteredProjects[indexPath.row]
        } else {
            project = projects[indexPath.row]
        }
        cell.populateViews(project: project)
        return cell
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
            return project.name.lowercased().contains(searchText.lowercased())
                || project.detail.lowercased().contains(searchText.lowercased())
        })
    }
}
