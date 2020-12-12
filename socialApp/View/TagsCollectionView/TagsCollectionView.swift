//
//  TagsCollectionView.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class TagsCollectionView: UIView {
    private var collectionView: UICollectionView?
    private var hightCollectionViewConstraint: NSLayoutConstraint?
    private var unselectTags: [MTag] = []
    private var selectedTags: [MTag] = []
    private var unselectTagsString: [String] = []
    private var selectedTagsString: [String] = []
    private var hightIsSetup = false
    private var headerText = ""
    private var headerFont: UIFont = .avenirRegular(size: 16)
    private var headerColor: UIColor = .myLabelColor()
    private var tagTextField = OneLineTextField(isSecureText: false, tag: 1)
    private var dataSource: UICollectionViewDiffableDataSource<SectionTagsCollectionView,MTag>?
    weak var tagsDelegate: TagsCollectionViewDelegate?
    
    init(unselectTags: [String],
         selectTags: [String],
         headerText: String,
         headerFont: UIFont,
         headerColor: UIColor,
         textFieldPlaceholder: String = "") {
        
        super.init(frame: .zero)
        self.headerText = headerText
        self.headerFont = headerFont
        self.headerColor = headerColor
        self.unselectTagsString = unselectTags
        self.selectedTagsString = selectTags
        self.tagTextField.placeholder = textFieldPlaceholder
        
        setup()
        setupCollectioView()
        setupConstraints()
        setupDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tagTextField.delegate = self
        tagTextField.addToolBar(target: self, doneSelector: #selector(textFieldDonePressed))
    }
    
    
    //MARK: addTag
    private func addTag(text: String) {
    
        guard text != "" else { return }
        
        if !selectedTags.contains(where: { mTag -> Bool in
            mTag.tagText.lowercased() == text.lowercased()
        }) {
            let newMTag = MTag(tagText: text, isSelect: true)
            selectedTags.append(newMTag)
            updateDataSource(animating: false)
        }
    }
    
    //MARK: textFieldDonePressed
    @objc private func textFieldDonePressed(){
        guard let newTag = tagTextField.text else { return }
        addTag(text: newTag)
        tagTextField.text = ""
        tagTextField.resignFirstResponder()
    }
    
    //MARK: configure
    func configure(unselectTags: [String], selectedTags: [String]){
        self.unselectTagsString = unselectTags
        self.selectedTagsString = selectedTags
        
        unselectTags.forEach {[weak self] stringTag in
            guard let unselectTags = self?.unselectTags else { return }
            if !unselectTags.contains(where: { mTag -> Bool in
                mTag.tagText.lowercased() == stringTag.lowercased()
            }) {
                let tag = MTag(tagText: stringTag, isSelect: false)
                self?.unselectTags.append(tag)
            }
        }
        
        selectedTags.forEach {[weak self] stringTag in
            guard let selectedTags = self?.selectedTags else { return }
            if !selectedTags.contains(where: { mTag -> Bool in
                mTag.tagText.lowercased() == stringTag.lowercased()
            }) {
                let tag = MTag(tagText: stringTag, isSelect: true)
                self?.selectedTags.append(tag)
            }
        }
        
        updateDataSource(animating: false)
      
    }
    
    func firstSetup() {
        configure(unselectTags: unselectTagsString, selectedTags: selectedTagsString)
    }
    
    //MARK: getSelectedTags
    func getSelectedTags() -> [String] {
        let seletedTagsString = selectedTags.map { mTag -> String in
            mTag.tagText
        }
        return seletedTagsString
    }
    
    //MARK: getUnselectedTags
    func getUnselectedTags() -> [String] {
        let unselectedTagsString = unselectTags.map { mTag -> String in
            mTag.tagText
        }
        return unselectedTagsString
    }
}

