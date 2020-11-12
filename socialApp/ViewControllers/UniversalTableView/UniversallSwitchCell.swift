//
//  UniversallSwitchCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class UniversallSwitchCell: UITableViewCell, UnversalSwitchCell {
    
    static let reuseID = "UniversallSwitchCell"
    
    let cellImage = UIImageView()
    let cellLabel = UILabel(labelText: "", textFont: .avenirBold(size: 16),textColor: .myLabelColor())
    let moreInfoLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 12), textColor: .myGrayColor(), linesCount: 0)
    let switchControl = UISwitch()
    var withImage = false
    var timer: Timer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setup() {
        cellImage.tintColor = .mySecondButtonLabelColor()
        switchControl.thumbTintColor = .myWhiteColor()
        switchControl.onTintColor = .myLabelColor()
        
        contentView.isUserInteractionEnabled = false
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .myWhiteColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .myWhiteColor()
        backgroundView = unselectView
    }
    
    func configure(with: UniversalCollectionCellModel, withImage: Bool, switchIsOn: Bool, configureFunc: (()->Void)? ){
        
        cellLabel.text = with.description()
        switchControl.isOn = switchIsOn

        self.withImage = withImage
        if let image = with.image(), withImage {
            cellImage.image = image.withConfiguration(UIImage.SymbolConfiguration(font: .avenirRegular(size: 25), scale: .default))
        }
        if let configureFunc = configureFunc {
            configureFunc()
        }
    }
    
    func setupTimerUpdate(timerInterval: Int, tolerance: Double, updateFunc: @escaping ()-> Void) {
        let timeUpdateInterval = TimeInterval(timerInterval)
        timer = Timer.scheduledTimer(withTimeInterval: timeUpdateInterval, repeats: true) { timer in
            timer.tolerance = tolerance
            updateFunc()
        }
    }
    
    func setupSwitchAction(target: Any?, selector: Selector, forEvent: UIControl.Event) {
        switchControl.addTarget(target, action: selector, for: forEvent)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.layer.cornerRadius = frame.height / 2
        backgroundView?.layer.cornerRadius = frame.height / 2
    }
    
    private func setupConstraints(){
        
        addSubview(cellLabel)
        addSubview(moreInfoLabel)
        addSubview(switchControl)
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        moreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        
        if withImage {
            addSubview(cellImage)
            cellImage.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cellImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cellImage.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                cellLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -10),
                cellLabel.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 10),
                cellLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: 10),
                
                moreInfoLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 5),
                moreInfoLabel.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 10),
                moreInfoLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -10),
                
                switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                cellLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
                cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cellLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: 10),
                
                moreInfoLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 10),
                moreInfoLabel.leadingAnchor.constraint(equalTo:  leadingAnchor, constant: 20),
                moreInfoLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -10),
                
                switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
}

