//
//  InputBar.swift
//  mMsgr
//
//  Created by jonahaung on 7/6/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import Photos

protocol InputBarDelegate: class {
    
    func inputBar(_ inputBar: InputBar, performAction action: InputBar.InputBarAction)
    func inputBar_willSendText()
    
}

final class InputBar: UIView {
    
    enum InputBarAction {
        case KeyboardIsTyping, KeyboardEndsTyping, TextViewBecomesActive, TextViewResignActive, TurnOffTranslateSwitch, TapScrollBottomButton, TapPhotoButton, TapVideosButton, TapPhotoCamera, TapVideoCamera, TapFace, TapMicrophone
    }
    
    weak var inputBarDelegate: InputBarDelegate?
    
    lazy var emojiManager: EmojiManager = { [weak self] in
        $0.delegate = self
        return $0
        }(EmojiManager())
    
    lazy var inputBarManager = InputBarManager(_textView: textView)
    var oldHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleHeight]
        badgeStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        blurView.addSubview(mainStackView)
        addSubview(badgeStackView)
        addSubview(blurView)
        
        
        let padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        NSLayoutConstraint.activate([
            badgeStackView.topAnchor.constraint(equalTo: topAnchor),
            badgeStackView.leftAnchor.constraint(equalTo: leftAnchor),
            badgeStackView.rightAnchor.constraint(equalTo: rightAnchor),
            
            blurView.topAnchor.constraint(equalTo: badgeStackView.bottomAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: blurView.topAnchor, constant: padding.top),
            mainStackView.leftAnchor.constraint(equalTo: blurView.safeAreaLayoutGuide.leftAnchor, constant: padding.left),
            mainStackView.rightAnchor.constraint(equalTo: blurView.safeAreaLayoutGuide.rightAnchor, constant: -padding.right),
            mainStackView.bottomAnchor.constraint(equalTo: blurView.safeAreaLayoutGuide.bottomAnchor, constant: -padding.bottom),
        ])

        setupButtonActions()
        inputBarManager.delegate = self
        
        tintColor = GlobalVar.theme.mainColor
    }
    
    
    var minHeight = CGFloat(50)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: max(minHeight, super.intrinsicContentSize.height))
    }
    
    
    func superViewDidAppear() {
        minHeight = bounds.height
    }
    
    let badgeStackView = BadgeStackView()
    
    let textView = InputBarTextView()
    private let sendButton = SendButton(image: UIImage(systemName: "arrow.up.circle.fill"))
    private let menuButton = RoundedButton(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 27, weight: .semibold)))
    private let cameraButton = RoundedButton(image: UIImage(systemName: "camera.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)))
    private let gifButton = RoundedButton(image: UIImage(systemName: "heart.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)))
    
    private lazy var mainStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alignment = .fill
        $0.axis = .vertical
        $0.distribution = .fill
        return $0
    }(UIStackView(arrangedSubviews: [bottomStackView]))
    
    lazy var leftButtonsBar: UIStackView = {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        return $0
    }(UIStackView(arrangedSubviews: [cameraButton, gifButton]))
    
    private lazy var bottomStackView: UIStackView = {
        $0.alignment = .bottom
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = UIStackView.spacingUseSystem
        return $0
    }(UIStackView(arrangedSubviews: [menuButton, leftButtonsBar, textView, sendButton]))
    
    let blurView: UIView = {
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = UIColor.tertiarySystemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    // Deinit
    deinit {
        print("Input Bar Deinit")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension InputBar: InputBarManagerDelegate {
    
    func inputBarManager(didAutocomplete text: String) {
        let room = GlobalVar.currentRoom
        MessageSender.shared.SendTextMessage(for: room?.objectID, text: text, canTranslate: room?.canTranslate == true)
        textView.text = String()
    }
    
    
    func inputBarManager(textViewDidChangeHeight textView: UITextView, height: CGFloat) {
        textView.invalidateIntrinsicContentSize()
        forceLayout()
    }
    
    func inputBarManager(autocompleteManager manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        let tableView = manager.tableView
        if shouldBecomeVisible && !mainStackView.arrangedSubviews.contains(tableView) {
            inputBarDelegate?.inputBar(self, performAction: .TurnOffTranslateSwitch)
            mainStackView.insertArrangedSubview(tableView, at: 1)
        } else if !shouldBecomeVisible && mainStackView.arrangedSubviews.contains(tableView) {
            mainStackView.removeArrangedSubview(tableView)
            tableView.removeFromSuperview()
            if textView.hasText && !textView.text.isWhitespace {
                sendButton.actionOnTouchUpInside()
            }
        }
        sendButton.isEnabled = true
    }
    
    
    func inputBarManager(textViewIsWriting isWritingText: Bool) {
        let isWrithing = isWritingText && textView.hasText
        sendButton.isEnabled = isWrithing
        inputBarDelegate?.inputBar(self, performAction: isWrithing ? .KeyboardIsTyping: .KeyboardEndsTyping)
    }
    
    func inputBarManager(textViewDidToggle isActive: Bool) {
        leftButtonsBar.isHidden = isActive
        inputBarDelegate?.inputBar(self, performAction: isActive ? .TextViewBecomesActive: .TextViewResignActive)
    }
    
    func inputBarManager(didGetClassifiedText text: String?) {
        badgeStackView.label.text = text
    }
    func inputBarManager(didGetSuggestedText text: String?) {
        //        badgeStackView.label.text = text
    }
    func inputBarManager(didChangeInputLanguage language: String?) {
        badgeStackView.label.text = language
    }
    
}


extension InputBar: EmojiManagerDelegate {
    
    func emojiManagerr(emojiManagerDidCancel manager: EmojiManager) {
        toggleEmojiView(show: false)
    }
    
    func emojiManagerr(manager: EmojiManager, didSelect emojiURL: URL, emojiSize: CGSize) {
        toggleEmojiView(show: false)
        let emoji = emojiURL.lastPathComponent
        Async.background {
            MessageSender.shared.sendGifMessage(roomID: GlobalVar.currentRoom?.objectID, fileNameWithType: emoji, imageSize: emojiSize)
        }
    }
    
    private func toggleEmojiView(show: Bool) {
        
        vibrate(vibration: .light)
        
        let emojiView = emojiManager.collectionView
        if show && !mainStackView.arrangedSubviews.contains(emojiView){
            self.mainStackView.addArrangedSubview(emojiView)
            gifButton.isHighlighted = true
        } else if !show && mainStackView.arrangedSubviews.contains(emojiView){
            mainStackView.removeArrangedSubview(emojiView)
            emojiView.removeFromSuperview()
            gifButton.isHighlighted = false
        }
        
        UIView.animate(withDuration: 0.2) {
            self.forceLayout()
        
        }
    }
    
    private func forceLayout() {
        blurView.layoutIfNeeded()
        if oldHeight != blurView.bounds.height {
            print(oldHeight, blurView.bounds.height)
            inputBarDelegate?.inputBar(self, performAction: .TextViewBecomesActive)
        }
        oldHeight = blurView.bounds.height
//        invalidateIntrinsicContentSize()
//        setNeedsLayout()
//        layoutIfNeeded()
        
    }
    
}

extension InputBar {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if badgeStackView.frame.contains(point) {
            return badgeStackView.point(inside: badgeStackView.convert(point, to: self), with: event)
        }

        return super.point(inside: point, with: event)
    }
    
    
    fileprivate func showCameraButtons() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Media Sources", font: UIFont.preferredFont(forTextStyle: .body ))
        alert.addAction(image: UIImage.systemImage(name: "camera.on.rectangle.fill", pointSize: 24, symbolWeight: .bold), title: "Photo Camera", color: nil, style: .default, isEnabled: true) { _ in
            self.inputBarDelegate?.inputBar(self, performAction: .TapPhotoCamera)
        }
        alert.addAction(image: UIImage.systemImage(name: "photo.fill.on.rectangle.fill", pointSize: 24, symbolWeight: .bold), title: "Photo Library", color: nil, style: .default, isEnabled: true) { _ in
            self.inputBarDelegate?.inputBar(self, performAction: .TapPhotoButton)
        }
        alert.addAction(image: UIImage.systemImage(name: "video.badge.plus.fill", pointSize: 24, symbolWeight: .bold), title: "Video Camera", color: nil, style: .default, isEnabled: true) { _ in
            self.inputBarDelegate?.inputBar(self, performAction: .TapVideoCamera)
        }
        
        alert.addAction(image: UIImage.systemImage(name: "tv.music.note.fill", pointSize: 24, symbolWeight: .bold), title: "Video Library", color: nil, style: .default, isEnabled: true) { _ in
            self.inputBarDelegate?.inputBar(self, performAction: .TapVideosButton)
        }
        
        alert.addCancelAction()
        alert.show()
    }
    fileprivate func showMenu() {
        textView.resignFirstResponder()
        let alert = UIAlertController(style: .actionSheet)
        alert.addTelegramPicker { [weak self] selected in
            guard let `self` = self else { return }
            switch selected {
            case .location(let x):
                if let location = x {
                    MessageSender.shared.sendLocationMessage(roomID: GlobalVar.currentRoom?.objectID, lat: location.coordinate.latitude, long: location.coordinate.longitude, place: location.address)
                }
            case .photos(let x):
                let assets = x as [PHAsset]
                _ =  Assets.resolve(assets: assets, completion: { images in
                    images.forEach {
                        MessageSender.shared.sendPhotoMessage(roomID: GlobalVar.currentRoom?.objectID, image: $0)
                    }
                })
            case .openSmileController(_):
                self.inputBarDelegate?.inputBar(self, performAction: .TapFace)
            case .openAudio(_):
                self.inputBarDelegate?.inputBar(self, performAction: .TapMicrophone)
            }
        }
        
        alert.addCancelAction()
        
        alert.show()
    }
    
    private func setupButtonActions() {
        
        badgeStackView.action { [weak self] (badgeType) in
            guard let `self` = self else { return }
            switch badgeType {
            case .ScrollToBottom:
                self.inputBarDelegate?.inputBar(self, performAction: .TapScrollBottomButton)

            default:
                break
            }
        }
        
        sendButton.action({ [weak self] _ in
            guard let `self` = self else { return }
            if let text = self.textView.text {
                self.inputBarDelegate?.inputBar_willSendText()
                Async.background {
                    let room = GlobalVar.currentRoom
                    MessageSender.shared.SendTextMessage(for: room?.objectID, text: text, canTranslate: room?.canTranslate == true)
                }.main {
                    self.textView.text = String()
                }
            }
        })
        
        
        cameraButton.action({[weak self] btn in
            self?.showCameraButtons()
        })
        
        menuButton.action { [weak self] _ in
            self?.showMenu()
        }
        
        gifButton.action { [weak self] _ in
            guard let `self` = self else { return }
            self.toggleEmojiView(show: self.mainStackView.arrangedSubviews.contains(self.emojiManager.collectionView) == false)
        }
    }
}


final class SendButton: UIButton {
    typealias Action = (SendButton) -> Swift.Void
    private var actionOnTouch: Action?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(image: UIImage?) {
        self.init(type: .custom)
        setup()
        setImage(image, for: .normal)
        setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .disabled)
        setImage(UIImage(systemName: "circle.fill"), for: .highlighted)
    }
    
    func setup() {
        isUserInteractionEnabled = true
        isOpaque = true
        backgroundColor = nil
        showsTouchWhenHighlighted = false
        reversesTitleShadowWhenHighlighted = true
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 27, weight: .black, scale: .large), forImageIn: .normal)
        isEnabled = false
    }
    
    override var isEnabled: Bool {
        didSet {
            guard oldValue != self.isEnabled else { return }
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 5, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
                self.transform = self.isEnabled ? .identity : CGAffineTransform(rotationAngle: -0.25.radians.float)
            })
            
        }
    }
    
    
    func action(_ closure: @escaping Action) {
        if actionOnTouch == nil {
            addTarget(self, action: #selector(SendButton.actionOnTouchUpInside), for: .touchUpInside)
        }
        self.actionOnTouch = closure
    }
    
    @objc internal func actionOnTouchUpInside() {
        vibrate(vibration: .light)
        self.actionOnTouch?(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
