//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jason Lemrond on 9/16/15.
//  Copyright (c) 2015 Jason Lemrond. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton:     UIButton!
    @IBOutlet weak var recordButton:   UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RecordSoundsVC Did Load")
        
    }
    
    override func viewWillAppear(_: Bool) {
        // hide stop button and set up recordingLabel/background.
        print("RecordSoundsVC Will Appear")
        stopButton.hidden = true
        recordingLabel.text = "Tap to Record"
        recordButton.enabled = true
        
        //Scale Background Image to fit.
        let bgImg = UIImage(named: "BackgroundGradientBlackGrey")
        let imgView = UIImageView(frame: self.view.frame)
        imgView.image = bgImg
        self.view.addSubview(imgView)
        self.view.sendSubviewToBack(imgView)
        
        //Set up Stop Button Image via Code.
        let stopImg = UIImage(named: "Stop2")
        stopButton.setImage(stopImg, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Record audio.  Save to my_audio.wav.
    @IBAction func recordAudio(sender: UIButton) {
        print("Audio Record button engaged")
        recordingLabel.text = "Recording..."
        stopButton.hidden = false
        recordButton.enabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print("File Path for audio recording is \(filePath)")
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        print("Audio session established")
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        print("Recording Started")
        
    }
    
    //Function called upon recording completion.  Performs seque and stores data to recordedAudio.
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            print("Audio Recording did finish successfully")
            recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
            print("About to perform Seque")
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            print("filePathURL:", recordedAudio.filePathURL, "\r\ntitle:", recordedAudio.title)
        } else {
            print("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    //Stores recordedAudio data in recievedAudio to transfer data to next playSoundsVC.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundViewController = segue.destinationViewController as! PlaySoundViewController
            let data = sender as! RecordedAudio
            playSoundsVC.recievedAudio = data
        }
    }
    
    //Stop Recorder.  Reset UI.
    @IBAction func stopButton(sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("ERROR")
        }
        recordingLabel.text = "Tap to Record"
        stopButton.hidden = true
        recordButton.enabled = true
    }
}

