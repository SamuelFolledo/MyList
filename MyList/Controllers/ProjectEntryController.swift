//
//  ProjectEntryController.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import CoreData

// MARK: ProjectEntryDelegate
protocol ProjectEntryDelegate {
  func didSaveProject(vc: ProjectEntryController, didSave: Bool)
}

class ProjectEntryController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    var project: Project? {
        didSet { title = project == nil ? "New Project" : "Edit Project" }
    }
    var childContext: NSManagedObjectContext!
    var delegate: ProjectEntryDelegate?
    
    //MARK: Views
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default) //UIFont(name: "Avenir-Heavy", size: 18)
        label.text = "Project Name"
        label.numberOfLines = 1
        return label
    }()
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = .font(size: 18, weight: .medium, design: .rounded)
        textField.textColor = .black
        textField.textAlignment = NSTextAlignment.left
        textField.placeholder = "Name your project"
        textField.keyboardAppearance = UIKeyboardAppearance.default
        textField.backgroundColor = UIColor(r: 242, g: 242, b: 242, a: 1)
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.setPadding(left: 15, right: 15)
//        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        return textField
    }()
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default) //UIFont(name: "Avenir-Heavy", size: 18)
        label.text = "Select Color"
        label.numberOfLines = 1
        return label
    }()
    lazy var saveEditButton: UIBarButtonItem = {
        let title = project == nil ? "Save" : "Edit"
        let barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.handleSaveEditProject))
        return barButton
    }()
    
    //MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateViewsWithProject()
    }
    
    // MARK: Private Methods
    fileprivate func setupViews() {
        setupNavigationBar()
        constraintNameLabel()
        constraintNameField()
        constraintColorLabel()
        hideKeyboardOnTap()
    }
    
    fileprivate func constraintColorLabel() {
        view.addSubview(colorLabel)
        (colorLabel).snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-16)
        }
    }
    
    fileprivate func constraintNameField() {
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
            make.height.equalTo(45)
        }
    }
    
    fileprivate func constraintNameLabel() {
        view.addSubview(nameLabel)
        (nameLabel).snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-16)
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = saveEditButton
    }
    
    //MARK: Helpers
    @objc func handleSaveEditProject() {
        updateProject()
        delegate?.didSaveProject(vc: self, didSave: true)
    }
    
    func populateViewsWithProject() {
        guard let project = project else { return }
        nameTextField.text = project.name
    }
    
    func updateProject() {
        guard let project = project else { return }
        guard let name = nameTextField.text, !name.isEmpty else { return }
        project.name = name
        project.detail = "No detail"
        project.color = UIColor.blue
        project.tasks = []
        project.lastOpenedDate = Date()
        project.taskLeft = 0
    }
}

extension ProjectEntryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
