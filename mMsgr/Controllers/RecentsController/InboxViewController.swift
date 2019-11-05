//
//  InboxViewController.swift
//  mMsgr
//
//  Created by Aung Ko Min on 28/7/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData

class InboxViewController: UIViewController, MainCoordinatorDelegatee {
    
    private lazy var collectionView: UICollectionView = { [weak self] in
        $0.backgroundColor = nil
        $0.alwaysBounceVertical = true
        $0.register(InboxCell.self)
        $0.register(FavoriteCell.self)
        $0.delegate = self
        $0.setBackgroundImage()
        return $0
        }(UICollectionView(frame:  UIScreen.main.bounds, collectionViewLayout: createLayout()))
    
    let dataProvider = InboxDataProvider()
    
    override func loadView() {
        view = collectionView
    }
    private var isFirstTimeLoading = true
    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider.configureDataSource(collectionView)
        dataProvider.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstTimeLoading {
            dataProvider.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTimeLoading {
            isFirstTimeLoading = false
        } else {
            dataProvider.reloadFavorites()
        }
    }
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
        collectionView.setBackgroundImage()
       }
   }
}

extension InboxViewController: InboxDataProviderDelegate {
    
    func didChangeUnreadValue(value: Int) {
        Async.main {
            self.tabBarItem.badgeValue = value == 0 ? nil : value.description
        }
                           
    }
}



extension InboxViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
           
            guard let layoutKind = InboxDataProvider.SectionLayoutKind(rawValue: sectionIndex) else { return nil }

            let columns = layoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
            let isRecents = layoutKind == .recents
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
            heightDimension: isRecents ? .estimated(80) : .fractionalWidth(0.2))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupWidth = NSCollectionLayoutDimension.fractionalWidth(1)
            let groupHeight = isRecents ? NSCollectionLayoutDimension.estimated(80) : .fractionalWidth(0.2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = isRecents ? NSDirectionalEdgeInsets.zero : NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
                        
            section.interGroupSpacing = 5
            return section
            
        }
        return layout
    }
}


extension InboxViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.isSafeToInteract else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        SoundManager.playSound(tone: .Tock)
        if indexPath.section == 0, let friend = dataProvider.friend(at: indexPath), let room = friend.createAndLinkRoom() {
            gotoChatLogController(for: room)
        }else {
            guard let lastMsg = dataProvider.lastMsg(at: indexPath), let room = lastMsg.room else { return }
            self.gotoChatLogController(for: room)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] actions -> UIMenu? in
            guard let `self` = self else { return nil }
            var actions = [UIAction]()
            
            if indexPath.section == 0 {
        
                let action = UIAction(title: "View Profile") { action in
                    let alert = UIAlertController(title: action.title, message: nil, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                actions.append(action)
            }else {
    
                let action = UIAction(title: "View Profile") { action in
                    let alert = UIAlertController(title: action.title, message: nil, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                actions.append(action)
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "delete.left"), identifier: nil, discoverabilityTitle: "clear all the messages", attributes: .destructive, state: .on) { _ in
                    Room.delete(in: PersistenceManager.sharedInstance.viewContext)
                    
                }
                actions.append(delete)
                
            }
            
            return UIMenu(title: "Menu", image: UIImage(systemName: "circle.fill"), identifier: nil, options: [.displayInline], children: actions)
        }
        return configuration
    }
}
