# iOS-Uno
UNO game for iOS

[![Build Status](https://travis-ci.org/aacalfa/iOS-Uno.svg?branch=master)](https://travis-ci.org/aacalfa/iOS-Uno)

Currently ongoing Uno game project for iOS. All required functionalities for the game have already been implemented, although a few enhancements can be added and a few glitches have to be addressed. Rules for this game are based from [Wikipedia](https://en.wikipedia.org/wiki/Uno_(card_game)).

## How to play

### Menu Screen
Upon starting the app, the user will be presented with the menu screen, which looks like this:

![Alt text](http://image.prntscr.com/image/09c5b8e0ee1940d79ea8aebf52841da8.png "Menu screen")

Here you can optionally enter your name (if you choose not to, your name will be set to "Me"), and select how many players (up to 4) by swiping up or down in the picker. When you are ready, just tap the start button.

### Game play
After tapping the start button, the play scene is loaded, where you will be able to see your cards, your opponents' cards (flipped down of course :P), and the discard (right) and draw pile(left) at the center of the table. Additionaly, on the top right corner it is displayed who is currently playing, and in case there are more than two players in the game, you can see at the top left corner the current play orientation (clockwise or counter clockwise)

![Alt text](http://image.prntscr.com/image/68330e7b480d47139b232a3e386a68ff.png "Start of game")

The flow of play is very straightforward. Once it is your turn to play, you have two options: if you have any cards in your hand that can be played, simply tap on the card and it will be moved from your hand to the discard pile. If you don't have any playable cards or you prefer to draw a card instead, tap on the draw pile and the top card from it will be moved to your hand.

If you decide to draw a card and this card happens to be playable, the card will be flipped so that you can see its value and a message will be shown in the screen asking if you wish to play it or not. Just tap on the button of your choice:

![Alt text](http://image.prntscr.com/image/a2e3308970324b079240df658d67d606.png "Drawing a playable card")

If the card drawn cannot be played, it will be automatically moved to your hand.

#### Wild cards

When playing a wild card, you must choose which color shall be played next. For this, a picker will be shown in the screen, so you can swipe up or down to choose the desired color. Once you have decided on the color, just tap the "Choose button".

![Alt text](http://image.prntscr.com/image/a7a61b247336422494fab5ead41cde75.png "Playing a wild card")

#### End of game
The first player who runs out of cards wins the game. Once that happens, an alert popup will be shown and you can choose between starting the next round, or starting over from the beginning (points will be reset).
