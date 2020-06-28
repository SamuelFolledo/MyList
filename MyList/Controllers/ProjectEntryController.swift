//
//  ProjectEntryController.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

// MARK: ProjectEntryDelegate
protocol ProjectEntryDelegate {
  func didFinish(viewController: ProjectController, didSave: Bool)
}

class ProjectEntryController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    var project: Project? {
        didSet { title = project == nil ? "New Project" : "Edit Project" }
    }
    var delegate: ProjectEntryDelegate?
    
    //MARK: Views
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default) //UIFont(name: "Avenir-Heavy", size: 18)
        label.text = "Project Name:"
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
    lazy var saveEditButton: UIBarButtonItem = {
        let title = project == nil ? "Save" : "Edit"
        let barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.handleEditSaveProject))
        return barButton
    }()
    
    //MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: Private Methods
    fileprivate func setupViews() {
        setupNavigationBar()
        constraintNameLabel()
        constraintNameField()
        hideKeyboardOnTap()
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
    @objc func handleEditSaveProject() {
        dismiss(animated: true, completion: nil)
    }
}

extension ProjectEntryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
