//
//  SoundFX.swift
//  Uno
//
//  Created by Andre Calfa on 3/16/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation
import AVFoundation

class SoundFX {
    static var player : AVAudioPlayer?
    
    static func playButtonClickSound() {
        let url = Bundle.main.url(forResource: "Button", withExtension: "wav")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
