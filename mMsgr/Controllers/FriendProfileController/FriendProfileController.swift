//
//  FriendProfileController.swift
//  mMsgr
//
//  Created by jonahaung on 20/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import MessageUI

protocol ColorPickerDelegate: class {
    func colorDelegate(didSelectColor profile: Theme)
}

class FriendProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate, AlertPresentable, MainCoordinatorDelegatee {
    
    var friend: Friend!
    
    private enum SettingsGroup: String {
        case about = "About"
        case messages = "Messages"
        case settings = "Settings"
        case theme = "Theme"
        var settings: [Setting] {
            switch self {
            case .about: return [.name, .phoneNumber, .country]
            case .messages: return [.photos, .videos, .audios, .locations]
            case .settings: return [.clearMessages, .deleteContact, .blockContact, .reportContact]
            case .theme: return [.setThemeColor]
            }
        }
    }
    
    enum Setting: String {
        case name = "Name"
        case phoneNumber = "Phone"
        case country = "Country"
        case photos = "Photos Messages"
        case videos = "Videos Messages"
        case audios = "Audio Messages"
        case locations = "Location Messages"
        case clearMessages = "Clear All Messages"
        case deleteContact = "Delete Contact"
        case blockContact = "Block This Contact"
        case reportContact = "Report Contact"
        case setThemeColor = ""
        
        var image: UIImage? {
            switch self {
            case .name:
                return UIImage(systemName: "person.icloud.fill")
            
            case .phoneNumber:
                return UIImage(systemName: "teletype.answer")
            case .country:
                return UIImage(systemName: "globe")
            case .photos:
                return UIImage(systemName: "photo.on.rectangle.fill")
            case .videos:
                return UIImage(systemName: "film.fill")
            case .audios:
                return UIImage(systemName: "hifispeaker.fill")
            case .locations:
                return UIImage(systemName: "map.fill")
            case .clearMessages:
                return UIImage(systemName: "trash.slash.fill")
            case .deleteContact:
                return UIImage(systemName: "delete.left.fill")
            case .blockContact:
                return UIImage(systemName: "hand.raised.fill")
            case .reportContact:
                return UIImage(systemName: "checkmark.seal.fill")
            case .setThemeColor:
                return UIImage(systemName: "user.circle.fill")
            }
        }
        var isSelectable: Bool {
            switch self {
            case .photos, .videos, .audios, .locations, .clearMessages, .deleteContact, .blockContact, .reportContact, .setThemeColor :
                return true
            default:
                return false
            }
        }
        
        var height: CGFloat {
            switch self {
            case .setThemeColor: return 350
            default:
                return 50
            }
        }
    }
    
