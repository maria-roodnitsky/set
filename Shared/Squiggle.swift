//
//  Squiggle.swift
//  Set
//
//  Created by Maria Roodnitsky on 6/3/22.
//

import SwiftUI

struct Squiggle: Shape{
    func path(in rect: CGRect) -> Path {
        
        // Based on: https://stackoverflow.com/questions/25387940/how-to-draw-a-perfect-squiggle-in-set-card-game-with-objective-c
        let startPoint = CGPoint(x: 76.5, y: 403.5)
        let curves = [ // to, cp1, cp2
            (CGPoint(x:  199.5, y: 295.5), CGPoint(x: 92.463, y: 380.439),
                                           CGPoint(x: 130.171, y: 327.357)),
            (CGPoint(x:  815.5, y: 351.5), CGPoint(x: 418.604, y: 194.822),
                                           CGPoint(x: 631.633, y: 454.052)),
            (CGPoint(x: 1010.5, y: 248.5), CGPoint(x: 844.515, y: 313.007),
                                           CGPoint(x: 937.865, y: 229.987)),
            (CGPoint(x: 1057.5, y: 276.5), CGPoint(x: 1035.564, y: 254.888),
                                           CGPoint(x: 1051.46, y: 270.444)),
            (CGPoint(x:  993.5, y: 665.5), CGPoint(x: 1134.423, y: 353.627),
                                           CGPoint(x: 1105.444, y: 556.041)),
            (CGPoint(x:  860.5, y: 742.5), CGPoint(x: 983.56, y: 675.219),
                                           CGPoint(x: 941.404, y: 715.067)),
            (CGPoint(x:  271.5, y: 728.5), CGPoint(x: 608.267, y: 828.077),
                                           CGPoint(x: 452.192, y: 632.571)),
            (CGPoint(x:  101.5, y: 803.5), CGPoint(x: 207.927, y: 762.251),
                                           CGPoint(x: 156.106, y: 824.214)),
            (CGPoint(x:   49.5, y: 745.5), CGPoint(x: 95.664, y: 801.286),
                                           CGPoint(x: 73.211, y: 791.836)),
            (startPoint, CGPoint(x: 1.465, y: 651.628),
                         CGPoint(x: 1.928, y: 511.233)),
        ]
        
        // Draw the squiggle
        var path = Path()
        path.move(to: startPoint)
        for (to, cp1, cp2) in curves {
            path.addCurve(to: to, control1: cp1, control2: cp2)
        }
        
        return Path(path.cgPath).scaled(for: rect)
    }
}

extension Path {
    func scaled(for rect: CGRect) -> Path {
        let scaleX = rect.width/boundingRect.width
        let scaleY = rect.height/boundingRect.height
        let scale = min(scaleX, scaleY)
        return applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}
