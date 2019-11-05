//
//  AudioCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 20/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCell: MessageCell {
    
    private let playerView = PlayerCellView()
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            playerView.frame = bubbleFrame
        }
    }
    override func setup() {
        super.setup()

        menuImageView.image = MessageCell.menuImageAudioCell
        menuImageView.sizeToFit()
        contentView.addSubview(playerView)
        playerView.addInteraction(contextMenuInterAction)
    }

    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
            guard let url = msg.mediaURL else { return }
            if url.idExistedInDocuments {
                playerView.url = url
            } else {
                guard !self.isSender else { return }
                 let storageReference = msg.firebaseStorageRef()
                _ = storageReference?.write(toFile: url) { [weak self] url, error in
                    guard let `self` = self else { return }
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        storageReference?.delete(completion: nil)
                        DispatchQueue.main.async {
                            self.playerView.url = url
                        }
                    }
                }
            }
    }

}


class PlayerCellView: UIView {
    
    private(set) var autioPlayer: AVAudioPlayer?
    
    var url: URL? {
        didSet {
            guard let url = self.url else { return }
            let duration = self.duration(for: url)
            self.startingTime = duration
            resetTimer()
            do {
                autioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                Log(error)
            }
        }
    }

    
    @objc private func togglePlay(_ sender: UIButton?) {
        if playButton.isSelected {
            resetTimer()
        } else {
            runTimer()
        }
    }
    
    func duration(for url: URL) -> Double {
        let asset = AVURLAsset(url: url)
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
    
    
    private var startingTime = Double()
    
    private var seconds = Double() {
        didSet {
            self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds))
        }
    }
    
    private var timer:Timer? = Timer()
    
    private let playButton: UIButton = {
        $0.setPreferredSymbolConfiguration(.init(pointSize: 60, weight: .semibold), forImageIn: .normal)
        $0.setPreferredSymbolConfiguration(.init(pointSize: 60, weight: .semibold), forImageIn: .selected)
        $0.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        $0.setImage(UIImage(systemName: "pause.circle.fill"), for: .selected)
        return $0
    }(UIButton())
    
    private let timeLabel: UILabel = {
        $0.textColor = GlobalVar.theme.mainColor
        $0.text = "00:00"
        $0.textAlignment = .center
        $0.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .medium)
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        addSubview(playButton)
        addSubview(timeLabel)
        
        playButton.centerInSuperview()
        timeLabel.addConstraints(playButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        playButton.addTarget(self, action: #selector(togglePlay(_:)), for: .touchUpInside)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runTimer() {
        autioPlayer?.play()
        playButton.isSelected = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            resetTimer()
        } else {
            seconds -= 1
            timeLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    func resetTimer() {
        autioPlayer?.stop()
        playButton.isSelected = false
        timer?.invalidate()
        seconds = startingTime
        timeLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        autioPlayer?.stop()
        autioPlayer = nil
    }
    
    
}
