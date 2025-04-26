//
//  VideoDataModel.swift
//  5ExceptionAssignmentProject
//
//  Created by Sadaf Khan on 26/04/25.
//

import Foundation

class Video {
    var title: String
    var url: URL
    var isDownloaded: Bool = false
    var downloadTask: URLSessionDownloadTask?
    var progress: Float = 0.0 // To track download progress
    
    init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}

