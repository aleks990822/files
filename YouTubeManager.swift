//
//  YouTubeManager.swift
//  STMEGI
//
//  Created by Aleks Amirkulov on 07/07/2019.
//  Copyright © 2019 STMEGI. All rights reserved.
//

import Foundation
import YouTubePlayer_Swift

class YouTubeManager {
    
    static var shared = YouTubeManager()
    private var id = [UITextView:[YouTubePlayerView]]()
    
    
    open func addVideo(textView:UITextView, id:String, rect:CGRect){
        
        let spacerView : YouTubePlayerView = YouTubePlayerView.init(frame: rect)
        spacerView.backgroundColor = .red
        if let myVideoURL = URL(string: "https://www.youtube.com/watch?v=\(id)") {
            spacerView.loadVideoURL(myVideoURL)
            textView.addSubview(spacerView)
            if self.id[textView] != nil {
                self.id[textView]?.append(spacerView)
            } else {
                self.id[textView] = [spacerView]
            }
        }
        
    }
    
    open func removeVideo(textView:UITextView) {
        
        guard let id = self.id[textView] else { return }
        for i in id {
            let result = i.getWebView()
            result.stopLoading()
            i.removeFromSuperview()
        }
        self.id[textView]?.removeAll()
        
    }
    
}
