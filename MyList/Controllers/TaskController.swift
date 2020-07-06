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
//    var tasks: [Task] = [] { didSet { tasks.forEach() {$0.isDone ? doneTasks.append($0) : toDoTasks.append($0)} } } //is task isDone, then append to doneTasks, else append to toDoTasks
//    var toDoTasks: [Task] = [] { didSet { tableView.reloadData() } }
//    var doneTasks: [Task] = [] { didSet { tableView.reloadData() } }
    var project: Project!
//    var childContext: NSManagedObjectContext!
    
    //MARK: Properties Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 100
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
        return segmentedControl
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(project.tasks)
    }
    
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
}

extension TaskController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task: Task!
        switch segmentedControl.selectedSegmentIndex {
        case 0: //to do
            task = project.toDoTasks[indexPath.row]
        default:
            task = project.doneTasks[indexPath.row]
        }
        print(task.name)
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
        cell.populateViews(task: task)
        return cell
    }
}

//MARK: Task Entry Delegate
extension TaskController: TaskEntryDelegate {
    func didSaveTask(vc: TaskEntryController, didSave: Bool) {
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
