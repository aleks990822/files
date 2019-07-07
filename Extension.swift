//
//  Extension.swift
//  STMEGI
//
//  Created by aleks on 04.05.17.
//  Copyright © 2017 STMEGI. All rights reserved.
//

import Foundation
import AVFoundation
import YouTubePlayer_Swift

@objc protocol PresenTVCellProtocol: class {
    @objc optional func presentVC(modals:Modal)
    @objc optional func presentVC(modals:[Modal], indexPath:IndexPath)
    @objc optional func presentVC(modals:[Modal], indexPath:IndexPath, completion: @escaping ([Modal], IndexPath)->())
}

protocol URLProtocol: class {
    func getUrl() -> String
}

struct Extension{
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stu
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func preloader<T>(view:T, indexPath:IndexPath, type:Type = Type.news) -> UIView? {
        
        switch type {
        case .main:
            if indexPath.row == 1 {
                let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "cellVideo", for: indexPath) as! TableViewCell
                cell.isAnimate = true
                return cell
            } else {
                let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "Preload", for: indexPath) as! PreloaderCell
                return cell
            }
        case .news:
            let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "Preload", for: indexPath) as! PreloaderCell
            return cell
        case .video: 
            let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "cellVideo", for: indexPath) as! PTVCVideo
            return cell
        case .event:
            let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! PTVCEvent
            return cell
        case .face:
            let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "cellFace", for: indexPath) as! PTVCFace
            return cell
        case .library:
            let cell = (view as! UICollectionView).dequeueReusableCell(withReuseIdentifier: "cellLibrary", for: indexPath) as! PCVCLibrary
            return cell
        case .photo:
            let cell = (view as! UITableView).dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! PTVCPhoto
            return cell
        }
        
    }
    
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// поворачивает в какой режим нужно
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func openSetting(title:String,message:String){
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Настройки", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {  return  }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
                
            }
        }
        alert.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    
}

enum Type {
    
    case main
    case news
    case video
    case event
    case face
    case library
    case photo
    
}

class PreloadTV {
    
    let preloadView = UIView()
    let img = UIView()
    let dt = UIView()
    let nm = UIView()
    
    func start(view:UIView, scroll:UIScrollView){
        
        preloadView.frame = view.frame
        preloadView.backgroundColor = .white
        scroll.isUserInteractionEnabled = false
        
        let height = view.frame.width * 1.07
        img.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height / 2)
        
        dt.frame.size.height = 20
        dt.frame.size.width = view.frame.width - 16
        dt.center = view.center
        dt.frame.origin.y = (height / 2) + 8
        
        nm.frame.size.height = 30
        nm.frame.size.width = view.frame.width - 16
        nm.center = view.center
        nm.frame.origin.y = dt.frame.origin.y + 28
        
        preloadView.addSubview(img)
        preloadView.addSubview(nm)
        scroll.addSubview(preloadView)
        
        AMShimmer.start(for: img , except: [], isToLastView: false)
        AMShimmer.start(for: nm , except: [], isToLastView: false)
        
    }
    
    func stop(scroll:UIScrollView){
        
        AMShimmer.stop(for: img)
        AMShimmer.stop(for: dt)
        AMShimmer.stop(for: nm)
        
        scroll.isUserInteractionEnabled = true
        preloadView.removeFromSuperview()
        
    }
    
}

class PreloadFace {
    
    let preloadView = UIView()
    let img = UIView()
    let nm = UIView()
    var txt = [UIView]()
    
    func start(view:UIView, scroll:UIScrollView){
        
        preloadView.frame = view.frame
        preloadView.backgroundColor = .white
        scroll.isUserInteractionEnabled = false
        
        img.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        
        nm.frame.size.height = 30
        nm.frame.size.width = view.frame.width - 16
        nm.center = view.center
        nm.frame.origin.y = 300 + 8
        
        for i in 0 ... 5 {
            
            if txt.count >= 6 { txt.removeAll() }
            let y = txt.count != 0 ? txt[i - 1].frame.origin.y + txt[i - 1].frame.height + 15 : nm.frame.origin.y + 45
            
            let bg = UIView(frame: CGRect(x: 8, y: y, width: view.frame.width - 16, height: 68 ))
            let txt = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 16, height: 22))
            let txt2 = UILabel(frame: CGRect(x: 0, y: 30, width: view.frame.width - 16, height: 22))
            let line = UIView(frame: CGRect(x: 7, y: 67 , width: bg.frame.width, height: 1))
            line.backgroundColor = .gray
            
