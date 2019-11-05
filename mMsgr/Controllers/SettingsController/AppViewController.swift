//
//  AppViewController.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class AppViewController: UIViewController, AlertPresentable, MainCoordinatorDelegatee {

    private enum SettingsGroup: String {
        case aboutMe = "About Me"
        case appSettings = "App Settings"
        case ui = "User Interface"
        case privacy = "Terms & Privace"
        case services = "Service and More"
        case system = "System"
        
        var settings: [Setting] {
            switch self {
            case .aboutMe: return [.name, .phoneNumber, .email, .createdApp, .lastSignedInDate, .emailVerified, .loginMethods, .profilePhotoURL]
            case .appSettings: return [.gotoDeviceSettings, .updatePassword, .updateEmail, .logout]
            case .ui: return [.fontOfChoice]
            case .privacy: return [.appLocking, .contactsSynced, .showOnlineStatus, .slideToSpeak, .highQualityTranslation]
            case .services: return [.guide, .aboutDeveloper, .privacyPolicy, .eula, .contactsUs, .shareApp]
            case .system: return [.newworkStatus, .appUsage, .appVersion]
            }
        }
    }
    
    enum Setting: String {
        case name = "Name"
        case phoneNumber = "Phone Number"
        case email = "Email"
        case createdApp = "Created"
        case lastSignedInDate = "Last Sign-in"
        case emailVerified = "Email Verified"
        case loginMethods = "Login Methods"
        case profilePhotoURL = "Profile Photo URL"
        case gotoDeviceSettings = "Goto Device Settings"
        case updatePassword = "Update Password (Email)"
        case updateEmail = "Add/Update Email Address"
        case logout = "Logout"
        case appLocking = "Lock App"
        case contactsSynced = "Contacts Synced"
        case showOnlineStatus = "Show Active Status"
        case slideToSpeak = "Slide to Speak"
        case guide = "App Guide"
        case aboutDeveloper = "About Developer"
        case privacyPolicy = "Privacy Policy"
        case eula = "End-User Licensing Agreement"
        case contactsUs = "Contact Us / Feedback"
        case shareApp = "Share this App"
        case newworkStatus = "Network Type"
        case appUsage = "App Usage"
        case appVersion = "App Version"
        case fontOfChoice = "Font of Choice"
        case highQualityTranslation = "High Quality Translation"
        
        var description: String? {
            let user = GlobalVar.currentUser
            switch self {

            case .name: return user?.displayName
            case .phoneNumber: return user?.phoneNumber
            case .email: return user?.email
            case .createdApp: return user?.metadata.creationDate?.forChatMessage()
            case .loginMethods: return user?.providerData.map{ $0.providerID }.joined(separator: "/")
            case .profilePhotoURL: return user?.photoURL?.absoluteString
            case .lastSignedInDate: return user?.metadata.lastSignInDate?.forChatMessage()
            case .emailVerified: return user?.isEmailVerified.description
            case .newworkStatus: return "\(userDefaults.currentReachabilityStatus)"
            case .appUsage: return userDefaults.currentStringObjectState(for: userDefaults.runCountNamespace)
            case .appVersion: return userDefaults.currentStringObjectState(for: userDefaults.previousVersion)
            case .fontOfChoice: return userDefaults.currentBoolObjectState(for: userDefaults.isZawgyiInstalled) ? "ZawGyi" : "Unicode"
            default: return nil
            }
            
        }
        
        var isSelectable: Bool {
            switch self {
            case .name, .gotoDeviceSettings, .updatePassword, .updateEmail, .logout, .guide, .aboutDeveloper, .privacyPolicy, .eula, .contactsUs, .shareApp, .fontOfChoice :
                return true
            default:
                return false
            }
        }
        
        var image: UIImage? {
            switch self {
            case .name: return UIImage(systemName: "person.crop.circle.fill")
            case .phoneNumber: return UIImage(systemName: "teletype")
            case .email: return UIImage(systemName: "envelope.circle.fill")
            case .newworkStatus: return UIImage(systemName: "wifi.slash")
            case .appUsage: return UIImage(systemName: "cube.fill")
            case .appVersion: return UIImage(systemName: "app.gift.fill")
            case .gotoDeviceSettings:
                return UIImage(systemName: "lock.shield.fill")
            case .updatePassword:
                return UIImage(systemName: "signature")
            case .updateEmail:
                return UIImage(systemName: "at")
            case .logout:
                return UIImage(systemName: "power")
            case .guide:
                return UIImage(systemName: "hand.draw.fill")
            case .aboutDeveloper:
                return UIImage(systemName: "eyeglasses")
            case .privacyPolicy:
                return UIImage(systemName: "doc.text.magnifyingglass")
            case .eula:
                return UIImage(systemName: "rosette")
            case .contactsUs:
                return UIImage(systemName: "envelope.badge")
            case .shareApp:
                return UIImage(systemName: "square.and.arrow.up")
            default:
                return nil
            }
        }
        var switchObject: SwitchObject? {
            switch self {
            case .appLocking: return SwitchObject(state: userDefaults.currentBoolObjectState(for: userDefaults.biometricalAuth), defaultsKey: userDefaults.biometricalAuth)
            case .contactsSynced: return SwitchObject(state: userDefaults.currentBoolObjectState(for: userDefaults.hasContactSynced), defaultsKey: userDefaults.hasContactSynced)
            case .showOnlineStatus: return SwitchObject(state: userDefaults.currentBoolObjectState(for: userDefaults.showOnlineStatus), defaultsKey: userDefaults.showOnlineStatus)
            case .slideToSpeak: return SwitchObject(state: userDefaults.currentBoolObjectState(for: userDefaults.speakOutPannedMessages), defaultsKey: userDefaults.speakOutPannedMessages)
            case .highQualityTranslation: return SwitchObject(state: userDefaults.currentBoolObjectState(for: userDefaults.usesHighQualityTranslation), defaultsKey: userDefaults.usesHighQualityTranslation)
            default:
                return nil
            }
        }
    }
    
    private lazy var settingGroups: [SettingsGroup] = [.aboutMe, .appSettings, .ui, .privacy, .services, .system]
    
    lazy var tableView: UITableView = { [unowned self] in
        $0.bounces = true
        $0.estimatedRowHeight = 100
        $0.rowHeight = UITableView.automaticDimension
        $0.sectionHeaderHeight = 50
        $0.separatorColor = $0.backgroundColor
        $0.register(DefaultTableViewCell.self)
        $0.register(RightSubtitleTableViewCell.self)
        $0.register(SwitchTableViewCell.self)
        $0.dataSource = self
        $0.delegate = self
        $0.setBackgroundImage()
        return $0
        }(UITableView(frame: .zero, style: .insetGrouped))
    
    lazy var tableHeaderView: TableHeaderAvatarView = { [weak self] x in
        x.avatarImageView.badge = "+"
        x.avatarImageView.action { [weak x] _ in
            x?.avatarImageView.showMediaViewer()
        }
        x.avatarImageView.badgeAction { [weak x, weak self] _ in
            self?.requestUpdatePhoto()
        }
        return x
        }(TableHeaderAvatarView())
    
    var avatarImageView: BadgeAvatarImageView {
        return tableHeaderView.avatarImageView
    }
    
    override func loadView() {
        view = tableView
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
           
            var headerFrame = headerView.frame
            headerFrame.size.height = tableView.bounds.width
            if headerFrame != headerView.frame {
                headerView.frame = headerFrame
                
            }
        } else {
            let tableWidth = tableView.bounds.width
            tableHeaderView.frame = CGRect(origin: .zero, size: CGSize(width: .greatestFiniteMagnitude, height: tableWidth))
            tableView.tableHeaderView = self.tableHeaderView
            tableHeaderView.refreshImage(refresh: false)
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            tableView.setBackgroundImage()
        }
    }
}


