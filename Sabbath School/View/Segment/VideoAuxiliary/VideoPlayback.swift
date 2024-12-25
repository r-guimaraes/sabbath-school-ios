/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AVKit
import SwiftAudioEx
import MediaPlayer

enum VideoCollectionItemViewMode {
    case horizontal
    case vertical
}

class VideoPlayback: ObservableObject {
    static let shared = VideoPlayback()
    
    var controller = VideoPlaybackPlayerViewControllerV2()
    var pip: Bool = false
    
    func play(_ video: VideoAuxArtist) {
        let titleMetadata = AVMutableMetadataItem()
        titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
        titleMetadata.value = video.title as NSString
        
        let artistMetadata = AVMutableMetadataItem()
        artistMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtist
        artistMetadata.value = video.artist as NSString
        
        let items = [titleMetadata, artistMetadata]
        
        let pi = AVPlayerItem(asset: AVAsset(url: video.src))
        
        pi.externalMetadata = items
        
        let player = AVPlayer(playerItem: pi)
        
        if pip {
            controller.player?.pause()
            controller.player = player
            controller.player?.play()
        } else {
            controller.player = player
            controller.presentVideoViewController(controller) {
                self.controller.player?.play()
            }
        }
    }
}

class VideoPlaybackPlayerViewControllerV2: AVPlayerViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func presentVideoViewController(_ viewController: VideoPlaybackPlayerViewControllerV2, completion: (() -> Void)? = nil) {
        if let activeVC = UIApplication.shared.getActiveViewController() {
            activeVC.present(viewController, animated: true) {
                completion?()
            }
        }
    }
}

extension VideoPlaybackPlayerViewControllerV2: AVPlayerViewControllerDelegate {
    public func playerViewControllerDidStartPictureInPicture(_ playerViewController2: AVPlayerViewController) {
        VideoPlayback.shared.pip = true
        UIApplication.shared.getActiveViewController()?.dismiss(animated: true)
    }
    
    public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        VideoPlayback.shared.pip = false
    }
    
    public func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return true
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController,
                              restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.presentVideoViewController(playerViewController as! VideoPlaybackPlayerViewControllerV2) {
            completionHandler(true)
        }
    }
}
