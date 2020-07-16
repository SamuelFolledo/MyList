//
//  TaskController.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import CoreData

class TaskController: UIViewController {
    
    weak var coordinator: MainCoordinator!
    weak var coreDataStack: CoreDataStack!
    var project: Project!
    private lazy var fetchRequest: NSFetchRequest<Task> = {
        //setup fetch request
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let dueDateSort = NSSortDescriptor(key: #keyPath(Task.dueDate), ascending: true) //soonest/overdue tasks first
        let nameSort = NSSortDescriptor(key: #keyPath(Task.name), ascending: true)
        fetchRequest.sortDescriptors = [dueDateSort, nameSort]
        let shouldFetchDoneTasks = segmentedControl.selectedSegmentIndex == 0 ? false : true //true if user wants to see TODO tasks (TODO = 0, DONE = 1), then shouldFetchDoneTasks is false
        let filterByProjectName = NSPredicate(format: "%K = %@ AND isDone = %@", "project.name", "\(project.name)", NSNumber(value: shouldFetchDoneTasks)) //fetch Tasks with a project's name property equal to selected project's name
        fetchRequest.predicate = filterByProjectName
        fetchRequest.fetchBatchSize = 10 //get 10 tasks at a time
        return fetchRequest
    }()
    
    //MARK: Properties Views
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.rowHeight = 70
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.separatorColor = .black
        table.separatorStyle = .singleLine
        table.tableFooterView = UIView()
        table.register(TaskCell.self, forCellReuseIdentifier: String(describing: TaskCell.self))
        return table
    }()
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        //create fetchResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.mainContext,
                                                                  sectionNameKeyPath: #keyPath(Task.overDueStatus), //#keyPath(Task.dueDate),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    lazy var addTaskButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(self.handleAddTask))
        return barButton
    }()
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["TO DO", "DONE"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5
        segmentedControl.backgroundColor = .systemBackground
        segmentedControl.tintColor = .label
        segmentedControl.selectedSegmentTintColor = project.color 
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
                                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)], for: .selected)
        segmentedControl.addTarget(self, action: #selector(fetchTasks), for: .valueChanged)
        return segmentedControl
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintViews()
        fetchTasks()
    }
    
    ///check which tasks user wants to see and update predicate before performing fetch, then reload data
    @objc fileprivate func fetchTasks() {
        do {
            let shouldFetchDoneTasks = segmentedControl.selectedSegmentIndex == 0 ? false : true //true if user wants to see TODO tasks (TODO = 0, DONE = 1), then shouldFetchDoneTasks is false
            let filterByProjectName = NSPredicate(format: "%K = %@ AND isDone = %@", "project.name", "\(project.name)", NSNumber(value: shouldFetchDoneTasks)) //fetch Tasks with a project's name property equal to selected project's name
            fetchedResultsController.fetchRequest.predicate = filterByProjectName
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    fileprivate func constraintViews() {
        self.view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            make.height.equalTo(40)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    //MARK: Helpers
    @objc func handleAddTask() {
        coordinator.goToTaskEntry(fromVC: self, task: nil)
    }
    
    fileprivate func animateCell(cell: TaskCell, toLeft: Bool) {
        let cellLocation = cell.convert(cell.center, from: cell.superview) //get the cell's position
        let cellDestination = toLeft ? tableView.bounds.width : -tableView.bounds.width //get left or right of tableView
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseInOut], animations: {
            cell.center = cellLocation.applying(CGAffineTransform(translationX: cellDestination, y: 0))
        }) { (_) in
            self.tableView.reloadData()
        }
    }
}

// MARK: - Internal
extension TaskController {
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? TaskCell else { return }
        var task: Task!
        if segmentedControl.selectedSegmentIndex == 0 {
            task = fetchedResultsController.object(at: indexPath)
        } else {
            task = fetchedResultsController.fetchedObjects![indexPath.row]
        }
        cell.task = task
    }
}

//MARK: TableView Delegate
extension TaskController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task: Task!
        if segmentedControl.selectedSegmentIndex == 0 {
            task = fetchedResultsController.object(at: indexPath)
        } else {
            task = fetchedResultsController.fetchedObjects![indexPath.row]
        }
        task.isDone = !task.isDone
        guard let tappedCell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
        tappedCell.task = task //update cell's task and its views
        coreDataStack.saveContext()
    }
    
    ///Newer Swipe To Delete or Edit
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipedTask: Task = fetchedResultsController.object(at: indexPath)
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion: @escaping ( Bool) -> Void) in
            self.coreDataStack.mainContext.delete(swipedTask)
            self.coreDataStack.saveContext()
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion: @escaping ( Bool) -> Void) in
            self.coordinator.goToTaskEntry(fromVC: self, task: swipedTask)
        }
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    ///view for header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if segmentedControl.selectedSegmentIndex == 0 { //Add header for to do tasks only that are overdue
            guard let overdueStatus = fetchedResultsController.sections?[section].name, overdueStatus != "" else { //if there is no or nil status
                return nil
            }
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = UIColor.clear
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "\(overdueStatus)"
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold) //UIFont().futuraPTMediumFont(16) // my custom font
            label.textColor = UIColor.label
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }
}

//MARK: TableView DataSource
extension TaskController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return fetchedResultsController.sections?.count ?? 0
        } else { //in done tasks
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskCell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskCell.self), for: indexPath) as! TaskCell
        configure(cell: cell, for: indexPath)
        return cell
    }
}

// MARK: NSFetchedResultsController Delegate
extension TaskController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            let deleteAnimation: UITableView.RowAnimation = self.segmentedControl.selectedSegmentIndex == 0 ? .right : .left
            tableView.deleteRows(at: [indexPath!], with: deleteAnimation)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TaskCell
            self.configure(cell: cell, for: indexPath!)
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
        if segmentedControl.selectedSegmentIndex == 0 { //edit sections only for todo tasks
            let indexSet = IndexSet(integer: sectionIndex)
            switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .automatic)
            case .delete:
                let deleteAnimation: UITableView.RowAnimation = self.segmentedControl.selectedSegmentIndex == 0 ? .right : .left
                tableView.deleteSections(indexSet, with: deleteAnimation)
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
}

//MARK: Task Entry Delegate
extension TaskController: TaskEntryDelegate {
    func didSaveTask(vc: TaskEntryController, didSave: Bool) {
        coordinator.navigationController.popViewController(animated: true)
        //1. check if user wanted to save, there is childContext, there are changes, project still exist, and we can get its tasks
        guard didSave,
            let childContext = vc.childContext,
            childContext.hasChanges,
            let currentProject = childContext.object(with: self.project.objectID) as? Project, //fetch the project with the childContext that contains the newly created Task (this makes sure project and tasks are under the same context)
            let tasks = currentProject.tasks.mutableCopy() as? NSMutableOrderedSet
        else { return }
        //2.loop through each objects in childContext's objects that are tasks
        for managedObject in childContext.registeredObjects { //get the task from childContext
            guard let task = managedObject as? Task, //convert managedObject to Task
                !tasks.contains(task) //ensure task does not exist yet, else go to next object
            else { continue }
            tasks.add(task) //add task to tasks
        }
        //3. Update project's task with the new/editted tasks and save it on the child then at mainContext
        currentProject.tasks = tasks
        self.project = coreDataStack.mainContext.object(with: currentProject.objectID) as? Project //update project
        childContext.perform { //save childContext before mainContext
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            self.coreDataStack.saveContext() //save mainContext
        }
    }
}
