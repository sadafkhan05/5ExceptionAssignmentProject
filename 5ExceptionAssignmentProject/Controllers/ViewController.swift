//
//  ViewController.swift
//  5ExceptionAssignmentProject
//
//  Created by Sadaf Khan on 26/04/25.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var backgroundSession: URLSession!
    private var videos: [Video] = []
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()

        videos = viewModel.loadVideos()
        setupBackgroundSession()
        checkDownloadedVideos() /// Check for already downloaded videos
    }

}

// MARK: - Initial SetUp
extension ViewController {
    func initialSetUp() {
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupBackgroundSession() {
        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundConfigIdentifier.backgroundIdentifier)
        backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func checkDownloadedVideos() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for video in videos {
            let destinationURL = documentsDirectory.appendingPathComponent(video.title + ".mp4")
            if fileManager.fileExists(atPath: destinationURL.path) {
                video.isDownloaded = true /// Mark as downloaded
            }
        }
        tableView.reloadData()
    }
}


// MARK: - TableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        cell.configureCell(videodata: videos[indexPath.row])
        
        cell.downloadClouser = {
            let video = self.videos[indexPath.row]
            if let task = video.downloadTask {
                /// If the download is in progress, pause it
                if task.state == .running {
                    task.suspend()
                    video.downloadTask = nil /// Clear the task reference
                } else if task.state == .suspended {
                    /// If the download is paused, resume it
                    task.resume()
                } else {
                    /// Start downloading if not already downloading
                    self.downloadVideo(video)
                }
            } else {
                /// Start downloading if not already downloading
                self.downloadVideo(video)
            }
        }
        
        cell.playClouser = {
            self.playVideo(self.videos[indexPath.row])
        }
        
        cell.deleteClouser = {
            self.deleteVideo(self.videos[indexPath.row])
        }
        return cell
    }
}

// MARK: - Delete, Play & Download Operation on Video.
extension ViewController {
    func downloadVideo(_ video: Video) {
        let downloadTask = backgroundSession.downloadTask(with: video.url)
        video.downloadTask = downloadTask
        downloadTask.resume()
    }
    
    func playVideo(_ video: Video) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(video.title + ".mp4")
        
        let player = AVPlayer(url: destinationURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    func deleteVideo(_ video: Video) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(video.title + ".mp4")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
                video.isDownloaded = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}

// MARK: - URLSessionDownloadDelegate
extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let video = videos.first(where: { $0.downloadTask == downloadTask }) else { return }
        
        /// Move the downloaded file to a permanent location
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(video.title + ".mp4")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)
            video.isDownloaded = true
            video.progress = 0  /// Re-initialize progress to zero after complete download.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error moving file: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
           /// Calculate the progress of the download
           let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
   
           /// Update the video's progress
           if let video = videos.first(where: { $0.downloadTask == downloadTask }) {
               video.progress = progress
   
               /// Update the UI on the main thread
               DispatchQueue.main.async {
                   if let index = self.videos.firstIndex(where: { $0.downloadTask == downloadTask }) {
                       let indexPath = IndexPath(row: index, section: 0)
                       if let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCell {
                           cell.progressView.progress = progress /// Update the progress view
                       }
                   }
               }
           }
       }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download failed with error: \(error.localizedDescription)")
            /// Handle the error
            DispatchQueue.main.async {
                if let index = self.videos.firstIndex(where: { $0.downloadTask == task }) {
                    let video = self.videos[index]
                    video.downloadTask = nil
                    /// Show a retry option
                    let alert = UIAlertController(title: StringConstants.downloadFailedTitle,
                                                  message: "Failed to download \(video.title). Would you like to retry?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: StringConstants.retryText, style: .default, handler: { _ in
                        self.downloadVideo(video)   /// Retry downloading video.
                    }))
                    alert.addAction(UIAlertAction(title: StringConstants.cancelText, style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            /// Clear the download task reference when completed
            if let index = videos.firstIndex(where: { $0.downloadTask == task }) {
                videos[index].downloadTask = nil
            }
        }
    }
}
