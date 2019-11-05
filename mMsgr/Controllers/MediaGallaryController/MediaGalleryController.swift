//
//  MediaGalleryController.swift
//  mMsgr
//
//  Created by jonahaung on 14/8/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class MediaGalleryController: UIViewController, MainCoordinatorDelegatee {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 200, height: 200)
        let x = UICollectionView(frame: .zero, collectionViewLayout: layout)
        x.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        x.allowsMultipleSelection = true
        x.delegate = self
        x.dataSource = self
        x.register(MediaGalleryCell.self)
        x.setBackgroundImage()
        return x
    }()
    
    var room: Room?
    var msgType: MsgType?
    
    var blockOperations = [BlockOperation]()
    
    var frc: NSFetchedResultsController<Message>?
    
    var collectionViewIsEditing: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem = collectionViewIsEditing ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTappedEdit(_:))) : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTappedEdit(_:)))
            navigationController?.setToolbarHidden(!collectionViewIsEditing, animated: true)
            vibrate(vibration: .heavy)
        }
    }

    override func loadView() {
        view = collectionView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .top
        
        navigationItem.title = "Media Gallery"
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(toolBarDidTappedCancel))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(toolBarDidDelete))
        setToolbarItems([cancel, UIBarButtonItem.space(), delete ], animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTappedEdit(_:)))
        
        if let type = msgType {
            frc = room?.getMediaFRC(type: type)
            
            do {
               try  frc?.performFetch()
            } catch {
                print(error.localizedDescription)
                
            }
            frc?.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @objc private func didTappedEdit(_ sender: UIBarButtonItem) {
        if collectionViewIsEditing {
            toolBarDidTappedCancel()
        } else {
            collectionViewIsEditing = true
        }
    }
    
    @objc private func toolBarDidTappedCancel() {
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            indexPaths.forEach{ collectionView.deselectItem(at: $0, animated: true )}
        }
        collectionViewIsEditing = false
    }
    
    @objc private func toolBarDidDelete() {
        collectionViewIsEditing = true
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            let msgs = indexPaths.map{ frc?.object(at: $0 )}.compactMap{$0}
            msgs.asyncForEach(completion: {
                self.collectionViewIsEditing = false
            }) { (msg, next) in
                msg.delete()
                next()
            }
        }
    }
}

extension MediaGalleryController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return frc?.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return frc?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaGalleryCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        guard let msg = frc?.object(at: indexPath) else { return cell }
        cell.configure(msg)
        return cell
    }

}
extension MediaGalleryController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch msgType! {
        case .Audio, .Location:
            return CGSize(width: collectionView.bounds.width/2 - 20, height: collectionView.bounds.width/2 - 20)
        case .Photo, .Video:
            guard let msg = frc?.object(at: indexPath) else { return .zero }
            
            let newWidth = Double(collectionView.bounds.width/2) - 20
            let scale = newWidth / msg.x
            let newHeight = msg.y * scale
            return CGSize(width: newWidth, height: newHeight)
        default:
            return .zero
        }
    }
    
    // select
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionViewIsEditing {
            return true
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? MediaGalleryCell, let msg = frc?.object(at: indexPath) else { return false }
            showMediaViewer(for: msg, from: cell.imageView)
            return false
        }
    }
}
/**
 FRC Delegate
 */

extension MediaGalleryController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll()
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append( BlockOperation(block: { [weak self] in
                guard let this = self, let newIndexPath = newIndexPath else { return }
            
                this.collectionView.insertItems(at: [newIndexPath])

            }))
            break
        case .update:
            blockOperations.append( BlockOperation(block: { [weak self] in
                
                guard let this = self, let indexPath = indexPath else { return }
                this.collectionView.reloadItems(at: [indexPath])
            }))
            break
        case .move:
            blockOperations.append( BlockOperation(block: { [weak self] in
                if let this = self, let indexPath = indexPath, let newIndexPath = newIndexPath {
                    
                    this.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }))
            break
        case .delete:
            blockOperations.append( BlockOperation(block: { [weak self] in
                if let this = self, let indexPath = indexPath {
                    this.collectionView.deleteItems(at: [indexPath])
                }
            }))
            break
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
            }))
            break
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
            }))
            break
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
            }))
            break
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.moveSection(sectionIndex, toSection: sectionIndex)
            }))
            break
        @unknown default:
            break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            blockOperations.forEach{ $0.start() }
        }, completion: { [weak self] done in
            guard done == true, let sself = self else { return }
            sself.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}

