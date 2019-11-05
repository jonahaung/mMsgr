//
//  LocationCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 20/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: MessageCell {
    
    let imageView: UIImageView = {
        $0.isUserInteractionEnabled = true
        $0.layer.cornerRadius = 19
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            imageView.frame = bubbleFrame
        }
    }
    
    override func setup() {
        
        super.setup()
        contentView.addSubview(imageView)
        imageView.addInteraction(contextMenuInterAction)
    }
    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
        
        let url =  docURL.appendingPathComponent(msg.id.uuidString)

        if let storedImage = UIImage(contentsOfFile: url.path) {
            
            imageView.image = storedImage
            setNeedsLayout()
        } else {
         
            let size = msg.mediaSize()
            
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(msg.x), longitude: CLLocationDegrees(msg.y))
            
            let options = MKMapSnapshotter.Options()
            options.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            options.scale = UIMainScreenScale
            options.size = size
            options.mapType = .satellite
            
            let snapShotter = MKMapSnapshotter(options: options)
            snapShotter.start { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard let snapshot = snapshot, error == nil else {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                UIGraphicsBeginImageContextWithOptions(size, true, 0)
                snapshot.image.draw(at: .zero)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineBreakMode = .byWordWrapping

                let font = UIFont.monoSpacedFont
                let attrs: [NSAttributedString.Key : Any] = [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: UIColor.white, .backgroundColor: UIColor.black.withAlphaComponent(0.2)]

                let textSize = CGSize(width: size.width, height: font.lineHeight * 3 + 10)
                msg.text.draw(with: textSize.bma_rect(inContainer: CGRect(origin: .zero, size: size), xAlignament: .center, yAlignment: .top, dx: 0, dy: 2), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)


                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()


                try? image?.jpegData(compressionQuality: 1)?.write(to: url, options: .atomic)
                Async.main {
                    self.imageView.image = image
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            
            let location = touch.location(in: self)
            if bubbleFrame.contains(location), let msg = self.msg {
                let alert = UIAlertController(style: .actionSheet)
                alert.set(title: msg.text, font: UIFont.preferredFont(forTextStyle: .headline))
                alert.addAction(image: UIImage(systemName: "mappin.and.ellipse"), title: "Show on Map", color: nil, style: .default, isEnabled: true) {_ in
                
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(msg.text) {(placemarks, error) in
                        guard error == nil else {
                            print("Geocoding error: \(error!)")
                            return
                        }
                        if let coordinate = placemarks?.first?.location?.coordinate {
                            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                            mapItem.name = msg.sender?.displayName
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault])
                        }
                    }
                }
                
                alert.addCancelAction()
                alert.show()
            }
        }
    }
    
}
