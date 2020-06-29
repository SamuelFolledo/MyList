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
    var tasks: [Task] = [] { didSet { tableView.reloadData() } }
    var project: Project!
    var childContext: NSManagedObjectContext!
    
    //MARK: Properties Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 100
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.register(TaskCell.self, forCellReuseIdentifier: String(describing: TaskCell.self))
        return table
    }()
    lazy var addTaskButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(self.handleAddTask))
        return barButton
    }()
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["TODO", "DONE"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = .lightGray
        segmentedControl.selectedSegmentTintColor = project.color 
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
//        segmentedControl.addTarget(self, action: #selector(switchApplication), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: Private Methods
    fileprivate func setupViews() {
        setupNavigationBar()
        constraintViews()
    }
    
    fileprivate func constraintViews() {
        self.view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(20)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    //MARK: Helpers
    @objc func handleAddTask() {
        print("Add Task")
    }
}

extension TaskController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        print(task.name)
    }
}

extension TaskController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskCell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskCell.self), for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.populateViews(task: task)
        return cell
    }
}
