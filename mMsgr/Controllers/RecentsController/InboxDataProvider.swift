//
//  InboxDataProvider.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData


extension Message {
    class func recentsFetchRequest() -> NSFetchRequest<Message> {
        let request = NSFetchRequest<Message>(entityName: "Message")
        request.predicate = NSPredicate(format: "lastMsgPoiter != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["room", "room.member", "sender"]
        request.shouldRefreshRefetchedObjects = true

        return request
    }
}
extension Friend {
    class func recentsFetchRequest() -> NSFetchRequest<Friend> {
        let request = NSFetchRequest<Friend>(entityName: "Friend")
        request.predicate = NSPredicate(format: "uid != phoneNumber && lastAccessedDate != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "lastAccessedDate", ascending: false)]
        request.fetchBatchSize = 5
        request.fetchLimit = 5
        request.shouldRefreshRefetchedObjects = true
        return request
    }
}

protocol InboxDataProviderDelegate: class {
    func didChangeUnreadValue(value: Int)
}
final class InboxDataProvider: NSObject {
    
    enum SectionLayoutKind: Int, CaseIterable {
        
        case favorite, recents
        
        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 650
            switch self {
            case .favorite:
                return 5
            case .recents:
                return wideMode ? 2 : 1
            }
        }
        
    }
    weak var delegate: InboxDataProviderDelegate?
    
    var lastMsgs: [Message] {
        return frc.fetchedObjects ?? []
    }
    private var favorites = [Friend]()
    private var favFetchRequest = Friend.recentsFetchRequest()
    private var isUpdating = false
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, NSManagedObject>!
    private var currentSnapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, NSManagedObject>? = nil
    lazy var frc: NSFetchedResultsController<Message> = {
        let request = Message.recentsFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PersistenceManager.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
        }catch { Log(error)}
        frc.delegate = self
        return frc
    }()

    deinit {
        print("Deinit: InboxDataProvider")
    }
}

extension InboxDataProvider {
    
    func configureDataSource(_ cv: UICollectionView) {
        
        do {
            favorites = try frc.managedObjectContext.fetch(favFetchRequest)
        }catch { Log(error)}
        
        
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, NSManagedObject>(collectionView: cv) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, object: NSManagedObject) -> UICollectionViewCell? in
            guard let `self` = self else { return nil }
            guard let section = SectionLayoutKind(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .recents:
                let cell: InboxCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.msg = self.lastMsgs[indexPath.item]
                return cell
            case .favorite:
                let cell: FavoriteCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                if let friend = object as? Friend {
                    cell.configure(friend)
                }
               return cell
            }
        }
    }
}

extension InboxDataProvider {
    
    func friend(at indexPath: IndexPath) -> Friend? {
        return dataSource.itemIdentifier(for: indexPath) as? Friend
    }
    
    func lastMsg(at indexPath: IndexPath) -> Message? {
        return dataSource.itemIdentifier(for: indexPath) as? Message
    }
    
}

extension InboxDataProvider: NSFetchedResultsControllerDelegate {
    
    func reloadFavorites() {
        if isUpdating { return }
        if currentSnapshot != nil {
            do {
                currentSnapshot?.deleteItems(favorites)
                favorites = try frc.managedObjectContext.fetch(favFetchRequest)
                currentSnapshot?.appendItems(favorites, toSection: .favorite)
                dataSource.apply(currentSnapshot!, animatingDifferences: true) {
                    print("applied")
                }
                
            }catch { Log(error)}
        }
    }
    func reloadData() {
        currentSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, NSManagedObject>()
        currentSnapshot?.appendSections([.favorite, .recents])
        currentSnapshot?.appendItems(favorites, toSection: .favorite)
        currentSnapshot?.appendItems(lastMsgs, toSection: .recents)
        dataSource.apply(currentSnapshot!, animatingDifferences: false)
        let value = lastMsgs.filter{ !$0.hasRead && !$0.isSender }.count
        delegate?.didChangeUnreadValue(value: value)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        isUpdating = true
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentSnapshot?.deleteSections([.recents])
        currentSnapshot?.insertSections([.recents], afterSection: .favorite)
        currentSnapshot?.appendItems(lastMsgs, toSection: .recents)
        dataSource.apply(currentSnapshot!, animatingDifferences: true) {
            print("applied")
        }
        isUpdating = false
        let value = lastMsgs.filter{ !$0.hasRead && !$0.isSender }.count
        delegate?.didChangeUnreadValue(value: value)
    }
}
