//
//  UIImage+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 17/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit

import Accelerate

extension UIImage {
    
    static func systemImage(name: String, pointSize: CGFloat, symbolWeight: UIImage.SymbolWeight) -> UIImage? {

        let homeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: symbolWeight)
        let image = UIImage(systemName: name, withConfiguration: homeSymbolConfiguration) ?? UIImage()
        return image
    }
    
    var png: Data? {
        guard let flattened = flattened else { return nil }
        if let x = flattened.pngData() {
            return x
        }
        return nil
    }
    
    var flattened: UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    

    var EXT_circleMasked: UIImage? {
        var isPortrait: Bool { return size.height > size.width }
        var isLandscape: Bool { return size.width > size.height }
        var breadth: CGFloat { return min(size.width, size.height) }
        var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
        var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }

        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }

        UIBezierPath(roundedRect: breadthRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: size.height * 0.6, height: size.height * 0.6)).addClip()
        UIImage(cgImage: cgImage, scale: UIMainScreenScale, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    var EXT_RoundCornor: UIImage? {
        let react = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage else { return nil }
        UIBezierPath(roundedRect: react, byRoundingCorners: .allCorners, cornerRadii: CGSize(10)).addClip()
        UIImage(cgImage: cgImage, scale: UIMainScreenScale, orientation: imageOrientation).draw(in: react)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    func rounded(cornorRadii: CGFloat) -> UIImage? {
        let react = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage else { return nil }
        UIBezierPath(roundedRect: react, byRoundingCorners: .allCorners, cornerRadii: CGSize(cornorRadii)).addClip()
        UIImage(cgImage: cgImage, scale: UIMainScreenScale, orientation: imageOrientation).draw(in: react)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


extension UIImage {
    
    func photoMessageThumbnil(to: CGFloat) -> UIImage? {
        return self.resizeScaleImage(preferredWidth: to)
    }
    
    func scaleFactor(preferredWidth: CGFloat) -> CGFloat {
        let oldWidth = size.width
        return preferredWidth / oldWidth
    }
    
    func resizeScaleImage(preferredWidth: CGFloat) -> UIImage? {
        let width = Int(preferredWidth)
       let height = Int(ceil(CGFloat(width) / self.size.width * self.size.height))
        let size = CGSize(width: width, height: height)

        guard let cgImage = self.cgImage else { return nil }

        var format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: nil,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent
        )

        var sourceBuffer = vImage_Buffer()
        defer {
            sourceBuffer.data.deallocate()
        }

        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = width * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: height * destBytesPerRow)
        defer {
            destData.deallocate()
        }

        var destBuffer = vImage_Buffer(
            data: destData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: destBytesPerRow
        )

        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }

        let destCGImage = vImageCreateCGImageFromBuffer(
            &destBuffer,
            &format,
            nil,
            nil,
            numericCast(kvImageNoFlags),
            &error
        )?.takeRetainedValue()

        guard error == kvImageNoError else { return nil }

        let scaledImage = destCGImage.flatMap {
            UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation)
        }

        return scaledImage
    }
    
    func resizedImageWithinRect(targetSize: CGSize) -> UIImage? {
        
        let image = self
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scaleImage(by scale: CGFloat) -> UIImage? {
        let size = self.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return self.resizedImageWithinRect(targetSize: scaledSize)
    }
}

extension UIImage {
    func imageWithBorder(imageSize: CGSize, borderWidth: CGFloat, borderColor: UIColor, cornorRadius: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
        imageView.image = self
        imageView.layer.cornerRadius = cornorRadius
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = borderColor.cgColor
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIMainScreenScale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}


extension UIImage {
    
    class func colorImage(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLength: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
