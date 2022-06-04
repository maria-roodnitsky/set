//
//  SetModel.swift
//  Set
//
//  Created by Maria Roodnitsky on 4/6/22.
//

import Foundation
import SwiftUI

struct SetModel<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    private var indexOfFaceUpCard: Int? {
        get { cards.indices.filter( {cards[$0].isSelected}).oneAndOnly }
        set { cards.indices.forEach {cards[$0].isSelected = ($0 == newValue)} }
    }
    private(set) var score: Int = 0
    private(set) var hand: Array<Card>
    private(set) var discarded: Array<Card>
    
    private(set) var selection: Array<Card>
    private(set) var lastCard = 11
    
    
    mutating func choose(_ card: Card) {
        let thiscard = hand.firstIndex(where: {$0.id == card.id})
        
        if !hand[thiscard!].isSelected, selection.count < 3 {
            hand[thiscard!].isSelected = true
            addToSelection(card)
            if selection.count == 3 {
                // check color
                var colorMatch = false
                if ((selection[0].color == selection[1].color) &&
                    (selection[1].color == selection[2].color) && 
                    (selection[0].color == selection[2].color)) ||
                    ((selection[0].color != selection[1].color) &&
                        (selection[1].color != selection[2].color) &&
                        (selection[0].color != selection[2].color)){
                    colorMatch = true
                }
                // check opacity
                var opacityMatch = false
                if ((selection[0].opacity == selection[1].opacity) &&
                    (selection[1].opacity == selection[2].opacity) &&
                    (selection[0].opacity == selection[2].opacity)) ||
                    ((selection[0].opacity != selection[1].opacity) &&
                        (selection[1].opacity != selection[2].opacity) &&
                        (selection[0].opacity != selection[2].opacity)){
                    opacityMatch = true
                }
                // check shape
                var shapeMatch = false
                if ((selection[0].shape == selection[1].shape) &&
                    (selection[1].shape == selection[2].shape) &&
                    (selection[0].shape == selection[2].shape)) ||
                    ((selection[0].shape != selection[1].shape) &&
                        (selection[1].shape != selection[2].shape) &&
                        (selection[0].shape != selection[2].shape)){
                    shapeMatch = true
                }
                // check count
                var countMatch = false
                if ((selection[0].multiple == selection[1].multiple) &&
                    (selection[1].multiple == selection[2].multiple) &&
                    (selection[0].multiple == selection[2].multiple)) ||
                    ((selection[0].multiple != selection[1].multiple) &&
                        (selection[1].multiple != selection[2].multiple) &&
                        (selection[0].multiple != selection[2].multiple)){
                    countMatch = true
                }
                if countMatch, shapeMatch, opacityMatch, colorMatch {
                    for selectedCard in selection {
                        if let handIndex = hand.firstIndex(where: {$0.id == selectedCard.id}) {
                            if let selectionIndex = selection.firstIndex(where: {$0.id == selectedCard.id}) {
                                var thisCard = hand[handIndex]
                                thisCard.isDiscarded = true
                                thisCard.color = Color.pink
                                thisCard.isMatched = true
                                hand.remove(at: handIndex)
                                selection.remove(at: selectionIndex)
                                discarded.append(thisCard)
                            }
                        }
                    }
                } else {
                    for selectedCard in selection {
                        if let handIndex = hand.firstIndex(where: {$0.id == selectedCard.id}) {
                            var thisCard = hand[handIndex]
                            hand[handIndex].unMatched = true
                        }
                    }
                }
            }
        } else {
            removeFromSelection(card)
            hand[thiscard!].isSelected = false
            hand[thiscard!].unMatched = false
            for selectedCard in selection {
                if let handIndex = hand.firstIndex(where: {$0.id == selectedCard.id}) {
                    var thisCard = hand[handIndex]
                    hand[handIndex].unMatched = false
                }
            }
        }
    }
    
    mutating func addToSelection(_ card: Card) {
        selection.append(card)
    }

    mutating func addToHand() {
        if ((lastCard) < 81 && hand.count < 36) {
            hand.append(cards[lastCard])
            lastCard = lastCard + 1
        }
    }
    
    mutating func removeFromSelection(_ card: Card) {
        if let chosenIndex = selection.firstIndex(where: {$0.id == card.id}) {
            selection.remove(at: chosenIndex)
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    
    init(createCardContent: (Int) -> CardContent?) {
        cards = []
        hand = []
        discarded = []
        selection = []
        var cardIndex = 0
        
        for opacity in [0, 0.5, 1] {
            for shape in [ShapeType.diamond, ShapeType.oval, ShapeType.squiggle] {
                for color in [Color.red, Color.blue, Color.green] {
                    for multiple in [1, 2, 3] {
                        // a function is passed in that creates the content for the card
                        if let content = createCardContent(cardIndex) {
                            cards.append(Card(isSelected: false, isMatched: false, seen: false, shape:shape, opacity: Float(opacity), color: color, multiple: multiple, content: content, id: cardIndex))
                            cardIndex += 1
                        }
                    }
                }
            }
        }
    
        cards.shuffle()
        hand = Array(cards[0..<lastCard])
    }
    
    struct Card: Identifiable, Equatable {
        var isSelected = false {
            didSet {
                if isSelected {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }

        var unMatched = false
        var isDiscarded = false
        var seen = false
        let shape: ShapeType
        let opacity: Float
        var color: Color
        let multiple: Int
        let content: CardContent
        let id: Int
        
        // MARK: - Bonus Time
        
        // this could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up
        
        // can be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        // the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        // whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isSelected && !isMatched && bonusTimeRemaining > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}

extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}

enum ShapeType {
    case oval, diamond, squiggle
}
