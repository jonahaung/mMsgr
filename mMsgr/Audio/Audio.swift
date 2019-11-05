//
//  Audio.swift
//  mMsgr
//
//  Created by Aung Ko Min on 16/8/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class Audio {
    let delegate: IQAudioRecorderViewControllerDelegate

    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }

    func presentAudioRecorder(target: UIViewController) {

        let controller = IQAudioRecorderViewController()

        controller.delegate = delegate
        controller.title = "Recorder"
        controller.maximumRecordDuration = GlobalVar.kAUDIO_MAX_DURATION
        controller.allowCropping = true

        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
