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
    
    @IBOutlet var slowButton:  UIButton!
    @IBOutlet var fastButton:  UIButton!
    @IBOutlet var darthButton: UIButton!
    @IBOutlet var chipButton:  UIButton!
    var buttons: [UIButton]?
    var activeButton: UIButton?
    
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var audioFile:   AVAudioFile!
    var audioBuffer: AVAudioPCMBuffer!
    
    @IBOutlet var rateSlider:  UISlider!
    @IBOutlet var pitchSlider: UISlider!

    @IBOutlet weak var playButton:   UIButton!
    @IBOutlet weak var stopButton:   UIButton!
    @IBOutlet weak var rateDisplay:  UILabel!
    @IBOutlet weak var rateLabel:    UILabel!
    @IBOutlet weak var pitchLabel:   UILabel!
    @IBOutlet weak var pitchDisplay: UILabel!

    
    // Load Images for Sliders.
    let sliderMinImage =   UIImage(named: "Slider_Min_GreyMinimalist")
    let sliderMaxImage =   UIImage(named: "Slider_Max_GreyMinimalist")
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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Scale Background Image to fit.
        let bgImg = UIImage(named: "BackgroundGradientBlackGrey")
        let imgView = UIImageView(frame: self.view.frame)
        imgView.image = bgImg
        self.view.addSubview(imgView)
        self.view.sendSubviewToBack(imgView)
        
        //Set images used for preset buttons.
        chipButton.setImage(UIImage(named: "Chipmunk2Active"), forState: .Selected)
        darthButton.setImage(UIImage(named: "DarthVader2Active"), forState: .Selected)
        fastButton.setImage(UIImage(named: "FastSpeed2Active"), forState: .Selected)
        slowButton.setImage(UIImage(named: "SlowSpeed2Active"), forState: .Selected)
        buttons = [chipButton, fastButton, darthButton, slowButton]
        
        //Establish stop button as hidden/not enabled.
        togglePlayButton(true)
        
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
        
        //Set label inital values.
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

    
    //Audio Buttons

    @IBAction func slowButton(sender: UIButton) {
        print("Attempting Slow.")
        variableSpeed(0.5)
        resetAndPlayAudio(sender)
    }

    @IBAction func fastButton(sender: UIButton) {
        print("Attempting Fast.")
        variableSpeed(1.5)
        resetAndPlayAudio(sender)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        print("Stop button engaged.")
        stopAudio()
        
        togglePlayButton(true)
    }
    
    @IBAction func playAtRate(sender: UIButton) {
        print("Attempting Cominbation.")
        PlaySoundsWithVariables(pitchSlider.value, rate: rateSlider.value)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        print("Attempting chipmunk.")
        pitchSlider.value = 1000
        PlaySoundsWithVariables(1000, rate: 1.0)
        resetButtons(sender)
    }

    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        print("Attempting Darth Vader.")
        pitchSlider.value = -1000
        PlaySoundsWithVariables(-1000, rate: 1.0)
        resetButtons(sender)
    }
    
    
    // AUDIO FUNCTIONS
    
    //Play sounds via Audio Engine.  Variable pitch and rate.
    func PlaySoundsWithVariables(pitch: Float, rate: Float) {
        
        //Stop Audio Player if it still playing.
        stopAudio()
        
        //Set up values for sliders.
        rateSlider.setValue(rate, animated: true)
        pitchSlider.setValue(pitch, animated: true)
        rateDisplay.text = String(NSString(format: "%.00f%%", rateSlider.value * 100))
        pitchDisplay.text = String(NSString(format: "%.00f", pitchSlider.value / 100))
        
        togglePlayButton(false)
        
        //Establish rate / pitch variables.
        let audioPlayerNode = AVAudioPlayerNode()
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        pitchEffect.rate = rate
        
        //Reset PlayerNode if running already.
        audioPlayerNode.stop()
        
        //Attach Audio Node to audioEngine/pitchEffect
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(pitchEffect)
        
        //Connect audioEngine to outputs/effects/
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: audioEngine.outputNode, format: nil)
        
        //Scheudle which file is to be played.  Start Engine/
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        print("Audio Engine started")
        
        audioPlayerNode.play()
        
        //Utilize buffer to establish when audio has completed to reset UI.
        audioPlayerNode.scheduleBuffer(audioBuffer) { () -> Void in
            //Establish total length of audioFile.
            let sampleTime = self.audioFile.length
            let sampleRate = self.audioFile.fileFormat.sampleRate
            let totalFrames: AVAudioTime = AVAudioTime(sampleTime: sampleTime,
                                                           atRate: sampleRate)
            
            //If audio engine is active, get last rendered sample frame.
            if let nodeTime: AVAudioTime = audioPlayerNode.lastRenderTime {
                let audioTime: AVAudioTime = audioPlayerNode.playerTimeForNodeTime(nodeTime)!
                
                //Reset UI if audio file has finished playing.
                if audioTime.sampleTime >= totalFrames.sampleTime {
                    self.resetAllButtons()
                }       // if audioTime.sampleTime...
            }           // if let nodeTime:...
        }               // audioPlayerNode.sche...
    }
    
    //Establish rate of playback for AVAudioPlayer.
    func variableSpeed(x: Float) {
        rateSlider.setValue(x, animated: true)
        audioPlayer.rate = x
        rateDisplay.text = String(format: "%.2f", x)
    }
    
    //Used to stop all audio and play via AVAuidoPlayer.
    func resetAndPlayAudio(button: UIButton?) {
        stopAudio()
        
        pitchSlider.setValue(0, animated: true)
        pitchDisplay.text = String(NSString(format: "%.00f", pitchSlider.value / 100))
        audioPlayer.play()
        
        togglePlayButton(false)
        resetButtons(button)
    }
    
    //Stops audio from both AVAudioPlayer and AVAudioEngine.
    func stopAudio() {
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }
    
    //Function called when audio player finishes.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            if !audioPlayer.playing && !audioEngine.running {
                resetAllButtons()
            } else {
                print("Reset UI not called, audio still playing")
            }
        } else {
            print("Error with audio playback")
        }
    }
    
    //Reset all UIButtons after audio has finished playing.
    func resetAllButtons() {
        print("Reset All Called.")
        //Dispatch used to reset UI otherwise UI does not refresh in time when method called.
        dispatch_async(dispatch_get_main_queue()) {
            self.togglePlayButton(true)
            self.resetButtons(nil)
        }
    }
    
    //Reset rate and pitch buttons to .Normal state.
    func resetButtons(active: UIButton?) {
        if active != nil {
            active!.selected = true
        }
        
        if let buttons = buttons {
            for x in buttons {
                if x != active {
                    if x.selected {
                        x.selected = false
                    }
                }
            }
        } else {
            print("Buttons Array not set")
        }
    }
    
    //Toggle Play and Stop Buttons.
    func togglePlayButton(enable: Bool) {
        stopButton.hidden = enable
        stopButton.enabled = !enable
        
        playButton.hidden = !enable
        playButton.enabled = enable
    }

}
