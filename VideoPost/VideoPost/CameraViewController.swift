//
//  CameraViewController.swift
//  VideoPost
//
//  Created by Nonye on 7/8/20.
//  Copyright © 2020 Nonye Ezekwo. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession  = AVCaptureSession()
    
    var fileOutput = AVCaptureMovieFileOutput()
   
    var player: AVPlayer?
    var playerView: VideoPlayerView!
    var delegate: VideoCollectionViewController!
    var videoURL: URL?
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCaptureSession()
        sendButton.isHidden = true
        titleTextField.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecording()
    }
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let clipName = titleTextField.text,
        clipName.count > 0,
            let fileURL = videoURL else { return }
        
        delegate?.videoClip.append((clipName, fileURL))
        let thumbnaill = delegate.createThumbnail(url: fileURL)
        delegate?.imageView.append(thumbnaill)
        
        navigationController?.popViewController(animated: true)
        
    }
    

    private func playMovie(at url: URL) {
           
           let player = AVPlayer(url: url)
        
        if playerView == nil {

            let playerView = VideoPlayerView()
            playerView.player = player
            
            var frame = view.bounds
            
            frame.size.height /= 4
            frame.size.width /= 4
            
            frame.origin.y = view.directionalLayoutMargins.top
  
            playerView.frame = frame
            
            view.addSubview(playerView)
            self.playerView = playerView
        }
        
        player.play()
        sendButton.isHidden = false
        self.player = player
    }
    private func toggleRecording() {
        // First we will ask if the file output is recording. If so then we will stop the recording
        if fileOutput.isRecording {
            //Stop the recording
            fileOutput.stopRecording()
        } else {
            // Save to the URL, set VC as the delegate
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
            // call update views here
            updateViews()
        }
    }

 
    func setUpCaptureSession() {
        // Let the capture session know we are going to be changing its settings (inputs, outputs)
        captureSession.beginConfiguration()
        
        // Camera
        
        let camera = bestCamera()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                // FUTURE: Display error that gets throw so you understand why it doesn't work.
                fatalError("Cannot create camera input. Do something better than crashing here")
        }
        //Assuming you can capture -
        captureSession.addInput(cameraInput)
        
        // Microphone
        //1st making a private func called bestAudio
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Cannot create and add input for microphone")
        }
        
        // Quality Level
        //we have to ask the capture session if it can add session preset for 1080p
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        } else {
            fatalError("1920x1080 preset is unavailable")
        }
        
        // Outputs
        //make sure capture session has the file output
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot add the movie recording output")
        }
        captureSession.addOutput(fileOutput)
        
        //Now it can save all of this and start using these settings
        captureSession.commitConfiguration()
        
        // Give the camera view the session so it can show the camera preview to the user
        cameraView.session = captureSession
        
    }
    
    private func bestCamera() -> AVCaptureDevice {
        // Choose the ideal camera available for the device
        // FUTURE: we could add a button to let the user choose front/back camera
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        fatalError("No camera available. Are you on a simulator?")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        // we are setting the default to let the device pick the default or best mic for audio
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            return audioDevice
        }
        fatalError("No audio capture device present")
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording at: \(fileURL)")
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        if let error = error {
            NSLog("Error saving recording")
        }
    }
}
