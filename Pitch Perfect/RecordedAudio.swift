//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Jason Lemrond on 9/25/15.
//  Copyright © 2015 Jason Lemrond. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    
    var filePathURL: NSURL!
    var title: String!
    
    init(filePathURL: NSURL, title: String){
        self.filePathURL = filePathURL
        self.title = title
    }
}