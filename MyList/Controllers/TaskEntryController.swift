//
//  TaskEntryController.swift
//  MyList
//
//  Created by Samuel Folledo on 7/3/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import CoreData

// MARK: TaskEntryDelegate
protocol TaskEntryDelegate {
  func didSaveTask(vc: TaskEntryController, didSave: Bool)
}

class TaskEntryController: UIViewController {
    
    weak var coordinator: MainCoordinator!
    var task: Task!
    var childContext: NSManagedObjectContext!
    var delegate: TaskEntryDelegate?
    
    //MARK: Views
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default)
        label.text = "Title"
        label.numberOfLines = 1
        return label
    }()
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = .font(size: 18, weight: .medium, design: .rounded)
        textField.textColor = .label
        textField.textAlignment = NSTextAlignment.left
        textField.placeholder = "e.g. Create Repository"
        textField.keyboardAppearance = UIKeyboardAppearance.default
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.setPadding(left: 15, right: 15)
        return textField
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default)
        label.text = "Due Date"
        label.numberOfLines = 1
        return label
    }()
    private lazy var dateTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = .font(size: 18, weight: .medium, design: .rounded)
        textField.textColor = .label
        textField.textAlignment = NSTextAlignment.left
        textField.placeholder = "mm/dd/yyyy"
        textField.keyboardAppearance = UIKeyboardAppearance.default
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.setPadding(left: 15, right: 15)
        return textField
    }()
    lazy var saveEditButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.handleSaveEditTask))
        return barButton
    }()
    lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    lazy var contentView: UIView = {
        let view: UIView = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateViewsWithTask()
    }
    
    // MARK: Private Methods
    fileprivate func populateViewsWithTask() {
        saveEditButton.title = self.task == nil ? "Add" : "Save"
        guard let name = task.name, let dueDate = task.dueDate else { return }
        nameTextField.text = name
        dateTextField.text = dueDate.dateToUTC
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintScrollView()
        constraintNameLabel()
        constraintNameField()
        constraintDateLabel()
        constraintDateField()
        hideKeyboardOnTap()
    }
    
    fileprivate func constraintDateField() {
        contentView.addSubview(dateTextField)
        dateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.equalTo(dateLabel.snp.leading)
            make.trailing.equalTo(dateLabel.snp.trailing)
            make.height.equalTo(45)
        }
    }
    
    fileprivate func constraintDateLabel() {
        contentView.addSubview(dateLabel)
        (dateLabel).snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
    }
    
    fileprivate func constraintNameField() {
        contentView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
            make.height.equalTo(45)
        }
    }
    
    fileprivate func constraintNameLabel() {
        contentView.addSubview(nameLabel)
        (nameLabel).snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
    }
    
    fileprivate func constraintScrollView() {
        view.addSubview(scrollView) //constraint scrollView
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        scrollView.addSubview(contentView) //constraint contentView
        contentView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.view)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(500)
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = saveEditButton
    }
    
    //MARK: Helpers
    @objc func handleSaveEditTask() {
        guard let task = task else { return }
        guard let name = nameTextField.text, !name.isEmpty else { return }
        task.name = name
        task.details = "No details"
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())! //add a day (24 hours) to today's date
        task.dueDate = modifiedDate
        task.isDone = false
        delegate?.didSaveTask(vc: self, didSave: true)
    }
}

extension TaskEntryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
