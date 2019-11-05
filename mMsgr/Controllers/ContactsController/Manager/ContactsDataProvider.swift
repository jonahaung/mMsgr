//
//  ContactsData.swift
//  mMsgr
//
//  Created by Aung Ko Min on 15/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData

protocol ContactsDataProviderDelegate: class {
    func provider(_ provider: ContactsDataProvider, didUpdateSnapshotWith itemsCount: Int, for isAllContacts: Bool)
}

final class ContactsDataProvider {
    
    weak var delegate: ContactsDataProviderDelegate?
    
    var isAllContacts: Bool = true {
        didSet {
            guard oldValue != isAllContacts else { return }
            SoundManager.playSound(tone: .Tock)
            self.fetchData()
           
        }
    }

    var dataSource: UICollectionViewDiffableDataSource<String, Friend>! = nil
    
    var friends = [Friend]()

    private lazy var context = PersistenceManager.sharedInstance.viewContext
    private let request: NSFetchRequest<Friend> = {
        $0.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
        $0.fetchBatchSize = 50
        $0.shouldRefreshRefetchedObjects = true
        $0.includesPendingChanges = true
        return $0
    }(NSFetchRequest<Friend>(entityName: "Friend"))
    
    
    func fetchData() {
        do {
            friends = try context.fetch(request)
             self.reloadData()
        }catch { print(error)}
    }
    
    private func reloadData() {
        
        var snap = NSDiffableDataSourceSnapshot<String, Friend>()
        let filtered = self.isAllContacts ? self.friends : self.friends.filter{ $0.isFriend }
        let groups = filtered.group{ $0.firstCharacter }
        
        var datas = [String: [Friend]]()
        groups.forEach { (group) in
            if let key = group.first?.firstCharacter{
                datas[key] = group
            }
            
        }
        let sorted = datas.sorted{ $0.key < $1.key }
        for data in sorted {
            snap.appendSections([data.key])
            snap.appendItems(data.value, toSection: data.key)
        }
        self.dataSource.apply(snap, animatingDifferences: false)
        self.delegate?.provider(self, didUpdateSnapshotWith: self.dataSource.snapshot().itemIdentifiers.count, for: self.isAllContacts)
        
    }
    
}

extension ContactsDataProvider {
    
    func configureDataSource(_ collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<String, Friend>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Friend) -> UICollectionViewCell? in
            let cell: ContactsCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(identifier)
            return cell
        }
        
        dataSource.supplementaryViewProvider = {[unowned self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header: ContactsHeaderCollectionView = collectionView.dequeueReusableSupplementaryViewOfKind(elementKind: kind, forIndexPath: indexPath)
                header.titleText = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                return header
            default:
                fatalError()
            }
        }
    }
}
