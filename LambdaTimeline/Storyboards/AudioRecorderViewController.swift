//
//  AudioRecorderViewController.swift
//  LambdaTimeline
//
//  Created by Nonye on 7/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }
    var timer: Timer?
    
    var recordingURL: URL?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var audioRecorder: AVAudioRecorder?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var audioSlider: UISlider!
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        cancelTimer()
    }
    
    // MARK: - ACTIONS
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        togglePlayback()
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        toggleRecording()
    }
    
    @IBAction func updateTime(_ sender: UISlider) {
        
    }
    
    func updateViews() {
        playButton.isSelected = isPlaying
        
        let elaspedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        
        let timeRemaining = round(duration) - elaspedTime
        currentTime.text = timeIntervalFormatter.string(for: elaspedTime)
        durationTime.text = timeIntervalFormatter.string(for: timeRemaining)
        
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = Float(duration)
        audioSlider.value = Float(elaspedTime)
        
        recordButton.isSelected = isRecording
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            self.updateViews()
        }
    }
    func play() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    func createNewRecordingURL() -> URL {
        // using documentdirectory to store it as we would with in previous projects
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        return file
    }
    
    func startRecording() {
        // Grab the recording URL
        let recordingURL = createNewRecordingURL()
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat)
        
        audioRecorder?.delegate = self
        audioRecorder?.record()
        self.recordingURL = recordingURL
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
            updateViews()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
    func requestPermissionOrStartRecording() {
         switch AVAudioSession.sharedInstance().recordPermission {
         case .undetermined:
             AVAudioSession.sharedInstance().requestRecordPermission { granted in
                 guard granted == true else {
                     print("We need microphone access")
                     return
                 }
                 
                 print("Recording permission has been granted!")
                 // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
             }
         case .denied:
             print("Microphone access has been blocked.")
             
             let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
             
             alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                 UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
             })
             
             alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
             
             present(alertController, animated: true, completion: nil)
         case .granted:
             startRecording()
         @unknown default:
             break
         }
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
extension AudioPlayerViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("\(error)")
            
        }
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
}

extension AudioPlayerViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            NSLog("Recording finished and successful")
            
        }
        updateViews()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            NSLog("Audio Record Encoding Error: \(error)")
            
        }
        updateViews()
    }
}