//MARK: setupCollectioView
extension TagsCollectionView {
    private func setupCollectioView() {
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: setupCompositionLayout())
        if let collectionView = collectionView {
            collectionView.backgroundColor = .clear
            collectionView.delegate = self
            collectionView.isScrollEnabled = false
            collectionView.register(TagsCollectionViewCell.self,
                                    forCellWithReuseIdentifier: TagsCollectionViewCell.reuseID)
            collectionView.register(TagsSelectCollectionViewCell.self,
                                    forCellWithReuseIdentifier: TagsSelectCollectionViewCell.reuseID)
            collectionView.register(TagsCollectionViewHeader.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: TagsCollectionViewHeader.reuseId)
        }
    }
    
    //MARK: setupCompositionLayout
    private func setupCompositionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {[weak self] sectionIndex, environment -> NSCollectionLayoutSection? in
            guard let sectionName = SectionTagsCollectionView(rawValue: sectionIndex) else { fatalError("Unknown section index")}
            
            switch sectionName {
                
            case .unselectTags:
                return self?.setupSection(withHeader: false)
            case .selectedTags:
                return  self?.setupSection(withHeader: true)
            }
        }
        return layout
    }
    
    //MARK: setupSection
    private func setupSection(withHeader: Bool) -> NSCollectionLayoutSection {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .estimated(30))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1),
                                          heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        if withHeader {
            section.boundarySupplementaryItems = [header]
        }
       
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                        leading: 0,
                                                        bottom: 10,
                                                        trailing: 0)
        return section
    }
}
//MARK: diffableDataSource
extension TagsCollectionView {
    private func setupDataSource() {
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        dataSource = UICollectionViewDiffableDataSource<SectionTagsCollectionView,MTag>(
            collectionView: collectionView,
            cellProvider: { collectionViewProvider, indexPath, item -> UICollectionViewCell? in
                
                guard let section = SectionTagsCollectionView(rawValue: indexPath.section) else { fatalError("Unknown section")}
                
                switch section {
                
                case .unselectTags:
                    guard let cell = collectionViewProvider.dequeueReusableCell(withReuseIdentifier: TagsCollectionViewCell.reuseID,
                                                                                for: indexPath) as? TagsCollectionViewCell else {
                        fatalError("Can't cast to TagsCollectionViewCell")
                    }
                    cell.configure(tag: item)
                    return cell
                case .selectedTags:
                    guard let cell = collectionViewProvider.dequeueReusableCell(withReuseIdentifier: TagsSelectCollectionViewCell.reuseID,
                                                                                for: indexPath) as? TagsSelectCollectionViewCell else {
                        fatalError("Can't cast to TagsSelectCollectionViewCell")
                    }
                    cell.configure(tag: item)
                    return cell
                }
                
                
            })
        
        dataSource?.supplementaryViewProvider = {[weak self] collectionViewProvider, kind, indexPath in
            guard let header = collectionViewProvider.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: TagsCollectionViewHeader.reuseId,
                                                                                 for: indexPath) as? TagsCollectionViewHeader else {
                fatalError("Can't cast to TagsCollectionViewHeader")
            }
            header.configure(text: self?.headerText,
                             font: self?.headerFont,
                             textColor: self?.headerColor)
            return header
        }
    }
    
    //MARK: updateDataSource
    func updateDataSource(animating: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionTagsCollectionView,MTag>()
        snapshot.appendSections([.unselectTags, .selectedTags])
        snapshot.appendItems(unselectTags, toSection: .unselectTags)
        snapshot.appendItems(selectedTags, toSection: .selectedTags)
        
        dataSource?.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
            
                self?.setNeedsUpdateConstraints()
                self?.setNeedsLayout()
            
        })
        
        tagsDelegate?.tagTextDidChange?(tagsCollectionView: self)
    }
    
    //MARK: updateConstraints
    override func updateConstraints() {
        
        //don't set 0 size, than contentSize will always be equal 0
        if collectionView?.contentSize.height != 0 {
            guard let size = collectionView?.contentSize.height else { return }
             hightCollectionViewConstraint?.constant = size
            
            //set first setup hight is complite for stop update layoutSubvies
            hightIsSetup = true
            tagsDelegate?.tagTextConstraintsDidChange?(tagsCollectionView: self)
        }
        super.updateConstraints()
    }
    
    
    //MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hightIsSetup {
            //needs to be updated until the height is first set
            setNeedsLayout()
            setNeedsUpdateConstraints()
        }
    }
}


//MARK: collectionViewDelegate
extension TagsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionName = SectionTagsCollectionView(rawValue: indexPath.section) else { fatalError("Unknown section")}
        guard var element = dataSource?.itemIdentifier(for: indexPath) else { fatalError("Unknown element")}
        
        switch sectionName {
        
        case .unselectTags:
            unselectTags.remove(at: indexPath.item)
            if !selectedTags.contains(where: { mTag -> Bool in
                mTag.tagText.lowercased() == element.tagText.lowercased()
            }) {
                element.isSelect = true
                selectedTags.append(element)
            }
            
            updateDataSource()
        case .selectedTags:
            selectedTags.remove(at: indexPath.item)
            updateDataSource()
        }
    }
}

//MARK: UITextFieldDelegate
extension TagsCollectionView: UITextFieldDelegate {
    
    private func backspacePressed() {
        if tagTextField.text == "" {
            if !selectedTags.isEmpty {
                selectedTags.removeLast()
                updateDataSource()
            }
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let newTag = textField.text else { return true }
        addTag(text: newTag)
        textField.text = ""
        tagsDelegate?.tagTextFiledShouldReturn?(tagsCollectionView: self, text: newTag)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLengthTags = 25
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= maxLengthTags
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tagsDelegate?.tagTextFiledDidBeginEditing?(tagsCollectionView: self)
    }
}


//MARK: setupConstraints
extension TagsCollectionView {
    private func setupConstraints() {
        guard let collectionView = collectionView else { fatalError("collection view is nil")}
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tagTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        addSubview(tagTextField)
        hightCollectionViewConstraint = collectionView.heightAnchor.constraint(equalToConstant: 100)
        hightCollectionViewConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tagTextField.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            tagTextField.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            tagTextField.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            tagTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
