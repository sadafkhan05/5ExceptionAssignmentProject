//
//  TableViewCell.swift
//  5ExceptionAssignmentProject
//
//  Created by Sadaf Khan on 26/04/25.
//

import UIKit

typealias VoidClouser = (() -> ())

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnPlayRef: UIButton!
    @IBOutlet weak var btnDownloadRef: UIButton!
    @IBOutlet weak var btnDeleteRef: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var playClouser: VoidClouser?
    var downloadClouser: VoidClouser?
    var deleteClouser: VoidClouser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction private func btnPlayTap(_ sender: Any) {
        playClouser?()
    }
    
    @IBAction private func btnDownloadTap(_ sender: Any) {
        downloadClouser?()
    }
    
    @IBAction private func btnDeleteTap(_ sender: Any) {
        deleteClouser?()
    }

    
    func configureCell(videodata: Video) {
        self.titleLabel.text = videodata.title
        
        if videodata.isDownloaded {
            /// Play Scenario
            self.btnPlayRef.isHidden = false
            self.btnDeleteRef.isHidden = false
            self.btnDownloadRef.isHidden = true
            self.progressView.isHidden = true
        } else {
            /// Video Download scenario
            self.btnPlayRef.isHidden = true
            self.btnDeleteRef.isHidden = true
            self.btnDownloadRef.isHidden = false
            self.progressView.isHidden = true
        }
        
        /// Show download progress
        if !videodata.isDownloaded {
            self.progressView.isHidden = false /// Show progress view if not downloaded
            self.progressView.progress = videodata.progress /// Update progress view
        } else {
            self.progressView.isHidden = true
        }
    }
    
}
