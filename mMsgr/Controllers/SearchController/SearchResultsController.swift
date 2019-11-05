/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
 */

import UIKit
import CoreData

final class SearchResultsController: UIViewController {
    
    private lazy var backgroundQueue = OperationQueue()
   
    lazy var context = PersistenceManager.sharedInstance.viewContext
    
    lazy var collectionView: UICollectionView = { [weak self] in
        $0.bounces = true
        $0.alwaysBounceVertical = true
        $0.register(SearchCollectionViewCell.self)
        $0.delegate = self
        return $0
        }(UICollectionView(frame:  UIScreen.main.bounds, collectionViewLayout: createLayout()))
    
    enum Section: CaseIterable {
        case main
    }
    
    override func loadView() {
        view = collectionView
    }
    
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Friend>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Friend>! = nil

    var searchText: String = "" {
        didSet {
            guard oldValue != searchText else { return }
            backgroundQueue.addOperation {
                let friends = self.friend_search(text: self.searchText)
                self.currentSnapshot = NSDiffableDataSourceSnapshot<Section, Friend>()
                self.currentSnapshot.appendSections([.main])
                self.currentSnapshot.appendItems(friends)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    func friend_search(text: String) -> [Friend] {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        let phone = NSPredicate(format: "phoneNumber CONTAINS %@", text)
        let name = NSPredicate(format: "displayName CONTAINS[c] %@", text)
        let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [phone, name])
        let onlyMmsgrFriend = NSPredicate(format: "phoneNumber != uid")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [orPredicate, onlyMmsgrFriend])
        request.fetchLimit = 10
        request.fetchBatchSize = 20
        do{
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    deinit {
        print("******** SearchControllerBaseViewController *******")
    }
}

extension SearchResultsController {
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 40)

        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.reuseIdentifier)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 40)
        section.decorationItems = [sectionBackgroundDecoration]

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.reuseIdentifier)
        return layout
    }
}



extension SearchResultsController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let friend = dataSource.itemIdentifier(for: indexPath)
        guard let room1 = friend?.createAndLinkRoom() else { return }
        GlobalVar.currentRoom = room1
        dismiss(animated: true) {
            guard let room = GlobalVar.currentRoom else { return }
            GlobalVar.theme = Theme(themeValue: room.themeValue)
            GlobalVar.currentRoom = room
            let x = ChatViewController()
            UIApplication.topViewController()?.navigationController?.pushViewController(x, animated: true)
        }
    }

}


extension SearchResultsController {
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Friend>(collectionView: collectionView) { [unowned self] (collectionView: UICollectionView, indexPath: IndexPath, friend: Friend) -> UICollectionViewCell? in
            let cell: SearchCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            
            if let friend = self.dataSource.itemIdentifier(for: indexPath) {
                cell.configure(for: friend)
            }
            
            return cell
        }
    
        
    }
}
