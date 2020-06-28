//
//  TaskController.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class TaskController: UIViewController {
    
    weak var coordinator: MainCoordinator!
    var tasks: [Task] = [] { didSet { tableView.reloadData() } }
    
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
    lazy var newTaskButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "New Task", style: .plain, target: self, action: #selector(self.handleNewTask))
        return barButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
        navigationItem.rightBarButtonItem = newTaskButton
    }
    
    //MARK: Helpers
    @objc func handleNewTask() {
        print("New Task")
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
        let cell: ProjectCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProjectCell.self), for: indexPath) as! ProjectCell
        let task = tasks[indexPath.row]
//        cell.populateViews(chatRoom: chatRoom)
        return cell
    }
}
