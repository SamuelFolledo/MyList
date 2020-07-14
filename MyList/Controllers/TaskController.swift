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
        let dueDateSort = NSSortDescriptor(key: #keyPath(Task.dueDate), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Task.name), ascending: true) //cleaner way
        fetchRequest.sortDescriptors = [dueDateSort, nameSort]
        let shouldFetchDoneTasks = segmentedControl.selectedSegmentIndex == 0 ? false : true //true if user wants to see TODO tasks (TODO = 0, DONE = 1), then shouldFetchDoneTasks is false
        let filterByProjectName = NSPredicate(format: "%K = %@ AND isDone = %@", "project.name", "\(project.name)", NSNumber(value: shouldFetchDoneTasks)) //fetch Tasks with a project's name property equal to selected project's name
        fetchRequest.predicate = filterByProjectName
        fetchRequest.fetchBatchSize = 10 //get 10 tasks at a time
        return fetchRequest
    }()
    
    //MARK: Properties Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 70
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.register(TaskCell.self, forCellReuseIdentifier: String(describing: TaskCell.self))
        return table
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
        segmentedControl.addTarget(self, action: #selector(switchTaskList), for: .valueChanged)
        return segmentedControl
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print(project.tasks)
//    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintViews()
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
            make.top.equalTo(segmentedControl.snp.bottom)
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
    
    @objc func switchTaskList() {
        tableView.reloadData()
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//
//        default:

//        }
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

extension TaskController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task: Task!
        var toLeft: Bool = true
        switch self.segmentedControl.selectedSegmentIndex {
        case 0: //to do tasks
            task = self.project.toDoTasks[indexPath.row]
        default: //done tasks
            toLeft = false
            task = self.project.doneTasks[indexPath.row]
        }
        task.isDone = !task.isDone
        guard let tappedCell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
        tappedCell.task = task
        animateCell(cell: tappedCell, toLeft: toLeft)
    }
}

extension TaskController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: //to do
            return project.toDoTasks.count
        default:
            return project.doneTasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskCell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskCell.self), for: indexPath) as! TaskCell
        var task: Task!
        switch segmentedControl.selectedSegmentIndex {
        case 0: //to do
            task = project.toDoTasks[indexPath.row]
        default:
            task = project.doneTasks[indexPath.row]
        }
        cell.task = task
        return cell
    }
}

//MARK: Task Entry Delegate
extension TaskController: TaskEntryDelegate {
    func didSaveTask(vc: TaskEntryController, didSave: Bool) {
        coordinator.navigationController.popViewController(animated: true)
        guard didSave,
            let childContext = vc.childContext,
            childContext.hasChanges,
            let currentProject = childContext.object(with: self.project.objectID) as? Project, //fetch the project
            let tasks = currentProject.tasks.mutableCopy() as? NSMutableOrderedSet //get tasks list
        else { return }
        for managedObject in childContext.registeredObjects { //get the task from childContext
            guard let task = managedObject as? Task else { continue }
            tasks.add(task) //add task to tasks
        }
        currentProject.tasks = tasks
        self.project = currentProject //update self.project
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
