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
    var project: Project!
    var childContext: NSManagedObjectContext!
    var delegate: ProjectEntryDelegate?
    
    //MARK: Views
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default)
        label.text = "Project Name"
        label.numberOfLines = 1
        return label
    }()
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = .font(size: 18, weight: .medium, design: .rounded)
        textField.textColor = .label
        textField.textAlignment = NSTextAlignment.left
        textField.placeholder = "Name your project"
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
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .font(size: 18, weight: .medium, design: .default)
        label.text = "Select Color"
        label.numberOfLines = 1
        return label
    }()
    lazy var saveEditButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.handleSaveEditProject))
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
    lazy var purpleView = ColorView(shape: .round, color: .systemPurple, isFilled: true, height: 60)
    lazy var greenView = ColorView(shape: .round, color: .systemGreen, isFilled: true, height: 60)
    lazy var blueView = ColorView(shape: .round, color: .systemBlue, isFilled: true, height: 60)
    lazy var pinkView = ColorView(shape: .round, color: .systemPink, isFilled: true, height: 60)
    lazy var orangeView = ColorView(shape: .round, color: .systemOrange, isFilled: true, height: 60)
    lazy var redView = ColorView(shape: .round, color: .systemRed, isFilled: true, height: 60)
    lazy var tealView = ColorView(shape: .round, color: .systemTeal, isFilled: true, height: 60)
    lazy var indigoView = ColorView(shape: .round, color: .systemIndigo, isFilled: true, height: 60)
    lazy var yellowView = ColorView(shape: .round, color: .systemYellow, isFilled: true, height: 60)
    lazy var cyanView = ColorView(shape: .round, color: .cyan, isFilled: true, height: 60)
    lazy var magentaView = ColorView(shape: .round, color: .magenta, isFilled: true, height: 60)
    lazy var brownView = ColorView(shape: .round, color: .brown, isFilled: true, height: 60)
    lazy var lightGrayView = ColorView(shape: .round, color: .opaqueSeparator, isFilled: true, height: 60)
    lazy var mediumGrayView = ColorView(shape: .round, color: .lightGray, isFilled: true, height: 60)
    lazy var grayView = ColorView(shape: .round, color: .gray, isFilled: true, height: 60)
    lazy var darkGrayView = ColorView(shape: .round, color: .darkGray, isFilled: true, height: 60)
    lazy var colorViews: [ColorView] = []
    lazy var colorStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    lazy var row1StackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    lazy var row2StackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    lazy var row3StackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    lazy var row4StackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
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
    fileprivate func populateViewsWithProject() {
        saveEditButton.title = self.project == nil ? "Add" : "Save"
        nameTextField.text = project.name
        for colorView in colorViews where colorView.color == project.color { //find the colorView that matches project.color
            colorView.isSelected = true
        }
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        constraintScrollView()
        constraintNameLabel()
        constraintNameField()
        constraintColorLabel()
        setupColorViews()
        hideKeyboardOnTap()
    }
    
    fileprivate func setupColorViews() {
        colorViews = [ //put all colorViews in one array
            purpleView, greenView, blueView, pinkView,
            orangeView, redView, tealView, indigoView,
            cyanView, magentaView, brownView, yellowView,
            lightGrayView, mediumGrayView, grayView, darkGrayView
        ]
        //begin colorViews constraints
        contentView.addSubview(colorStackView)
        colorStackView.snp.makeConstraints { (make) in
            make.top.equalTo(colorLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        [row1StackView, row2StackView, row3StackView, row4StackView].forEach { //put each stackView inside colorStackView
            colorStackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(60)
                make.width.equalTo(330)
            }
        }
        [purpleView, greenView, blueView, pinkView].forEach {
            row1StackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalToSuperview()
            }
        }
        [orangeView, redView, tealView, indigoView].forEach {
            row2StackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalToSuperview()
            }
        }
        [cyanView, magentaView, brownView, yellowView].forEach {
            row3StackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalToSuperview()
            }
        }
        [lightGrayView, mediumGrayView, grayView, darkGrayView].forEach {
            row4StackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalToSuperview()
            }
        }
        for colorView in colorViews { //add tap gesture to each colorView
            colorView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.colorViewTapped(_:)))
            colorView.addGestureRecognizer(tap)
        }
    }
    
    fileprivate func constraintColorLabel() {
        contentView.addSubview(colorLabel)
        (colorLabel).snp.makeConstraints { (make) in
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
    @objc func handleSaveEditProject() {
        guard let project = project else { return }
        guard let name = nameTextField.text, !name.isEmpty else { return }
        if project.color == nil { //user did not select any colors
            colorViews.forEach() { $0.hasError = true } //add red borders
            return
        }
        project.name = name
        project.detail = "No detail"
        project.tasks = []
        project.lastOpenedDate = Date()
        project.taskLeft = 0
        delegate?.didSaveProject(vc: self, didSave: true)
    }
    
    ///clears the border of all colorViews
    fileprivate func resetBorderOfAllColorViews() {
        for otherColorView in colorViews {
            otherColorView.hasError = false
            otherColorView.isSelected = false
        }
    }
    
    ///update project color with the sender's background color. Update favoriteColor and
    @objc func colorViewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        guard let tappedColorView = gestureRecognizer.view as? ColorView else { return }
        if tappedColorView.isSelected { //if tappedColor was already selected
            tappedColorView.isSelected = false
            project!.color = nil //clear project's color
        } else if tappedColorView.hasError { //if tappedColor hasError
            resetBorderOfAllColorViews() //clear all colorViews's border
            tappedColorView.hasError = false
            tappedColorView.isSelected = true //select it
            project!.color = tappedColorView.color
        } else { //if unselected and no error, select it
            resetBorderOfAllColorViews()
            tappedColorView.isSelected = true
            project!.color = tappedColorView.color
        }
    }
}

extension ProjectEntryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
