//
//  MessageCollectionViewCell.swift
//  mMsgr
//
//  Created by jonahaung on 24/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//
import UIKit


private extension Message {
    
    var hideHasReadView: Bool {
        return isSender ? !hasRead : hasRead
    }
}

class MessageCell: CollectionViewCell {
    
    static let menuImageTextCell = UIImage(systemName: "message.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .thin))?.withTintColor(UIColor.opaqueSeparator, renderingMode: .alwaysOriginal)
    static let menuImagePhotoVideoCell = UIImage(systemName: "rectangle.on.rectangle.angled", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .thin))
    static let menuImageAudioCell = UIImage(systemName: "waveform.path.ecg", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .thin))
    static let menuImageRichLinkCell = UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .light))
    
    internal let menuImageView: UIImageView = {
        $0.isUserInteractionEnabled = false
        $0.isOpaque = true
        $0.backgroundColor = nil
        return $0
    }(UIImageView())
    
    internal let hasReadImageView: UIImageView = {
        $0.isUserInteractionEnabled = false
        $0.isOpaque = true
        $0.backgroundColor = nil
        $0.image = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .thin))?.withTintColor(UIColor.opaqueSeparator, renderingMode: .alwaysOriginal)
        $0.sizeToFit()
        return $0
    }(UIImageView())
    
    weak var msg: Message?
    var isSender: Bool { return msg?.isSender == true }
    lazy var contextMenuInterAction = UIContextMenuInteraction(delegate: self)
    weak var timeLabel: UILabel?
    
    var bubbleFrame = CGRect.zero
    var layout: ChatLayoutBlock? {
        didSet {
            guard oldValue != layout, let layout = self.layout else { return }
            menuImageView.frame.origin = layout.statusImageViewFrame.origin
            hasReadImageView.frame.origin = layout.hasReadImageViewFrame.origin
            
            bubbleFrame = layout.bubbleFrame
            drawBubble(layout.bubbleType)
        }
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        guard let attributes = layoutAttributes as? MsgCellLayoutAttributes else { return }
        super.apply(layoutAttributes)
        attributes.createBlock {[weak self] (layout) in
            guard let `self` = self else { return }
            self.layout = layout
        }
    }
    
    override func setup() {
        super.setup()
        backgroundView = UIView()
        addSubview(menuImageView)
        addSubview(hasReadImageView)
    }
    
    override func reload() {
        if let msg = self.msg {
            hasReadImageView.isHidden = msg.hideHasReadView
        }
    }
    
    func willDisplayCell() {}
    func didEndDisplayingCell() {}
    func appearingOnScreen() {}
    func drawBubble(_ bubbleType: BubbleType) {}
    func configure(_ msg: Message) {
        self.msg = msg
        hasReadImageView.isHidden = msg.hideHasReadView
    }

    func releaseObjects() {
        removeTimeLabel()
    }
    
    deinit {
        releaseObjects()
    }

}


// AccessoryView Revealer

extension MessageCell {
    
    func revealAccessoryView(withOffset offset: CGFloat, canSpeak: Bool, animated: Bool) {
        guard let timeLabel = timeLabel else { return }
        
        if timeLabel.superview == nil {
            if offset > 2 {
                self.insertSubview(timeLabel, at: 0)
            }
        } else {
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                    self.layoutTimeLabelIfNeeded(offsetToRevealAccessoryView: offset)
                }) { _ in
                    if offset == 0 {
                        self.removeTimeLabel()
                        if canSpeak, let cell = self as? TextCell {
                            cell.textView.text.speak()
                        }
                    }
                }
            } else {
                self.layoutTimeLabelIfNeeded(offsetToRevealAccessoryView: offset)
                
            }
        }
    }
    
    private func layoutTimeLabelIfNeeded(offsetToRevealAccessoryView: CGFloat) {
        
        if let timeLabel = self.timeLabel, timeLabel.superview != nil {
            timeLabel.sizeToFit()
            let timeLabelSize = timeLabel.bounds.size
            
            timeLabel.bounds = CGRect(origin: .zero, size: timeLabelSize)
            let timeLabelWidth = timeLabel.bounds.width + 20
            let leftOffsetForContentView = max(0, offsetToRevealAccessoryView)
            let leftOffsetForAccessoryView = min(leftOffsetForContentView, timeLabelWidth)
            var contentViewframe = contentView.frame
            
            let leftRight = self.isSender == true ? -leftOffsetForContentView : leftOffsetForContentView
            contentViewframe.origin.x = leftRight
            
            contentView.frame = contentViewframe
            let labelX = self.isSender == true ? self.bounds.width - (leftOffsetForAccessoryView/2) : leftOffsetForAccessoryView/2
            timeLabel.center = CGPoint(x: labelX, y: contentViewframe.midY)
        }
    }
    
    private func removeTimeLabel() {
        timeLabel?.removeFromSuperview()
        timeLabel = nil
    }
}

import MessageUI
import MapKit