            bg.addSubview(line)
            bg.addSubview(txt)
            bg.addSubview(txt2)
            self.txt.append(bg)
            preloadView.addSubview(bg)
            AMShimmer.start(for: bg , except: [], isToLastView: false)
            
        }
        
        preloadView.addSubview(img)
        preloadView.addSubview(nm)
        scroll.addSubview(preloadView)
        
        AMShimmer.start(for: img , except: [], isToLastView: false)
        AMShimmer.start(for: nm , except: [], isToLastView: false)
        
    }
    
    func stop(scroll:UIScrollView){
        
        AMShimmer.stop(for: img)
        AMShimmer.stop(for: nm)
        let _ = txt.map { AMShimmer.stop(for: $0) }
        
        scroll.isUserInteractionEnabled = true
        preloadView.removeFromSuperview()
        
    }
    
}

class Preload {
    
    let preloadView = UIView()
    let img = UIView()
    let dt = UIView()
    let nm = UIView()
    let txt = UIView()
    var tvc = [UIView]()
    
    func start(view:UIView, scroll:UIScrollView){
        
        preloadView.frame = view.frame
        preloadView.backgroundColor = .white
        scroll.isUserInteractionEnabled = false
        
        let height = view.frame.width * 1.07
        img.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height / 2)
        
        dt.frame.size.height = 20
        dt.frame.size.width = view.frame.width - 16
        dt.center = view.center
        dt.frame.origin.y = (height / 2) + 10
        
        
        nm.frame.size.height = 50
        nm.frame.size.width = view.frame.width - 16
        nm.center = view.center
        nm.frame.origin.y = (height / 2) + 40
        
        txt.frame.size.height = 100
        txt.frame.size.width = view.frame.width - 16
        txt.center = view.center
        txt.frame.origin.y = (height / 2) + 100
        
        for i in 0 ... 5 {
            
          // print(tvc.count, i)
            if tvc.count >= 6 { tvc.removeAll() }
            let y = tvc.count != 0 ? tvc[i - 1].frame.origin.y + 80 : txt.frame.origin.y + 100
            let bg = UIView(frame: CGRect(x: 8, y: y, width: view.frame.width - 16, height: 81 ))
            
            let img = UIView(frame: CGRect(x: 0, y: 8, width: 100, height: 64))
            let txt = UIView(frame: CGRect(x: 108, y: 8, width: bg.frame.width - 108, height: 64))
            let line = UIView(frame: CGRect(x: 7, y: 80 , width: bg.frame.width, height: 1))
            line.backgroundColor = UIColor.clear
            
            bg.addSubview(img)
            bg.addSubview(txt)
            bg.addSubview(line)
            tvc.append(bg)
            preloadView.addSubview(bg)
            AMShimmer.start(for: bg , except: [], isToLastView: false)
            
        }
        
        preloadView.addSubview(img)
        preloadView.addSubview(dt)
        preloadView.addSubview(nm)
        preloadView.addSubview(txt)
        scroll.addSubview(preloadView)
        
        AMShimmer.start(for: img , except: [], isToLastView: false)
        AMShimmer.start(for: dt , except: [], isToLastView: false)
        AMShimmer.start(for: nm , except: [], isToLastView: false)
        AMShimmer.start(for: txt , except: [], isToLastView: false)
        
    }
    
    func stop(scroll:UIScrollView){
        
        AMShimmer.stop(for: img)
        AMShimmer.stop(for: dt)
        AMShimmer.stop(for: nm)
        AMShimmer.stop(for: txt)
        let _ = tvc.map { AMShimmer.stop(for: $0) }
        tvc.removeAll()
        
        scroll.isUserInteractionEnabled = true
        preloadView.removeFromSuperview()
        
    }
    
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, height: CGFloat, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y + height, width: 1, height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func scrollToLeft() {
        setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
        
        
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
}

extension UITextView {
    
    // конвертирует range в CGRect
    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
        
