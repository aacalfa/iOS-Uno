//
//  MenuScene.swift
//  Uno
//
//  Created by Andre Calfa on 3/10/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit
import UIKit

class MenuScene: SKScene, UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    // we need to make sure to set this when we create our GameScene
    var viewController: GameViewController!
    
    var startButton = SKSpriteNode()
    let startButtonTex = SKTexture(imageNamed: "start_button")
    
    let numberPlayersLabel = SKLabelNode(text: "Please select the number of players")
    var myPicker : UIPickerView?
    var myLabel: UILabel?
    let pickerData = ["2": UIColor.red, "3": UIColor.green, "4": UIColor.cyan]
    let nonAIPlayerNameLabel = SKLabelNode(text: "Your name")
    let nonAIPlayerNameTextField = UITextField()

    override func didMove(to view: SKView) {
        
        // Draw button
        startButton = SKSpriteNode(texture: startButtonTex)
        startButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        startButton.setScale(0.5)
        self.addChild(startButton)
        
        // Draw label
        numberPlayersLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        self.addChild(numberPlayersLabel)
        
        // Draw picker
        myPicker = UIPickerView(frame: CGRect(x: view.bounds.width / 2 - 50, y: view.bounds.height / 2 - 100, width: 100, height: 60))
        myLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 50, height: 200))
        myLabel?.text = Array(pickerData.keys.sorted())[0] // Set default value for label text
        myPicker?.delegate = self
        myPicker?.dataSource = self
        self.view!.addSubview(myPicker!)
        
        // Draw name label
        nonAIPlayerNameLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(nonAIPlayerNameLabel)
        
        // Draw name textfield
        nonAIPlayerNameTextField.borderStyle = UITextBorderStyle.roundedRect
        nonAIPlayerNameTextField.frame = CGRect(x: frame.midX - numberPlayersLabel.frame.width / 4, y: frame.midY + 20, width: numberPlayersLabel.frame.width / 2, height: numberPlayersLabel.frame.height)
        nonAIPlayerNameTextField.textAlignment = .center
        self.view!.addSubview(nonAIPlayerNameTextField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == startButton {
                if view != nil {
                    // Set non-AI player's name if given
                    if !(nonAIPlayerNameTextField.text?.isEmpty)! {
                        viewController.nonAIPlayerName = nonAIPlayerNameTextField.text!
                    }
                    // Get selected value in picker and set number of players
                    viewController.numOfPlayers = Int((myLabel?.text)!)!
                    // Initialize Players
                    viewController.initPlayers()
                    // Remove picker from view
                    myPicker?.removeFromSuperview()
                    // Remove non-AI player's name textfield from view
                    nonAIPlayerNameTextField.removeFromSuperview()
                    
                    // Play button click sound
                    SoundFX.playButtonClickSound()
                    
                    // Go to GameScene
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let gameScene : GameScene = GameScene(size: self.size)
                    gameScene.viewController = viewController
                    viewController.gameScene = gameScene
                    self.view?.presentScene(gameScene, transition: transition)
                }
            }
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
        return Array(pickerData.keys.sorted())[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myLabel?.text = Array(pickerData.keys.sorted())[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = Array(pickerData.keys.sorted())[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blue])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            pickerLabel?.backgroundColor = pickerData[Array(pickerData.keys.sorted())[row]]
        }
        let titleData = Array(pickerData.keys.sorted())[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: 26.0)!,NSForegroundColorAttributeName:UIColor.black])
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
