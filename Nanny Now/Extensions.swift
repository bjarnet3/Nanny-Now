//
//  Extensions.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 05.12.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

// Stored Images
let imageCache = NSCache<NSString, UIImage>()

// Type Extension
public extension String {
    var isEmptyStr:Bool{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty
    }
}

extension UIImageView {
    /**
     Load Image from Catch or Get from URL function
     
     [Tutorial on YouTube]:
     https://www.youtube.com/watch?v=GX4mcOOUrWQ "Click to Go"
     
     [Tutorial on YouTube] made by **Brian Voong**
     
     - parameter urlString: URL to the image
    */
    func loadImageUsingCacheWith(urlString: String, completion: Completion? = nil) {
        // print("-- loadImageUsingCacheWith --")
        let urlNSString = urlString as NSString
        
        // set initial image to nil so it doesn't use the image from a reused cell
        // image = nil
        
        // Check cache for image first
        if let cacheImage = imageCache.object(forKey: urlNSString) {
            self.image = cacheImage
            // print("found Image=\(urlString) in imageCache (loadImageUsingCacheWith)")
            completion?()
            return
        }
        // If not,, download with dispatchqueue
        let url = URL(string: urlString)
        // URL Request
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            // Run on its own threads with DispatchQueue
            DispatchQueue.main.async(execute: { () -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    self.image = downloadedImage
                    // print("set image=\(urlString) in (loadImageUsingCacheWith)")
                    imageCache.setObject(downloadedImage, forKey: urlNSString)
                    completion?()
                }
            })
        }).resume( )
    }
    
    func loadFacebookImageUsingCache(with facebookID: String, size: PictureSize, completion: Completion? = nil) {
        let urlString = "https://graph.facebook.com/" + facebookID + "/picture?type=\(size)"
        loadImageUsingCacheWith(urlString: urlString, completion: completion)
    }
}

// Calculate age from birthDay Date
extension Date {
    static func age(birthDate: Date) -> String {
        let years = Calendar.current.component(.year, from: birthDate)
        return String(years)
    }
    
    // Calculate age from self(Date)
    // Thanx to https://stackoverflow.com/questions/28935565/calculate-age-from-birth-date
    // Easier then calcAge that i made to dyret
    var calcAge: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
        // let myAge = Calendar.current.date(from: DateComponents(year: 1983, month: 6, day: 10))!
    }
}

protocol Blurable
{
    var layer: CALayer { get }
    var subviews: [UIView] { get }
    var frame: CGRect { get }
    var superview: UIView? { get }
    
    func addSubview(_ view: UIView)
    func removeFromSuperview()
    
    func blur(blurRadius: CGFloat)
    func unBlur()
    
    var isBlurred: Bool { get }
}

extension Blurable
{
    func blur(blurRadius: CGFloat)
    {
        if self.superview == nil
        {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        guard let blur = CIFilter(name: "CIGaussianBlur"),
            let this = self as? UIView else
        {
            return
        }
        
        blur.setValue(CIImage(image: image!), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext = CIContext(options: nil)
        
        let result = blur.value(forKey: kCIOutputImageKey) as! CIImage?
        
        let boundingRect = CGRect(x:0,
                                  y: 0,
                                  width: frame.width,
                                  height: frame.height)
        
        let cgBlurImage = ciContext.createCGImage(result!, from: boundingRect)
        
        let filteredImage = UIImage(cgImage: cgBlurImage!)
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = UIViewContentMode.left
        
        if let superview = superview as? UIStackView,
            let index = (superview as UIStackView).arrangedSubviews.index(of: this)
        {
            removeFromSuperview()
            superview.insertArrangedSubview(blurOverlay, at: index)
        }
        else
        {
            blurOverlay.frame.origin = frame.origin
            
            UIView.transition(from: this,
                              to: blurOverlay,
                              duration: 0.3,
                              options: UIViewAnimationOptions.curveEaseIn,
                              completion: nil)
        }
        
        objc_setAssociatedObject(this,
                                 &BlurableKey.blurable,
                                 blurOverlay,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func unBlur()
    {
        guard let this = self as? UIView,
            let blurOverlay = objc_getAssociatedObject(self, &BlurableKey.blurable) as? BlurOverlay else
        {
            return
        }
        
        if let superview = blurOverlay.superview as? UIStackView,
            let index = (blurOverlay.superview as! UIStackView).arrangedSubviews.index(of: blurOverlay)
        {
            blurOverlay.removeFromSuperview()
            superview.insertArrangedSubview(this, at: index)
        }
        else
        {
            this.frame.origin = blurOverlay.frame.origin
            
            UIView.transition(from: blurOverlay,
                              to: this,
                              duration: 0.2,
                              options: UIViewAnimationOptions.curveEaseIn,
                              completion: nil)
        }
        
        objc_setAssociatedObject(this,
                                 &BlurableKey.blurable,
                                 nil,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    var isBlurred: Bool
    {
        return objc_getAssociatedObject(self, &BlurableKey.blurable) is BlurOverlay
    }
}

extension UIView: Blurable
{
    func fadeOut(duration: TimeInterval = 0.2, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.2
        }, completion: completion)
    }
    
    func fadeIn(duration: TimeInterval = 0.2, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }
}

class BlurOverlay: UIImageView
{
}

struct BlurableKey
{
    static var blurable = "blurable"
}
