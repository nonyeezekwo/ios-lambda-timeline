//
//  ViewController.swift
//  VideoPost
//
//  Created by Nonye on 7/8/20.
//  Copyright © 2020 Nonye Ezekwo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
    }
    
    private func requestPermissionAndShowCamera() {
        // TODO: get permission
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera()
        case .denied:
            // Take user to the settings app (or show a custom onboarding screen explaing why we need camera access)
            fatalError("Camera permission denied")
        case .notDetermined:
            // This will be based off requesting permission.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                guard granted else {
                    fatalError("Camera permission denied")
                }
                // Then dispatch to the main que
                DispatchQueue.main.async {
                    self.showCamera()
                }
            }
        case .restricted:
            // Parental control (Inform the user they dont have access, Maybe ask a parent?)
            fatalError("Camera permission restricted")
        @unknown default:
            fatalError("Unexpected enum value is not being handled")
        }
    }
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }


}

