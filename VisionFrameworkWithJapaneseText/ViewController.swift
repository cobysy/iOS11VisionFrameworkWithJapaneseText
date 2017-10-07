//
//  ViewController.swift
//  VisionFrameworkWithJapaneseText
//
//  Created on 07/10/2017.
//  Copyright © 2017 cobysy. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    var currentImageIndex = 0
    var images : [UIImage]?
    var imageView : UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        images = [
            UIImage(named: "simple")!,
            UIImage(named: "1日本語メイリオ")!,
            UIImage(named: "2日本語MSP明朝")!,
            UIImage(named: "3日本語HGP行書体")!,
            UIImage(named: "4日本語HGP創英角ポップ体")!,
            UIImage(named: "5日本語手書き文字")!,
            UIImage(named: "6日本語手書き文字2")!
        ]

        performDetection()
    }

    func performDetection() {
        let request = VNDetectTextRectanglesRequest(completionHandler: self.textDetectionHandler)
        request.reportCharacterBoxes = true
        
        let handler = VNImageRequestHandler(cgImage: images![currentImageIndex].cgImage!, options: [:])
        try! handler.perform([request])
    }
    
    func textDetectionHandler(request: VNRequest, error: Error?) {
        if error != nil {
            return
        }
        
        if let results = request.results as? [VNTextObservation] {
            
            // Start with the original image
            var overlayedImage = images![currentImageIndex]
            
            // Draw boxes around each detectected character
            for result in results {
                overlayedImage = overlayImageWithTextObservations(overlayedImage, observations: result.characterBoxes!)
            }

            // Just update the imageView
            if (imageView != nil) {
                imageView!.image = overlayedImage
                return
            }
            
            // Create the imageView for the first time
            imageView = UIImageView(image: overlayedImage)
            if let iv = imageView {
                // make imageView respond to user taps
                iv.isUserInteractionEnabled = true
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                iv.addGestureRecognizer(tapRecognizer)
                
                iv.translatesAutoresizingMaskIntoConstraints = false
                iv.contentMode = .scaleAspectFit
                view.addSubview(iv)
                
                // Let imageView fill it's superview
                let attributes: [NSLayoutAttribute] = [.top, .bottom, .right, .left]
                NSLayoutConstraint.activate(attributes.map {
                    NSLayoutConstraint(item: iv, attribute: $0, relatedBy: .equal, toItem: iv.superview, attribute: $0, multiplier: 1, constant: 0)
                })
            }
        }
    }
    
    @objc func imageTapped(sender : UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            currentImageIndex += 1
            if (currentImageIndex >= images!.count) {
                currentImageIndex = 0;
            }
            performDetection()
        }
    }
    
    func overlayImageWithTextObservations(_ image: UIImage, observations : [VNRectangleObservation]) -> UIImage {
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(image.size)
        
        // Draw the starting image in the current context as background
        image.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
       
        var t = CGAffineTransform.identity
        t = t.scaledBy(x: image.size.width, y: -image.size.height)
        t = t.translatedBy(x: 0, y: -1)
        
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.blue.cgColor)
        for rectangleObservation in observations {
            UIBezierPath(rect: rectangleObservation.boundingBox.applying(t)).stroke()
        }
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return modified image
        return myImage!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
