/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Pinned sction headers example
 */

import UIKit
import MessageUI
import PhoneNumberKit
import CoreData

class ContactsViewController: UIViewController, MainCoordinatorDelegatee, AlertPresentable {

    private var isFIrstTimeLoading = true
    let contactManager = ContactsManager()
    
    lazy var dataProvider: ContactsDataProvider = ContactsDataProvider()
    
    
    lazy var collectionView: UICollectionView = { [weak self] in
        $0.backgroundColor = .systemBackground
        $0.alwaysBounceVertical = true
        $0.backgroundView = UIView()
        $0.backgroundView?.backgroundColor = UIColor.systemGroupedBackground
        $0.delegate = self
        $0.register(ContactsCollectionViewCell.self)
        $0.register(ContactsHeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        $0.setBackgroundImage()
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: createLayout()))
    
    let headerView = ContactTableHeaderView()
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        dataProvider.configureDataSource(collectionView)
        contactManager.delegate = self
        dataProvider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFIrstTimeLoading {
            isFIrstTimeLoading = false
            dataProvider.fetchData()
            contactManager.checkStatus()
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
         collectionView.setBackgroundImage()
        }
    }
}

extension ContactsViewController {
    private func setupViews() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
        
        headerView.addButton.addTarget(self, action: #selector(ContactsViewController.didTapAddContacts), for: .touchUpInside)
        headerView.toggle.addTarget(self, action: #selector(ContactsViewController.toggleSwitch(_:)), for: .valueChanged)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)

            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 15)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(60)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            sectionHeader.pinToVisibleBounds = true
            sectionHeader.zIndex = 3
            section.boundarySupplementaryItems = [sectionHeader]
            
           
            return section
        }
        
        
        return layout
    }
}

extension ContactsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let friend = dataProvider.dataSource.itemIdentifier(for: indexPath) else { return }
        if friend.isFriend {
            if let room = friend.room {
                gotoChatLogController(for: room)
            }else {
                if let room = friend.createAndLinkRoom() {
                    gotoChatLogController(for: room)
                }
            }
            
        } else {
            self.handleInvitation(friend: friend)
        }
    }
}
extension ContactsViewController: ContactsManagerDelegate {

    func contactsManager(didFinishedCheckingStatus manager: ContactsManager) {
        dataProvider.fetchData()
    }
    
    func syncContacts() {
        self.contactManager.forceSync()
    }
    
    
    func contactsManager(didChangeOperationsStatus status: String) {
        headerView.label.text = status
    }
}


extension ContactsViewController: ContactsDataProviderDelegate {
    func provider(_ provider: ContactsDataProvider, didUpdateSnapshotWith itemsCount: Int, for isAllContacts: Bool) {
        self.headerView.label.text = " \(itemsCount)"
    }
}

extension ContactsViewController: MFMessageComposeViewControllerDelegate {
    
    private func handleInvitation(friend: Friend) {
        let alert = UIAlertController(style: .actionSheet)
        let title = "Invite Friend"
        let message = "\(friend.displayName) is not a mMsgr user. Please invite \(friend.displayName.firstWord) to join mMsgr"
        alert.set(title: title, font: UIFont.preferredFont(forTextStyle: .title3))
        alert.set(message: message, font: UIFont.preferredFont(forTextStyle: .callout))
        
        alert.addAction(image: nil, title: "Invite via SMS", color: nil, style: .default, isEnabled: true) { _ in
            if let phoneNumber = friend.phoneNumber {
                self.handleSendSMS([phoneNumber])
            }
        }
        
        alert.addAction(image: nil, title: "Other Invite Methods", color: UIColor.myappGreen, style: .default, isEnabled: true) { _ in
            AppUtility.shareApp()
        }
        
        alert.addCancelAction()
        alert.show()
    }
    
    @objc private func toggleSwitch(_ control: SwitchBUtton) {
        dataProvider.isAllContacts = !control.isOn
    }
    
    private func handleSendSMS(_ numbers: [String]) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Check out mMsgr, the only chat application with burmese translator. Get it for free at   https://itunes.apple.com/sg/app/mmsgr/id1434410940?mt=8"
        messageVC.recipients = numbers
        messageVC.messageComposeDelegate = self
        UIApplication.topViewController()?.present(messageVC, animated: true, completion: nil)
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}




final class ContactTableHeaderView: CustomView {
    
    let toggle: SwitchBUtton = {
        return $0
    }(SwitchBUtton())
    
    let addButton: UIButton = {
        $0.setPreferredSymbolConfiguration(.init(pointSize: 25, weight: .medium), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        return $0
    }(UIButton(type: .custom))
    
    let label: UILabel = {
        $0.text = "0 Contacts"
        $0.textAlignment = .left
        $0.font = UIFont.monoSpacedFont
        $0.textColor = .myAppYellow
        return $0
    }(UILabel())
    
    override func setup() {
        super.setup()
       
        let stackView = UIStackView(arrangedSubviews: [toggle, label, addButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .bottom
        stackView.spacing = UIStackView.spacingUseSystem
        addSubview(stackView)
        stackView.fillSuperview()
        
    }

}
