//
//  LoginViewController.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 8/29/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    var context = LAContext()
    @IBOutlet weak var loginButton: UIButton!
    
    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    var state = AuthenticationState.loggedout
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        state = .loggedout
        setupView()
        
        if context.biometryType == .touchID {
            loginButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            loginButton.setImage(UIImage(named: "touchID_white"), for: .normal)
        } else if context.biometryType == .faceID {
            loginButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            loginButton.setImage(UIImage(named: "faceid_white"), for: .normal)
        } else {
            loginButton.setTitle("Log in", for: .normal)
            loginButton.setTitleColor(.white, for: .normal)
        }
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if state == .loggedin {
            state = .loggedout
        } else {
            context = LAContext()
            context.localizedCancelTitle = "Cancel"
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    if success {
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                            self.performSegue(withIdentifier: "goToTable", sender: nil)
                        }
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
            }
        }
    }
    
    
    private func setupView() {
        let path = URL(fileURLWithPath:  Bundle.main.path(forResource: "backgroundvideo", ofType: "mp4")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.videoDidPlayToEnd(_:)), name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }
    
    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
//        player.seek(to: CMTime.zero)
        player.seek(to: CMTime.zero, completionHandler: nil)
    }

}

