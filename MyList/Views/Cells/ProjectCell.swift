//
//  ProjectCell.swift
//  MyList
//
//  Created by Samuel Folledo on 6/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
    
    //MARK: Properties
    var project: Project! {
        didSet { populateViews() }
    }
    
    //MARK: View Properties
    lazy var containerView: UIView = {
        let view: UIView = UIView(frame: .zero)
        view.backgroundColor = .systemFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var mainStackView: UIStackView = { //will contain colorView and verticalStackView
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    lazy var verticalStackView: UIStackView = { //will contain the nameLabel, detailLabel, and pendingTaskLabel
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 20, weight: .bold, design: .default)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 14, weight: .medium, design: .rounded)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    lazy var pendingTaskLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 14, weight: .regular, design: .rounded)
        label.textColor = .darkGray
        label.numberOfLines = 1
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    lazy var colorView: ColorView = {
        let colorView = ColorView(shape: .round, color: .clear, isFilled: true, height: 40)
        return colorView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        detailLabel.text = ""
        detailLabel.isHidden = true
        pendingTaskLabel.text = ""
        pendingTaskLabel.isHidden = true
        colorView.color = .clear
    }
    
    //MARK: Private Methods
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-10)
        }
        //setup mainStackView
        containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
        mainStackView.addArrangedSubview(colorView)
        colorView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.centerY.equalToSuperview()
        }
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        verticalStackView.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(pendingTaskLabel)
        pendingTaskLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
    }
    
    fileprivate func populateViews() {
        colorView.color = project.color!
        nameLabel.text = project.name
        if project.detail != "" {
            detailLabel.isHidden = false
            detailLabel.text = project.detail
        }
        if project.taskLeft > 0 {
            pendingTaskLabel.isHidden = false
            let taskLeftString: String = project.taskLeft == 0 ? "task left" : "tasks left"
            pendingTaskLabel.text = "\(project.taskLeft) \(taskLeftString)"
        }
    }
}
