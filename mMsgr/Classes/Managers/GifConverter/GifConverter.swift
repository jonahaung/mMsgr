//
//  Regift.swift
//  Regift
//
//  Created by Matthew Palmer on 27/12/2014.
//  Copyright (c) 2014 Matthew Palmer. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation

public typealias TimePoint = CMTime
public typealias ProgressHandler = (Double) -> Void

public enum RegiftError: String, Error {
    case DestinationNotFound = "The temp file destination could not be created or found"
    case SourceFormatInvalid = "The source file does not appear to be a valid format"
    case AddFrameToDestination = "An error occurred when adding a frame to the destination"
    case DestinationFinalize = "An error occurred when finalizing the destination"
}


private struct MyDispatchGroup {
    let group = DispatchGroup()
    func enter() { group.enter() }
    func leave() { group.leave() }
    func wait() { let _ = group.wait(timeout: DispatchTime.distantFuture) }
}

/// Easily convert a video to a GIF. It can convert the whole thing, or you can choose a section to trim out.
///
/// Synchronous Usage:
///
///      let regift = Regift(sourceFileURL: movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7)
///      print(regift.createGif())
///
///      // OR
///
///      let trimmedRegift = Regift(sourceFileURL: movieFileURL, startTime: 30, duration: 15, frameRate: 15)
///      print(trimmedRegift.createGif())
///
/// Asynchronous Usage:
///
///      let regift = Regift.createGIFFromSource(movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7) { (result) in
///          print(result)
///      }
///
///      // OR
///
///      let trimmedRegift = Regift.createGIFFromSource(movieFileURL, startTime: 30, duration: 15, frameRate: 15, loopCount: 0) { (result) in
///          print(result)
///      }
///
public struct GifConverter {

    public static func createGIFFromSource(
        _ sourceFileURL: URL,
        destinationFileURL: URL? = nil,
        frameCount: Int,
        delayTime: Float,
        loopCount: Int = 0,
        size: CGSize? = nil,
        progress: ProgressHandler? = nil,
        completion: (_ result: URL?) -> Void) {
            let gift = GifConverter(
                sourceFileURL: sourceFileURL,
                destinationFileURL: destinationFileURL,
                frameCount: frameCount,
                delayTime: delayTime,
                loopCount: loopCount,
                size: size,
                progress: progress
            )

            completion(gift.createGif())
    }


    public static func createGIFFromSource(
        _ sourceFileURL: URL,
        destinationFileURL: URL? = nil,
        startTime: Float,
        duration: Float,
        frameRate: Int,
        loopCount: Int = 0,
        size: CGSize? = nil,
        progress: ProgressHandler? = nil,
        completion: (_ result: URL?) -> Void) {
            let gift = GifConverter(
                sourceFileURL: sourceFileURL,
                destinationFileURL: destinationFileURL,
                startTime: startTime,
                duration: duration,
                frameRate: frameRate,
                loopCount: loopCount,
                size: size,
                progress: progress
            )

            completion(gift.createGif())
    }
    
    public static func createGIF(
        fromAsset asset: AVAsset,
        destinationFileURL: URL? = nil,
        startTime: Float,
        duration: Float,
        frameRate: Int,
        loopCount: Int = 0,
        completion: (_ result: URL?) -> Void) {

        let gift = GifConverter(
            asset: asset,
            destinationFileURL: destinationFileURL,
            startTime: startTime,
            duration: duration,
            frameRate: frameRate,
            loopCount: loopCount
        )
        
        completion(gift.createGif())
    }

    private struct Constants {
        static let FileName = "regift.gif"
        static let TimeInterval: Int32 = 600
        static let Tolerance = 0.01
    }


    private var asset: AVAsset
    private var sourceFileURL: URL?
    private var startTime: Float = 0
    private var duration: Float
    private var movieLength: Float
    private let frameCount: Int
    private let delayTime: Float
    private let loopCount: Int
    private var destinationFileURL: URL?
    private var progress: ProgressHandler?
    fileprivate let size: CGSize?
    
    public init(sourceFileURL: URL, destinationFileURL: URL? = nil, frameCount: Int, delayTime: Float, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.sourceFileURL = sourceFileURL
        self.asset = AVURLAsset(url: sourceFileURL, options: nil)
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.duration = movieLength
        self.delayTime = delayTime
        self.loopCount = loopCount
        self.destinationFileURL = destinationFileURL
        self.frameCount = frameCount
        self.size = size
        self.progress = progress
    }

