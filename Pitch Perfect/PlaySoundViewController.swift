//
//  PlaySoundViewController.swift
//  Pitch Perfect
//
//  Created by Jason Lemrond on 9/22/15.
//  Copyright © 2015 Jason Lemrond. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class PlaySoundViewController: UIViewController, AVAudioPlayerDelegate {
    
    var recievedAudio: RecordedAudio!
    
    @IBOutlet var SlowButton: UIButton!
    @IBOutlet var FastButton: UIButton!
    @IBOutlet var DarthButton: UIButton!
    @IBOutlet var ChipButton: UIButton!
    var buttons: [UIButton]!
    
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var audioFile:   AVAudioFile!
    var audioBuffer: AVAudioPCMBuffer!
    
    @IBOutlet var rateSlider: UISlider!
    @IBOutlet var pitchSlider: UISlider!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var rateDisplay: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var pitchDisplay: UILabel!

    
    // Load Images for Sliders.
    let sliderMinImage = UIImage(named: "Slider_Min_GreyMinimalist")
    let sliderMaxImage = UIImage(named: "Slider_Max_GreyMinimalist")
    let sliderThumbImage = UIImage(named: "Slider_Thumb_Minimalist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up Audio Engine.  Audio buffer also used because ScheduleFile's completion handler would sometimes run prior to audioFile playback being completed.
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: recievedAudio.filePathURL)
        let audioFormat = audioFile.fileFormat
        let audioCount = UInt32(audioFile.length)
        audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: audioCount)

        
        // Set up audioPlayer
        audioPlayer = try! AVAudioPlayer(contentsOfURL: recievedAudio.filePathURL)
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //Scale Background Image to fit.
        let bgImg = UIImage(named: "BackgroundGradientBlackGrey")
        let imgView = UIImageView(frame: self.view.frame)
        imgView.image = bgImg
        self.view.addSubview(imgView)
        self.view.sendSubviewToBack(imgView)
        
        //Set image used for selected images.
        ChipButton.setImage(UIImage(named: "Chipmunk2Active"), forState: .Selected)
        DarthButton.setImage(UIImage(named: "DarthVader2Active"), forState: .Selected)
        FastButton.setImage(UIImage(named: "FastSpeed2Active"), forState: .Selected)
        SlowButton.setImage(UIImage(named: "SlowSpeed2Active"), forState: .Selected)
        buttons = [ChipButton, FastButton, DarthButton, SlowButton]
        
        stopButton.hidden = true
        stopButton.enabled = false
        
        //Set up Rate/Pitch Labels.
        let labelColor: UIColor = UIColor(red: CGFloat(77/255.0), green: CGFloat(77/255.0), blue: CGFloat(77/255.0), alpha: 1.0)
        rateDisplay.textColor = labelColor
        pitchDisplay.textColor = labelColor
        
        rateLabel.text = "Rate:"
        rateLabel.textColor = labelColor
        
        pitchLabel.text = "Pitch:"
        pitchLabel.textColor = labelColor
        
        //Set up Sliders
        rateSlider.setValue(1.00, animated: true)
        rateSlider.setMaximumTrackImage(sliderMaxImage, forState: .Normal)
        rateSlider.setMinimumTrackImage(sliderMinImage, forState: .Normal)
        rateSlider.setThumbImage(sliderThumbImage, forState: .Normal)
        
        pitchSlider.setValue(0, animated: true)
        pitchSlider.setMaximumTrackImage(sliderMaxImage, forState: .Normal)
        pitchSlider.setMinimumTrackImage(sliderMinImage, forState: .Normal)
        pitchSlider.setThumbImage(sliderThumbImage, forState: .Normal)
        
        rateDisplay.text = String(NSString(format: "%.00f%%", rateSlider.value * 100))
        pitchDisplay.text = String(NSString(format: "%.00f", pitchSlider.value / 100))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    //Slider Change Functions.

    @IBAction func pitchChange(sender: UISlider) {
        pitchDisplay.text = String(NSString(format: "%.00f", sender.value / 100))
    }

    @IBAction func rateChange(sender: UISlider) {
        rateDisplay.text = String(NSString(format: "%.00f%%", sender.value * 100))
        if audioPlayer.playing {
            audioPlayer.rate = sender.value
        }
    }

    
    //AUDIO BUTTONS

    @IBAction func SlowButton(sender: UIButton) {
        print("Attempting Slow.")
        resetButtons()
        variableSpeed(0.5)
        resetAndPlayAudio()
        sender.selected = true
    }

    @IBAction func FastButton(sender: UIButton) {
        print("Attempting Fast.")
        resetButtons()
        variableSpeed(1.5)
        resetAndPlayAudio()
        sender.selected = true
    }
    
    @IBAction func StopAudio(sender: UIButton) {
        print("Stop button engaged.")
        audioPlayer.stop()
        
        audioEngine.stop()
        audioEngine.reset()
        
        enablePlayButton()
    }
    
    @IBAction func PlayAtRate(sender: UIButton) {
        print("Attempting Cominbation.")
        PlaySoundsWithVariables(pitchSlider.value, rate: rateSlider.value)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        resetButtons()
        print("Attempting chipmunk.")
        pitchSlider.value = 1000
        PlaySoundsWithVariables(1000, rate: 1.0)
        sender.selected = true
    }

    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        resetButtons()
        print("Attempting Darth Vader.")
        pitchSlider.value = -1000
        PlaySoundsWithVariables(-1000, rate: 1.0)
        sender.selected = true
    }
    
    
    // AUDIO FUNCTIONS
    
    func PlaySoundsWithVariables(pitch: Float, rate: Float) {
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        rateSlider.setValue(rate, animated: true)
        pitchSlider.setValue(pitch, animated: true)
        rateDisplay.text = String(NSString(format: "%.00f%%", rateSlider.value * 100))
        pitchDisplay.text = String(NSString(format: "%.00f", pitchSlider.value / 100))
        
        enableStopButton()
        
        let audioPlayerNode = AVAudioPlayerNode()
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        pitchEffect.rate = rate
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(pitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        print("Audio Engine started")
        
        audioPlayerNode.play()
        audioPlayerNode.scheduleBuffer(audioBuffer, completionHandler: resetPlayAndStopButtons)
    }
    
    func variableSpeed(x: Float) {
        rateSlider.setValue(x, animated: true)
        audioPlayer.rate = x
        rateDisplay.text = String(format: "%.2f", x)
    }
    
    func resetAndPlayAudio() {
        audioEngine.stop()
        audioEngine.reset()
        
        pitchSlider.setValue(0, animated: true)
        pitchDisplay.text = String(NSString(format: "%.00f", pitchSlider.value / 100))
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.play()
        
        enableStopButton()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            resetPlayAndStopButtons()
        } else {
            print("Error with audio playback")
        }
    }
    
    
    func resetPlayAndStopButtons() {
        print("Reset Called")
        if !audioPlayer.playing && !audioEngine.running {
            dispatch_async(dispatch_get_main_queue()) {
                print("dispatch called")
                self.enablePlayButton()
                self.resetButtons()
            }
        }
    }
    
    func resetButtons() {
        for x in buttons {
            if x.selected {
                x.selected = false
            }
        }
    }
    
    func enablePlayButton() {
        stopButton.hidden = true
        stopButton.enabled = false
        
        playButton.hidden = false
        playButton.enabled = true
    }
    
    func enableStopButton() {
        stopButton.hidden = false
        stopButton.enabled = true
        
        playButton.hidden = true
        playButton.enabled = false
    }

}