    private lazy var settingGroups: [SettingsGroup] = [.about, .messages, .settings, .theme]
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.bounces = true
        $0.separatorColor = UIColor.systemFill
        $0.separatorStyle = .singleLine
        $0.register(DefaultTableViewCell.self)
        $0.register(RightSubtitleTableViewCell.self)
        $0.register(ColorPlateTableCell.self)
        $0.setBackgroundImage()
        return $0
        }(UITableView(frame: .zero, style: .insetGrouped))
    
    override func loadView() {
        view = tableView
    }
    
    lazy var tableHeaderView: TableHeaderAvatarView = { [unowned self] in
        $0.avatarImageView.badgeColor = .clear
        return $0
        }(TableHeaderAvatarView())
    
    var avatarImageView: BadgeAvatarImageView {
        return tableHeaderView.avatarImageView
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tableView.tableHeaderView {
            
            var headerFrame = headerView.frame
            headerFrame.size.height = tableView.bounds.width
            if headerFrame != headerView.frame {
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        } else {
            let tableWidth = tableView.bounds.width
            tableHeaderView.frame = CGRect(origin: .zero, size: CGSize(width: .greatestFiniteMagnitude, height: tableWidth))
            tableView.tableHeaderView = self.tableHeaderView
            tableHeaderView.avatarImageView.loadImage(for: friend, refresh: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "User Profile"
    }
    
    deinit {
        print("DEINIT: FriendProfileController")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingGroups[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingGroups[indexPath.section].settings[indexPath.row]
        
        switch setting {
        case .name:
            let cell: RightSubtitleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.textLabel?.text = setting.rawValue
            cell.detailTextLabel?.text = friend.displayName
            cell.imageView?.image = setting.image
            return cell
        case .country:
            let cell: RightSubtitleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.textLabel?.text = setting.rawValue
            cell.detailTextLabel?.text = friend.country
            cell.imageView?.image = setting.image
            return cell
            
        case .phoneNumber:
            let cell: RightSubtitleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.textLabel?.text = setting.rawValue
            cell.detailTextLabel?.text = friend.phoneNumber
            cell.imageView?.image = setting.image
            return cell
        case .photos, .videos, .audios, .locations:
            let cell: RightSubtitleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.textLabel?.text = setting.rawValue
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = setting.image
            return cell
        case .clearMessages, .deleteContact, .blockContact, .reportContact:
            let cell: DefaultTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            if setting == .blockContact {
                cell.textLabel?.text = friend.hasBlocked ? "Unblock Contact" : "Block Contact"
            } else {
                cell.textLabel?.text = setting.rawValue
            }
            cell.imageView?.image = setting.image? .imageWithSize(size: CGSize(20), extraMargin: 5)?.withRenderingMode(.alwaysTemplate)
            return cell
        case .setThemeColor:
            let cell: ColorPlateTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let setting = settingGroups[indexPath.section].settings[indexPath.row]
        return setting.height
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let setting = settingGroups[indexPath.section].settings[indexPath.row]
        return setting.isSelectable
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = settingGroups[section]
        return group.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let room = friend.createAndLinkRoom() else { return }
        let setting = settingGroups[indexPath.section].settings[indexPath.row]
        
        switch setting {
            
        case .photos:
            gotoMediaGalleryController(room: room, msgType: .Photo)
        case .videos:
            gotoMediaGalleryController(room: room, msgType: .Video)
        case .audios:
            gotoMediaGalleryController(room: room, msgType: .Audio)
        case .locations:
            gotoMediaGalleryController(room: room, msgType: .Location)
        case .clearMessages:
            AlertPresentable_showAlert(buttonText: "Continue", message: "All messages will be deleted", cancelButton: true, style: .destructive) { accept in

                if accept {
                    let context = PersistenceManager.sharedInstance.editorContext
                    context.delete(room)
                    try? context.save()
                }
                
                
            }
        case .deleteContact:
            AlertPresentable_showAlert(buttonText: "Continue", message: "This contact and all its messages will be deleted", cancelButton: true, style: .destructive) { [weak self] accept in
                guard let `self` = self else { return }
                if accept {
                    let context = PersistenceManager.sharedInstance.editorContext
                    if let friend = try? context.localInstance(of: self.friend) {
                        context.delete(friend)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        case .blockContact:
            let text = friend.hasBlocked ? "Unblock this Coontact" : "Block this Contact"
            AlertPresentable_showAlert(buttonText: text, message: nil, cancelButton: true, style: .destructive) { [weak self] accept in
                guard let `self` = self else { return }
                if accept {
                    self.friend.state = self.friend.hasBlocked ? 0 : 1
                    tableView.reloadRows(at: [indexPath], with: .left)
                }
                
            }
        case .reportContact:
            if MFMailComposeViewController.canSendMail(), let user = GlobalVar.currentUser {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("mMsgr: Report Contact")
                mail.setToRecipients(["mmsgrapp@gmail.com"])
                mail.setMessageBody("<p> mMsgr User ID : \(user.uid), mMsgr Reported User ID : \(friend.uid)</p>", isHTML: true)
                
                present(mail, animated: true)
            }
        default:
            break
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        
        header?.textLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        header?.backgroundView?.backgroundColor = nil
    }
}
extension FriendProfileController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            if result == .sent {
                self?.AlertPresentable_showAlert(buttonText: "OK", message: "Thank you for Reporting us. We will look into it and get back to you soon !")
            }
        }
        
    }
    
}
extension FriendProfileController: ColorPickerDelegate {
    
    
    
    func colorDelegate(didSelectColor profile: Theme) {
        let alert = UIAlertController(title: "Set this color?", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = profile.mainColor
        let action = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            let context = PersistenceManager.sharedInstance.editorContext
            context.performAndWait {
                if let fri = context.object(with: self.friend.objectID) as? Friend {
                    let room = fri.room
                    room?.themeValue = profile.type.rawValue
                    context.saveIfHasChnages()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }
        alert.addAction(action)
        
        alert.addCancelAction()
        
        alert.show()
        
        
    }
}


class ProfilePhotoCell: UITableViewCell, ReusableView {
    
    let profileImageView: AvatarImageView = {
        let x = AvatarImageView()
        x.diameter = 100
        x.isUserInteractionEnabled = true
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView)))
    }
    
    @objc private func didTapProfileImageView() {
        guard let image = profileImageView.currentImage else { return }
        let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: profileImageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        imageViewer.dismissCompletion = {
            print("dismissCompletion")
        }
        EXT_parentViewController?.present(imageViewer, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class ColorPlateTableCell: UITableViewCell, ReusableView, MainCoordinatorDelegatee {
    
    weak var delegate: ColorPickerDelegate?
    
    let items: [Theme] = {
        let all = ThemeType.items
        return all.map{ Theme(themeValue: $0.rawValue )}
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let x = UICollectionView(frame: .zero, collectionViewLayout: layout)
        x.showsHorizontalScrollIndicator = false
        x.alwaysBounceHorizontal = true
        x.backgroundColor = nil
        return x
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = nil
        collectionView.register(ColorCollectionCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        contentView.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorPlateTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let item = items[indexPath.item]
        cell.contentView.backgroundColor = item.mainColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        delegate?.colorDelegate(didSelectColor: item)
    }
}

class ColorCollectionCell: CollectionViewCell {
    
    override func setup() {
        super.setup()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 40
    }
}