    public init(sourceFileURL: URL, destinationFileURL: URL? = nil, startTime: Float, duration: Float, frameRate: Int, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.sourceFileURL = sourceFileURL
        self.asset = AVURLAsset(url: sourceFileURL, options: nil)
        self.destinationFileURL = destinationFileURL
        self.startTime = startTime
        self.duration = duration

        self.delayTime = (1.0 / Float(frameRate))
        self.frameCount = Int(duration * Float(frameRate))
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.loopCount = loopCount
        self.size = size
        self.progress = progress
    }
    
    public init(asset: AVAsset, destinationFileURL: URL? = nil, startTime: Float, duration: Float, frameRate: Int, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.asset = asset
        self.destinationFileURL = destinationFileURL
        self.startTime = startTime
        self.duration = duration
        self.delayTime = (1.0 / Float(frameRate))
        self.frameCount = Int(duration * Float(frameRate))
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.loopCount = loopCount
        self.size = size
        self.progress = progress
    }

    public func createGif() -> URL? {

        let fileProperties = [kCGImagePropertyGIFDictionary as String:[
            kCGImagePropertyGIFLoopCount as String: NSNumber(value: Int32(loopCount) as Int32)],
            kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
        ] as [String : Any]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String:[
                kCGImagePropertyGIFDelayTime as String:delayTime
            ]
        ]

        let increment = Float(duration) / Float(frameCount)
        
        var timePoints: [TimePoint] = []
        
        for frameNumber in 0 ..< frameCount {
            let seconds: Float64 = Float64(startTime) + (Float64(increment) * Float64(frameNumber))
            let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: Constants.TimeInterval)
            
            timePoints.append(time)
        }
        
        do {
            return try createGIFForTimePoints(timePoints, fileProperties: fileProperties as [String : AnyObject], frameProperties: frameProperties as [String : AnyObject], frameCount: frameCount, size: size)
            
        } catch {
            return nil
        }
    }

    public func createGIFForTimePoints(_ timePoints: [TimePoint], fileProperties: [String: AnyObject], frameProperties: [String: AnyObject], frameCount: Int, size: CGSize? = nil) throws -> URL {
        // Ensure the source media is a valid file.
        guard asset.tracks(withMediaCharacteristic: .visual).count > 0 else {
            throw RegiftError.SourceFormatInvalid
        }

        var fileURL:URL?
        if self.destinationFileURL != nil {
            fileURL = self.destinationFileURL
        } else {
            let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent(Constants.FileName)
            fileURL = URL(fileURLWithPath: temporaryFile)
        }
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL! as CFURL, kUTTypeGIF, frameCount, nil) else {
            throw RegiftError.DestinationNotFound
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        if let size = size {
            generator.maximumSize = size
        }
        
        let tolerance = CMTimeMakeWithSeconds(Constants.Tolerance, preferredTimescale: Constants.TimeInterval)
        generator.requestedTimeToleranceBefore = tolerance
        generator.requestedTimeToleranceAfter = tolerance

        // Transform timePoints to times for the async asset generator method.
        var times = [NSValue]()
        for time in timePoints {
            times.append(NSValue(time: time))
        }

        // Create a dispatch group to force synchronous behavior on an asynchronous method.
        let gifGroup = MyDispatchGroup()
        gifGroup.enter()

        var handledTimes: Double = 0
        generator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { (requestedTime, image, actualTime, result, error) in
            handledTimes += 1
            guard let imageRef = image , error == nil else {
                print("An error occurred: \(String(describing: error)), image is \(String(describing: image))")
                if requestedTime == times.last?.timeValue {
                    gifGroup.leave()
                }
                return
            }

            CGImageDestinationAddImage(destination, imageRef, frameProperties as CFDictionary)
            self.progress?(min(1.0, handledTimes/max(1.0, Double(times.count))))
            if requestedTime == times.last?.timeValue {
                gifGroup.leave()
            }
        })

        // Wait for the asynchronous generator to finish.
        gifGroup.wait()
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        // Finalize the gif
        if !CGImageDestinationFinalize(destination) {
            throw RegiftError.DestinationFinalize
        }
        
        return fileURL!
    }
}
