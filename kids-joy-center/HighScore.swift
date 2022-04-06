//
//  HighScore.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/29/22.
//

import Foundation

class HighScore: CustomStringConvertible {
    var title: String
    var difficulty: Int
    var score: Int
    var isRecent: Bool
    
    public var description: String { return "\(title) - \(difficultyString()) | Score: \(score)" }
    
    init(title: String, difficulty: Int, score: Int, isRecent: Bool) {
        self.title = title
        self.difficulty = difficulty
        self.score = score
        self.isRecent = isRecent
    }
    
    func difficultyString() -> String {
        switch difficulty {
        case 0:
            return "Easy"
        case 1:
            return "Normal"
        case 2:
            return "Hard"
        default:
            return "Unknown"
        }
    }
}
