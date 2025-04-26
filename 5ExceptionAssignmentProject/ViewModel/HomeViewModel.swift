//
//  HomeViewModel.swift
//  5ExceptionAssignmentProject
//
//  Created by Sadaf Khan on 26/04/25.
//

import Foundation

class HomeViewModel {
    
    func loadVideos() -> [Video] {
        var videoData: [Video] = []
        
        if let videoUrl1 = URL(string: StringConstants.video1) {
            videoData.append(.init(title: "Video 1", url: videoUrl1))
        }
        
        if let videoUrl2 = URL(string: StringConstants.video2) {
            videoData.append(.init(title: "Video 2", url: videoUrl2))
        }
        
        if let videoUrl3 = URL(string: StringConstants.video3) {
            videoData.append(.init(title: "Video 3", url: videoUrl3))
        }
        
        if let videoUrl4 = URL(string: StringConstants.video4) {
            videoData.append(.init(title: "Video 4", url: videoUrl4))
        }
        
        if let videoUrl5 = URL(string: StringConstants.video5) {
            videoData.append(.init(title: "Video 5", url: videoUrl5))
        }
       
        return videoData
    }
}
