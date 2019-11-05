//
//  NSURL+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit
import AVKit

extension URL {
    
    func getVideoThumbnail() -> UIImage? {
        let asset = AVURLAsset(url: self, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000)
        var actualTime = CMTime.zero
        var image: CGImage?
        
        do {
            image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        guard let cgimage = image else {
            return nil
        }

        guard let thumbImage = UIImage(cgImage: cgimage).photoMessageThumbnil(to: 230) else { return nil}
        let imageSize = thumbImage.size
        
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let drawedImage = renderer.image { ctx in
            thumbImage.draw(at: .zero)
            let playImage = #imageLiteral(resourceName: "Video Message")
            playImage.draw(in: playImage.size.bma_rect(inContainer: CGRect(origin: .zero, size: imageSize), xAlignament: .center, yAlignment: .center))
        }
        
        return drawedImage
    }
}
