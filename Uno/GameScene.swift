//
//  GameScene.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    var background = SKSpriteNode(imageNamed: "Table") // sprite for table texture
    var viewController: GameViewController!
    
    var cardPositions: [CGPoint] = [] // Location of cards
    
    var playDirection = SKSpriteNode(imageNamed: "Clockwise") // Show if play is clockwise or anti-clockwise
    let invalidPlayLabel = SKLabelNode(text: "Invalid play!")
    var currPlayerLabel = SKLabelNode(text: "")
    var wildChosenColorLabel = SKLabelNode(text: "")
    var playerNames: [SKLabelNode] = [] // Labels for players' names
    
    // picker attributes related to color picker used when
    // human player plays a wild card and has to select a color
    var colorPicker : UIPickerView?
    var myLabel: UILabel?
    let pickerData = ["Red": UIColor.red, "Green": UIColor.green, "Blue": UIColor.cyan, "Yellow": UIColor.yellow]
    var colorChoiceButton = UIButton()
    var cardHackBecauseOBJCIsShit: Card?
    var fromCardDeckHackBecauseOBJCIsShit: Bool?
    
    // Buttons shown when human player draws a card that is playable,
    // so he can decide whether to play it or not
    var playYesButton = UIButton()
    var playNoButton = UIButton()
    var decidedToPlay: Bool = false // decision made by player whether to use card or not
    var playerAndCard: (Player, Card)?
    
    override func didMove(to view: SKView) {
        // Draw backgorund
        addChild(background)
        
        // Define where to place cards on screen
        setCardLocations()
        
        // Draw players cards
        var cardPosIdx = 0
        let playersVec = viewController.playersVec
        for player in playersVec {
            drawPlayerCards(player: player, cardPosIdx: cardPosIdx)
            cardPosIdx += 1
        }
        
        // Draw labels for players' names
        drawPlayersNames()
        
        // Draw label for current player
        drawCurrentPlayerLabel()
        
        // Draw discard pile
        drawTopDiscardPileCard()
        
        // Draw card deck
        drawTopDrawDeckCard()
        
        // Draw playDirection node, but only if number of players > 2
        if viewController.numOfPlayers > 2 {
            drawPlayDirection()
        }
        
        // Initialize properties of invalid play label and make it hidden
        invalidPlayLabel.fontSize = 13
        invalidPlayLabel.fontName = "AvenirNext-Bold"
        let topDiscardPileCard = viewController.currentCard
        invalidPlayLabel.position = CGPoint(x: (topDiscardPileCard?.position.x)!, y: (topDiscardPileCard?.position.y)! - (topDiscardPileCard?.size.height)!)
        invalidPlayLabel.isHidden = true
        background.addChild(invalidPlayLabel)
    }
    
    func drawPlayerCards(player: Player?, cardPosIdx: Int) {
        let cards = player?.getCards()
        var xPos = cardPositions[cardPosIdx].x
        var yPos = cardPositions[cardPosIdx].y
        
        for card in cards! {
            // If cards currently exist, remove them so they'll get rearranged
            card?.removeFromParent()
            
            card?.position = CGPoint(x: xPos, y: yPos)
            card?.setScale(0.2)
            // Draw frontTexture if it's human player, otherwise draw backTexture
            card?.texture = (player?.isAI())! ? card?.backTexture : card?.frontTexture
            if cardPosIdx == 1 {
                card?.zRotation = CGFloat(M_PI)
            } else if cardPosIdx == 2 {
                card?.zRotation = CGFloat(-M_PI / 2)
            } else if cardPosIdx == 3 {
                card?.zRotation = CGFloat(M_PI / 2)
            }
            background.addChild(card!)
            
            // player 0 and 1 cards are distributed horizontally through the screen,
            // whereas players 2 and 3 cards are distributed vertically
            if cardPosIdx <= 1 {
                xPos += (card?.texture?.size().width)! / 6
            } else {
                yPos += (card?.texture?.size().width)! / 6
            }
            
        }
    }
    
    /// Draw label that informs the current player
    func drawCurrentPlayerLabel() {
        currPlayerLabel.removeFromParent()
        currPlayerLabel.position = CGPoint(x: size.width * 0.9, y: size.height * 0.94)
        currPlayerLabel.fontSize = 13
        currPlayerLabel.fontName = "AvenirNext-Bold"
        currPlayerLabel.text = (viewController.playerOrderOfPlay[viewController.currPlayerIdx]?.getName())! + "'s turn"
        background.addChild(currPlayerLabel)
    }
    
    /// Draw label that informs what color has been chose for wild card
    func drawWildChosenColorLabel() {
        // Make sure color picker and button are hidden
        colorPicker?.isHidden = true
        colorChoiceButton.isHidden = true
        
        let topDiscardPileCard = viewController.currentCard
        wildChosenColorLabel.removeFromParent()
        wildChosenColorLabel.position = CGPoint(x: (topDiscardPileCard?.position.x)!, y: (topDiscardPileCard?.position.y)! + (topDiscardPileCard?.size.height)!)
        wildChosenColorLabel.fontSize = 13
        wildChosenColorLabel.fontName = "AvenirNext-Bold"
        wildChosenColorLabel.fontColor = topDiscardPileCard?.colorAsUIColor()
        wildChosenColorLabel.text = "Chosen color is: " + (topDiscardPileCard?.colorAsString())!
        wildChosenColorLabel.isHidden = false
        background.addChild(wildChosenColorLabel)
    }
    
    /// Draw players' names labels
    func drawPlayersNames() {
        let playersVec = viewController.playersVec
        var i = 0
        for player in playersVec {
            let playerNameLabel = SKLabelNode(text: player?.getName())
            playerNameLabel.fontSize = 13
            playerNameLabel.fontName = "AvenirNext-Bold"
            var position = cardPositions[i]
            // fixMe: find a better way to set the position
            if i < 2 {
                position.x -= 60
            } else {
                position.y -= 60
            }
            playerNameLabel.position = position
            playerNames.append(playerNameLabel)
            background.addChild(playerNames[i])
            i += 1
        }
    }
    
    /// Draw sprite that shows if the order is clockwise or anticlockwise
    func drawPlayDirection() {
        playDirection.removeFromParent()
        playDirection.texture = viewController.isOrderClockwise ?
            SKTexture(imageNamed: "Clockwise") : SKTexture(imageNamed: "AntiClockwise")
        playDirection.position = CGPoint(x: size.width * 0.06, y: size.height * 0.94)
        playDirection.setScale(0.3)
        background.addChild(playDirection)
    }
    
    /// Draw card on top of discard pile
    func drawTopDiscardPileCard() {
        let topDiscardPileCard = viewController.currentCard
        topDiscardPileCard?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        topDiscardPileCard?.setScale(0.2)
        topDiscardPileCard?.texture = topDiscardPileCard?.frontTexture
        topDiscardPileCard?.zRotation = CGFloat(M_PI / 2)
        topDiscardPileCard?.removeFromParent()
        background.addChild(topDiscardPileCard!)
    }
    
    /// Draw card on top of draw deck
    func drawTopDrawDeckCard() {
        let topDrawDeckCard = viewController.cardDeck.peek()
        topDrawDeckCard?.position = CGPoint(x: self.size.width / 2 - (topDrawDeckCard?.size.width)! / 3, y: self.size.height / 2)
        topDrawDeckCard?.setScale(0.2)
        topDrawDeckCard?.texture = topDrawDeckCard?.backTexture
        topDrawDeckCard?.zRotation = CGFloat(M_PI / 2)
        topDrawDeckCard?.removeFromParent()
        background.addChild(topDrawDeckCard!)
    }
    
    /// Set card locations
    func setCardLocations() {
        let player1CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.1)
        let player2CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.89)
        let player3CardPosition = CGPoint(x: size.width * 0.06, y: size.height * 0.2)
        let player4CardPosition = CGPoint(x: size.width * 0.94, y: size.height * 0.2)
        cardPositions.append(player1CardPosition)
        cardPositions.append(player2CardPosition)
        cardPositions.append(player3CardPosition)
        cardPositions.append(player4CardPosition)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    /// Handles touches on the game scene UI
    ///
    /// - Parameters:
    ///   - touches: Reference to touches on the UI
    ///   - event: Reference to touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node is Card {
                let card = (node as? Card)!
                let player = viewController.playerOrderOfPlay[viewController.currPlayerIdx]!
                if !player.isAI() && player.hasCardObject(card: card) {
                    // Non-AI player attempts to play
                    NotificationCenter.default.post( name: Notification.Name("handlePlayerCardTouch"), object: ["player": player, "card": card])
                } else if node === viewController.cardDeck.peek() {
                    if !player.isAI() {
                        // Drawn card from deck
                        decidedToPlay = false
                        if viewController.isPlayValid(player: player, card: card) {
                            // show card and ask player if he/she wants to play card or keep it
                            card.texture = card.frontTexture
                            drawOptionalPlayButtons(player: player, card: card)
                        } else {
                            NotificationCenter.default.post( name: Notification.Name("handleDrawCardDeckTouch"), object: ["player": player, "card": card, "decidedToPlay": decidedToPlay])
                        }
                    }
                }
            }
        }
    }
    
    /// Animates the card being played by moving it to the discard player
    ///
    /// - Parameters:
    ///   - player: Player that's currently playing
    ///   - card: Card that will be moved
    func moveCardFromHandToDiscardPile(player: Player, card: Card) {
        card.texture = card.frontTexture
        let moveTo = viewController.currentCard?.position
        let move = SKAction.move(to: moveTo!, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandlePlayerCardTouch(player: player, card: card) })
    }
    
    /// Animates the card being moved from draw pile to player's hand
    ///
    /// - Parameters:
    ///   - player: Player who drew card
    ///   - cardPosIdx: Defines where to move the card to
    ///   - card: Card moved from draw pile
    func moveCardFromDrawToPlayerHand(player: Player, cardPosIdx: Int, card: Card) {
        self.invalidPlayLabel.isHidden = true
        card.texture = player.isAI() ? card.backTexture : card.frontTexture
        card.zRotation = 0
        let moveTo = cardPositions[cardPosIdx]
        let move = SKAction.move(to: moveTo, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandleDrawCardDeckTouch(player: player, card: card) })
    }
    
    /// Animates the card being moved from draw pile to discard pile
    ///
    /// - Parameters:
    ///   - player: Player who drew card
    ///   - cardPosIdx: Defines where to move the card to
    ///   - card: Card moved from draw pile
    func moveCardFromDrawToDiscardPile(player: Player, card: Card) {
        self.invalidPlayLabel.isHidden = true
        card.texture = card.frontTexture
        let moveTo = viewController.discardPile.peek()!.position
        let move = SKAction.move(to: moveTo, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandleDrawDeckPile(player: player, card: card) })
    }
    
    /// Animates the card being moved from draw pile to player's hand
    ///
    /// - Parameters:
    ///   - player: Player who drew card
    ///   - cardPosIdx: Defines where to move the card to
    ///   - card: Card moved from draw pile
    func moveCardFromDrawToPlayerHandDrawTwoOrFourAction(player: Player, cardPosIdx: Int, card1: Card, card2: Card, card3: Card? = nil, card4: Card? = nil) {
        self.invalidPlayLabel.isHidden = true
        card1.texture = player.isAI() ? card1.backTexture : card1.frontTexture
        card1.zRotation = 0
        card2.texture = player.isAI() ? card2.backTexture : card2.frontTexture
        card2.zRotation = 0
        let moveTo = cardPositions[cardPosIdx]
        let move = SKAction.move(to: moveTo, duration: 1)
        if card3 != nil && card4 != nil {
            card3!.texture = player.isAI() ? card3!.backTexture : card3!.frontTexture
            card3!.zRotation = 0
            card4!.texture = player.isAI() ? card4!.backTexture : card4!.frontTexture
            card4!.zRotation = 0
            
            card1.run(move, completion: { self.viewController.doFinishDrawTwoOrFourAction(player: player, card1: card1, card2: card2, card3: card3, card4: card4) })
        } else {
            card1.run(move, completion: { self.viewController.doFinishDrawTwoOrFourAction(player: player, card1: card1, card2: card2) })
        }
    }
  
    func drawOptionalPlayButtons(player: Player, card: Card) {
        playYesButton = UIButton(frame: CGRect(x: (view?.bounds.width)! / 2, y: (view?.bounds.height)! / 2 - 85, width: 100, height: 30))
        playYesButton.setTitle("Yes", for: .normal)
        playYesButton.titleLabel?.font = UIFont.init(name: "AvenirNext-Bold", size:13)
        playYesButton.setTitleColor(UIColor.white, for: .normal)
        playYesButton.backgroundColor = UIColor.green
        playYesButton.addTarget(self, action: #selector(self.playYesPressed), for: .touchUpInside)
        self.view!.addSubview(playYesButton)
        
        playNoButton = UIButton(frame: CGRect(x: (view?.bounds.width)! / 2 - 100, y: (view?.bounds.height)! / 2 - 85, width: 100, height: 30))
        playNoButton.setTitle("No", for: .normal)
        playNoButton.titleLabel?.font = UIFont.init(name: "AvenirNext-Bold", size:13)
        playNoButton.setTitleColor(UIColor.white, for: .normal)
        playNoButton.backgroundColor = UIColor.red
        playNoButton.addTarget(self, action: #selector(self.playNoPressed), for: .touchUpInside)
        self.view!.addSubview(playNoButton)
        playerAndCard = (player, card)
    }
    
    func playYesPressed() {
        playYesButton.removeFromSuperview()
        playNoButton.removeFromSuperview()
        decidedToPlay = true
        let player = playerAndCard?.0
        let card = playerAndCard?.1
        // first check if this is wild card, if yes, we have to ask the player what is the desired color
        if card?.cardType == CardType.wild {
            drawColorPicker(player: player!, card: card!, fromCardDeck: true)
            fromCardDeckHackBecauseOBJCIsShit = true
        } else {
            moveCardFromDrawToDiscardPile(player: player!, card: card!)
        }
    }
    
    func playNoPressed() {
        playYesButton.removeFromSuperview()
        playNoButton.removeFromSuperview()
        decidedToPlay = false
        let player = playerAndCard?.0
        let card = playerAndCard?.1
        NotificationCenter.default.post( name: Notification.Name("handleDrawCardDeckTouch"), object: ["player": player!, "card": card!, "decidedToPlay": decidedToPlay])
    }
    
    func drawColorPicker(player: Player, card: Card, fromCardDeck: Bool) {
        // Make sure wild chosen color label is hidden
        wildChosenColorLabel.isHidden = true
        
        // Draw picker
        colorPicker = UIPickerView(frame: CGRect(x: (view?.bounds.width)! / 2 - 110, y: (view?.bounds.height)! / 2 - 100, width: 100, height: 60))
        myLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 50, height: 200))
        myLabel?.text = Array(pickerData.keys.sorted())[0] // Set default value for label text
        myLabel?.font = UIFont.init(name: "AvenirNext-Bold", size:13)
        colorPicker?.delegate = self
        colorPicker?.dataSource = self
        self.view!.addSubview(colorPicker!)
        
        colorChoiceButton = UIButton(frame: CGRect(x: (view?.bounds.width)! / 2, y: (view?.bounds.height)! / 2 - 85, width: 100, height: 30))
        colorChoiceButton.setTitle("Choose", for: .normal)
        colorChoiceButton.titleLabel?.font = UIFont.init(name: "AvenirNext-Bold", size:13)
        colorChoiceButton.setTitleColor(UIColor.black, for: .normal)
        colorChoiceButton.backgroundColor = UIColor.white
        colorChoiceButton.addTarget(self, action: #selector(self.colorChoicePressed), for: .touchUpInside)
        self.view!.addSubview(colorChoiceButton)
        // hack to tell pressed what card is supposed to be moved
        cardHackBecauseOBJCIsShit = card
    }
    
    @objc func colorChoicePressed() {
        // Remove picker and button from view
        colorChoiceButton.removeFromSuperview()
        colorPicker?.removeFromSuperview()
        // Get value in color picker
        let chosenColor = myLabel?.text
        // Convert color string to CardColor
        let player = viewController.playerOrderOfPlay[viewController.currPlayerIdx]
        
        cardHackBecauseOBJCIsShit?.cardColor = Card.stringToCardColor(color: chosenColor!)
        
        // Check if the wild card played was drawn from deck
        if fromCardDeckHackBecauseOBJCIsShit == true {
            fromCardDeckHackBecauseOBJCIsShit = false
            moveCardFromDrawToDiscardPile(player: player!, card: cardHackBecauseOBJCIsShit!)
        } else {
            moveCardFromHandToDiscardPile(player: player!, card: cardHackBecauseOBJCIsShit!)
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
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: 13)!,NSForegroundColorAttributeName:UIColor.blue])
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
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: 13)!,NSForegroundColorAttributeName:UIColor.black])
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
