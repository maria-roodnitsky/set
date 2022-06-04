//
//  EmojiMemorizeViewModel.swift
//  Memorize
//
//  Created by Maria Roodnitsky on 4/6/22.
//

import SwiftUI

class SetViewModel: ObservableObject {
    
    private static func createSetModel() -> SetModel<String> {
        SetModel<String>() { pairIndex in
            return ""
        }
    }
    
    @Published private var model = createSetModel()
    
    var cards: Array<SetModel<String>.Card> {
        return model.cards
    }
    
    var score: Int {
        return model.score
    }
    
    var hand: Array<SetModel<String>.Card> {
        return model.hand
    }
    
    var discarded: Array<SetModel<String>.Card> {
        return model.discarded
    }
    
    var lastCard: Int {
        return model.lastCard
    }
    
    
    // MARK - Intents
    
    func choose(_ card: SetModel<String>.Card) {
        model.choose(card)
    }
    
    func addToHand() {
        model.addToHand()
    }

    func shuffle() {
        model.shuffle()
    }
    
    func newGame() {
        model = SetViewModel.createSetModel()
    }
}