        guard let attributedText = attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: intrinsicContentSize)
        textContainer.lineFragmentPadding = 0.0
        layoutManager.addTextContainer(textContainer)
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
    }
    
    // добавляет фотографии и видео в текст
    func convertToInlineImageFormat(htmlString:String){
        
        let text = videoInText(htmlString: htmlString)
        let videoId = text.1
        let HTMLString = text.0
        
        let content = try! NSMutableAttributedString(
            data: HTMLString.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [ .documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        var videoRange = [NSRange]()
        var videoRect = [CGRect]()
        var isVideo = false
        
        let fontDesc =  UIFont(name:"roboto-light", size: 19)
        content.addAttribute(NSAttributedString.Key.font, value: fontDesc!, range: NSRange(location: 0, length: content.length))
        content.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: content.length), options: [], using: {(value,range,stop) -> Void in
            
            if (value is NSTextAttachment) {
                let attachment: NSTextAttachment? = (value as? NSTextAttachment)
                let fileWrapper = attachment?.fileWrapper
                DispatchQueue.main.async {
                    let width = self.frame.size.width
                    if fileWrapper?.preferredFilename == "0.jpg" {
                        isVideo = true
                        videoRange.append(range)
                        videoRect.append(CGRect(x: 0, y: 0, width: width, height: CGFloat(width/(attachment?.bounds.width ?? width) * (attachment?.bounds.height ?? width))))
                    }
                    
                    attachment?.bounds.origin = CGPoint(x: 0, y: 20)
                    attachment?.bounds.size = CGSize(width: width, height: CGFloat(width/(attachment?.bounds.width ?? width) * (attachment?.bounds.height ?? width)))
                }
                
            }
        })
        
        DispatchQueue.main.async {
            if isVideo {
                // отступы внутри контейнера
                self.textContainer.lineFragmentPadding = 0
                self.attributedText = content
                
                for i in 0 ..< videoRange.count {
                    // получает CGRect видео
                    let rect = self.boundingRect(forCharacterRange: videoRange[i])!
                    // удаляет фотографию видео
                    let copy = self.attributedText.mutableCopy() as? NSMutableAttributedString
                    copy?.replaceCharacters(in: videoRange[i], with: "")
                    self.attributedText = copy
                    //добавляет плеер
                    let imgRect : UIBezierPath = UIBezierPath(rect:rect)
                    self.textContainer.exclusionPaths = [imgRect]
                    YouTubeManager.shared.addVideo(textView: self, id:videoId[i], rect: rect)
                }
            } else {
                self.attributedText = content
            }
        }
        
    }
    
    //убирает iframe и возвращает id видео
    func videoInText(htmlString:String)-> (String, [String]){
        
        func setText(text: String) -> (String, [String]) {
            return formatString(text: text);
        }
        //main function that adds the youtube frame
        func formatString(text: String) -> (String, [String]) {
            let iframe_texts = matches(for: ".*iframe.*", in: text);
            var new_text = text;
            var video_id = [String]()
            
            if iframe_texts.count > 0 {
                for iframe_text in iframe_texts {
                    let iframe_id = matches(for: "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)", in: iframe_text);
                    if iframe_id.count > 0 { //just in case there is another type of iframe
                        new_text = new_text.replacingOccurrences(of: iframe_text, with:"<a href='https://www.youtube.com/watch?v=\(iframe_id[0])'><img src=\"https://img.youtube.com/vi/" + iframe_id[0] + "/0.jpg\" alt=\"\" width=\"600\" /></a>");
                        video_id.append(iframe_id[0])
                    }
                }
            } else {
               // print("there is no iframe in this text");
            }
            
            return (new_text, video_id)
        }
        
        func matches(for regex: String, in text: String) -> [String] {
            
            do {
                let regex = try NSRegularExpression(pattern: regex,  options: .caseInsensitive)
                let nsString = text as NSString
                let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
                return results.map { nsString.substring(with: $0.range)}
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
        
        return setText(text: htmlString)
    }
    
}

extension UIImageView {
    
    func loadImage(url:String?, completion: @escaping ()->()){
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let img = url, let url = URL(string: "https://stmegi.com\(img)"), let data = NSData(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data as Data)
                completion()
            }
        }
    }
    
}

//extension UIView {
//
//    func dropShadow(scale: Bool = true) {
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowOffset = CGSize(width: -1, height: 1)
//        self.layer.shadowRadius = 1
//
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//
//    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = color.cgColor
//        self.layer.shadowOpacity = opacity
//        self.layer.shadowOffset = offSet
//        self.layer.shadowRadius = radius
//
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//}

public extension Int {
    func abbreviatedNumber() -> String {
        if abs(self) < 10000 {
            return String(self)
        }
        let sign = self < 0 ? "-" : ""
        let num = fabs(Double(self))
        let exp:Int = Int(log10(num) / 3.0 )
        
        let units:[String] = ["K","M","G","T","P","E"]
        
        let roundedNum = round(10 * num / pow(1000.0,Double(exp))) / 10
        
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
    
}

extension UIColor {
    
    @objc convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


extension UIApplication {
    @objc class func topViewController(base: UIViewController? = UIApplication.shared
        .keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UINavigationItem {
    func back(){
        //кнопка назад
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.backBarButtonItem = backItem
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboardView() {
        view.endEditing(true)
    }
    
}

