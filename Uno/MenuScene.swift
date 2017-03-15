//
//  MenuScene.swift
//  Uno
//
//  Created by Andre Calfa on 3/10/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit
import AVFoundation
import UIKit

class MenuScene: SKScene, UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

	// we need to make sure to set this when we create our GameScene
	var viewController: GameViewController!
	
	var startButton = SKSpriteNode()
	let startButtonTex = SKTexture(imageNamed: "start_button")
	var player : AVAudioPlayer?
	
	let numberPlayersLabel = SKLabelNode(text: "Please select the number of players")
	var myPicker : UIPickerView?
	var myLabel: UILabel?
	let pickerData = ["2", "3", "4"]

	override func didMove(to view: SKView) {
		
		// Draw button
		startButton = SKSpriteNode(texture: startButtonTex)
		startButton.position = CGPoint(x: frame.midX, y: frame.midY)
		startButton.setScale(0.5)
		self.addChild(startButton)
		
		// Draw label
		numberPlayersLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
		self.addChild(numberPlayersLabel)
		
		// Draw picker
		myPicker = UIPickerView(frame: CGRect(x: view.bounds.width / 2 - 50, y: view.bounds.height / 2 - 100, width: 100, height: 60))
		myLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 50, height: 200))
        myLabel?.text = pickerData[0] // Set default value for label text
		myPicker?.delegate = self
		myPicker?.dataSource = self
		self.view!.addSubview(myPicker!)
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let pos = touch.location(in: self)
			let node = self.atPoint(pos)
			
			if node == startButton {
				if view != nil {
					// Get selected value in picker and set number of players
					viewController.numOfPlayers = Int((myLabel?.text)!)!
					// Initialize Players
					viewController.initPlayers()
					// Remove picker from view
					myPicker?.removeFromSuperview()
					
					// Play button click sound
					playSound()
					
					// Go to GameScene
					let transition:SKTransition = SKTransition.fade(withDuration: 1)
					let scene:SKScene = GameScene(size: self.size)
					self.view?.presentScene(scene, transition: transition)
				}
			}
		}
	}
	
	func playSound() {
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
	
	//MARK: - Delegates and data sources
	//MARK: Data Sources
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	//MARK: Delegates
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		myLabel?.text = pickerData[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let titleData = pickerData[row]
		let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blue])
		return myTitle
	}
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var pickerLabel = view as! UILabel!
		if view == nil {  //if no label there yet
			pickerLabel = UILabel()
			//color the label's background
			let hue = CGFloat(row)/CGFloat(pickerData.count)
			pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
		}
		let titleData = pickerData[row]
		let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.black])
		pickerLabel!.attributedText = myTitle
		pickerLabel!.textAlignment = .center
		
		return pickerLabel!
		
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 36.0
	}
	// for best use with multitasking , dont use a constant here.
	//this is for demonstration purposes only.
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		return 100
	}
}