extension MessageCell: UIContextMenuInteractionDelegate, MainCoordinatorDelegatee {

    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[unowned self] (elements) -> UIMenu? in
            return self.getMessageContextMenu()
        }
    }
    
    func getMessageContextMenu() -> UIMenu? {
           
            guard let msg = self.msg else { return nil }
            
            let more = moreMenu(for: self, msg: msg)

            let report = UIAction(title: "Report", image: UIImage(systemName: "info")) { action in
                if !msg.isSender {
                    if MFMailComposeViewController.canSendMail(), let user = GlobalVar.currentUser {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self.chatViewController
                        mail.setSubject("mMsgr: Report Contact")
                        mail.setToRecipients(["mmsgrapp@gmail.com"])
                        mail.setMessageBody("<p> mMsgr User ID : \(user.uid), mMsgr Reported User ID : \(msg.sender?.uid ?? ""), Reporting Message Text : \(msg.text)</p>", isHTML: true)
                        
                        self.maincoordinator?.presentViewController(mail)
                    }
                } else {
                    let dispalyName = GlobalVar.currentUser?.displayName?.firstWord ?? "Human"
                    dropDownMessageBar.show(text: "\(dispalyName), you cannot report your own message!", duration: 0.4)
                }
            }
           
            let delete = UIAction(title: "Delete", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .on) { action in
                let alert = UIAlertController(style: .actionSheet)
                alert.set(title: "Warning!", font: UIFont.preferredFont(forTextStyle: .title3))
                alert.set(message: "This message will be permanently deleted. Continue?", font: UIFont.preferredFont(forTextStyle: .body))
                
                alert.addAction(image: nil, title: "Continue", color: nil, style: .destructive, isEnabled: true, handler: { [weak msg] _ in
                    msg?.delete()
                })
                alert.addCancelAction()
                alert.show()
            }
            
            return UIMenu(title: msg.date.dateTimeString(), image: nil, identifier: nil, options: [], children: [more, report, delete])
        }
        
        private func moreMenu(for cell: MessageCell, msg: Message) -> UIMenu {
            
            var actions = [UIAction]()
            
            switch msg.messageType {
            case .Text:
                actions.append(copyTextAction(for: msg))
                
                if msg.text2 != nil {
                    let action = UIAction(title: "Translations", image: UIImage(systemName: "repeat")) { action in
                        self.showTranslatedTextAlert(msg: msg)
                    }
                    actions.append(action)
                }
            case .Photo:
                let action = UIAction(title: "Save To Device", image: UIImage(systemName: "tray.and.arrow.down")) { action in
                    if let url = msg.mediaURL, let image = UIImage(contentsOfFile: url.path) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        SoundManager.playSound(tone: .Tock)
                    }
                }
                actions.append(action)
            case .Location:
                let action = UIAction(title: "Show on Map", image: UIImage(systemName: "map")) { action in
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(msg.text) {
                        (placemarks, error) in
                        guard error == nil else {
                            print("Geocoding error: \(error!)")
                            return
                        }
                        if let coordinate = placemarks?.first?.location?.coordinate {
                            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                            mapItem.name = msg.sender?.displayName
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        }
                    }
                }
                actions.append(action)
                actions.append(copyTextAction(for: msg))
            default:
                break
            }
            
            actions.append(snapshotAction(msg: msg, cell: cell))
            
            return UIMenu(title: "More", image: UIImage(systemName: "chevron.down"), identifier: nil, options: [], children: actions)
        }
        
        private func copyTextAction(for msg: Message) -> UIAction {
            
            return UIAction(title: "Copy Text", image: UIImage(systemName: "doc.on.doc")) { [unowned msg] action in
                UIPasteboard.general.string = msg.text
                dropDownMessageBar.show(text: "Copied", duration: 2)
            }
        }
        
        // Snapshot
        private func snapshotAction(msg: Message, cell: MessageCell) -> UIAction {
            
            return UIAction(title: "Snapshot", image: UIImage(systemName: "photo")) {[unowned cell] action in
                let alert = UIAlertController(style: .actionSheet)
                
                alert.set(title: "Snapshot", font: UIFont.preferredFont(forTextStyle: .title3))
                
                let image = cell.asImage().withRenderingMode(.alwaysOriginal)
                
                let snapshotAction = UIAlertAction(title: "", style: .default, handler: nil)
                snapshotAction.setValue(image, forKey: "image")
                snapshotAction.isEnabled = false
                alert.addAction(snapshotAction)
                
                alert.addAction(image: nil, title: "Send As Photo Message", color: nil, style: .default, isEnabled: true) { _ in
                    MessageSender.shared.sendPhotoMessage(roomID: GlobalVar.currentRoom?.objectID, image: image)
                }
                alert.addAction(image: nil, title: "Save To Photos", color: nil, style: .default, isEnabled: true) { _ in
                    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                }
                alert.addAction(image: nil, title: "Share", color: nil, style: .default, isEnabled: true) { _ in
                    image.shareWithMenu()
                }
                alert.addCancelAction()
                alert.show()
            }
            
        }
        
        // Copy Original Text
        private func copyOriginalTextAction(msg: Message) -> UIAlertAction {
            return UIAlertAction(title: "Copy This Text", style: .default) { [unowned msg] _ in
                vibrate(vibration: .medium)
                UIPasteboard.general.string = msg.text2
                dropDownMessageBar.show(text: "Copied", duration: 2)
            }
            
        }
        
        // Translated Text
        private func showTranslatePropertiesActions(msg: Message) -> UIAlertAction {
            return UIAlertAction(title: "Translate Properties", style: .default) { [unowned msg] _ in
                self.showTranslatedTextAlert(msg: msg)
            }
        }
        
        private func showTranslatedTextAlert(msg: Message) {
            let language = msg.text.language
            guard let text2 = msg.text2, let language2 = msg.text2?.language else { return }
            
            let alert = UIAlertController(style: .actionSheet)
            alert.set(title: "Language - \(language2) to \(String(describing: language))", font: UIFont.preferredFont(forTextStyle: .title3))
            alert.set(message: "This is the original text from the message", font: UIFont.preferredFont(forTextStyle: .callout))
            
            alert.addTextViewer(text: .text(text2))
            alert.addAction(self.copyOriginalTextAction(msg: msg))
            alert.addCancelAction()
            alert.show()
        }
    
    
}
