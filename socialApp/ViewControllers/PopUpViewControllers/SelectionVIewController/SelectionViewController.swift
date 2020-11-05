//
//  SelectionTableView.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    var model: [String]
    var tableDescription: String
    let tableView = UITableView(frame: .zero, style: .plain)
    var selectedItem: String
    let saveFunc: (String)-> Void
    
    init(elements: [String], description: String, selectedValue: String, complition:@escaping (String) -> Void ) {
        self.model = elements
        self.tableDescription = description
        self.selectedItem = selectedValue
        self.saveFunc = complition
        super.init(nibName: nil, bundle: nil)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .myWhiteColor()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.register(SelectionTableViewCell.self, forCellReuseIdentifier: SelectionTableViewCell.reuseID)
        tableView.register(SelectionTableViewHeader.self, forHeaderFooterViewReuseIdentifier: SelectionTableViewHeader.reuseID)
        
        if let index = model.firstIndex(of: selectedItem) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        } else {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
        
        view.backgroundColor = UIColor.myLabelColor().withAlphaComponent(0.5)
    }
    
}


// MARK: - Table view data source
extension SelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SelectionTableViewCell.reuseID, for: indexPath) as? SelectionTableViewCell {
            cell.configure(value: model[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SelectionTableViewHeader.reuseID) as? SelectionTableViewHeader {
            header.headerText.text = tableDescription
            header.cancelButton.addTarget(self, action: #selector(cancelTupped), for: .touchUpInside)
            header.saveButton.addTarget(self, action: #selector(saveTupped), for: .touchUpInside)
            return header
        } else {
            return nil
        }
    }
}

extension SelectionViewController {
    
    @objc private func cancelTupped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTupped() {
        saveFunc(model[tableView.indexPathForSelectedRow?.item ?? 0])
        dismiss(animated: true, completion: nil)
    }
}
extension SelectionViewController {
    private func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