extension AppViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingGroups[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = self.settingGroups[indexPath.section]
        let setting = group.settings[indexPath.row]
        
        switch group {
        case .aboutMe, .system, .ui:
            let cell: RightSubtitleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(setting)
            return cell
        case .privacy:
            let cell: SwitchTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(setting)
            return cell
        case .appSettings, .services:
            let cell: DefaultTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(setting)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.settingGroups[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let group = self.settingGroups[indexPath.section]
        let setting = group.settings[indexPath.row]
        return setting.isSelectable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isSafeToSelect(indexPath: indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let group = self.settingGroups[indexPath.section]
            let setting = group.settings[indexPath.row]
            self.select(setting, indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if self.tableView(tableView, shouldHighlightRowAt: indexPath) {
            let group = self.settingGroups[indexPath.section]
            let setting = group.settings[indexPath.row]
            self.select(setting, indexPath: indexPath)
        }
    }
}


extension AppViewController {
    
    private func select(_ setting: Setting, indexPath: IndexPath) {
        switch setting {
        case .name:
            gotoChangeName()
        case .gotoDeviceSettings:
            gotoAppSettings()
        case .updatePassword:
            checkIfEmailRegistered()
        case .updateEmail:
            updateEmail()
        case .logout:
            gotoLogout()
        case .guide:
            gotoGuide()
        case .aboutDeveloper:
            aboutDeveloper()
        case .privacyPolicy:
            gotoPrivacy()
        case .eula:
            gotoEULA()
        case .contactsUs:
            gotoContactUs()
        case .shareApp:
            gotoShareApp()
        case .fontOfChoice:
            resetWords(at: indexPath)
        default:
            break
        }
    }
}
