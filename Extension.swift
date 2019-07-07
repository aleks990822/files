

import Foundation
import AVFoundation
import YouTubePlayer_Swift

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




