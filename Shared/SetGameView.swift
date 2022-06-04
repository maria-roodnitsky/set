//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Maria Roodnitsky on 3/30/22.
//

import SwiftUI

let BUTTON_HEIGHT: CGFloat = 65.0

struct SetGameView: View {

    @ObservedObject var game: SetViewModel
    @Namespace private var dealingNamespace
    @State private var dealt = Set<Int>()
    
    // views
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Text("Set")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
//                HStack{
//                    Text("Score: \(game.score)")
//                }
                gameBody
                HStack{
                    newGameButton
                    Spacer()
                    shuffleButton
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.hand, aspectRatio: 2/3) { card in
            if isUndealt(card) || (card.isMatched && !card.isSelected) {
                Color.clear // makes a rectangle with clear color
            }
            else if card.isSelected {
                CardView(card: card)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .padding(4)
                .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                .zIndex(zIndex(of: card))
                .onTapGesture {
                    withAnimation{
                        game.choose(card)
                    }
                }
            } else {
                CardView(card: card)
                    .foregroundColor(card.color)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation{
                            game.choose(card)
                        }
                    }
                }
        }
    }
        
    var newGameButton: some View {
        Button(action: {
                withAnimation {
                    dealt = []
                    game.newGame()
                }
            }, label: { Text("New Game") })
    }
    
    var shuffleButton: some View {
        Button(action: { withAnimation { game.shuffle() } }, label: { Text("Shuffle") })
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }.frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
            game.addToHand()
            for card in game.hand {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    // functions for UI
    
    private func deal(_ card: SetModel<String>.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: SetModel<String>.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: SetModel<String>.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: SetModel<String>.Card) -> Double {
        -Double(game.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }
}

struct CardView: View {
    let card: SetModel<String>.Card
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360 - 90)).padding(5).opacity(0.0)
                            .onAppear{
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - card.bonusTimeRemaining) * 360 - 90)).padding(5).opacity(0.0)
                    }
                }
                .padding(5)
                .opacity(0.5)
                VStack {
                    ForEach(1...card.multiple, id: \.self) { i in
                        switch card.shape {
                        case .oval:
                                Capsule().strokeBorder(card.color, lineWidth: 3)
                                .background(Capsule().fill(card.color).opacity(Double(card.opacity)))
                        case .diamond:
                            Diamond().stroke(card.color, lineWidth: 3)
                                .background(Diamond().fill(card.color).opacity(Double(card.opacity)))
                        case .squiggle:
                            ZStack {
                            Squiggle().stroke(card.color, lineWidth: 3)
                                .background(Squiggle().fill(card.color).opacity(Double(card.opacity)))
                                .offset(y: -10)
                            }
                        }
                    }
                        .frame(width: geometry.size.width - 30, height: (geometry.size.height - 40) / 3)
                }.padding(10)
                }
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.easeInOut)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
        .cardify(isFaceUp: true, isSelected: card.isSelected, cardColor: card.color)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.5
        static let fontSize: CGFloat = 32
    }


struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SetViewModel()
        SetGameView(game: viewModel)
    }
}
