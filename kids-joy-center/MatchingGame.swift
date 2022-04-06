//
//  MatchingGame.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/25/22.
//

import UIKit

class MatchingGame: UIViewController {
    
    var difficulty: Int = -1
    
    var scoreLabel: UILabel = UILabel()
    var score: Int = 0
    
    var started: Bool = false
    
    var timerLabel: UILabel = UILabel()
    var timer: Timer!
    var remainingTime: Int = 0
    
    var selectedCard: Int = -1
    var cardSelected: Bool = false
    
    var numItems: Int = 0
    var numMatched: Int = 0
    
    var imageSource: [String] = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐵", "🐙", "🐷", "🐸"]
    
    var imageArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func drawScore() {
        scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 50, y: 250, width: -150, height: 32))
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = .boldSystemFont(ofSize: 32)
        scoreLabel.textAlignment = .right
        
        self.view.addSubview(scoreLabel)
    }
    
    func addScore(scoreToBeAdded: Int) {
        score += scoreToBeAdded
        scoreLabel.text = "Score: \(score)"
    }
    
    func setupTimer() {
        switch difficulty {
        case 0:
            remainingTime = 2 * 60 //2 minutes
        case 1:
            remainingTime = Int(1.75 * 60) //1.75 minutes
        case 2:
            remainingTime = Int(1.5 * 60) //1.5 minutes
        default:
            break
        }
        
        timerLabel = UILabel(frame: CGRect(x: self.view.frame.width - 50, y: 150, width: -200, height: 96))
        
        timerLabel.text = "\(remainingTime)"
        timerLabel.font = .systemFont(ofSize: 96)
        timerLabel.textAlignment = .right
        
        self.view.addSubview(timerLabel)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stepTimer), userInfo: nil, repeats: true)
    }
    
    @objc func stepTimer() {
        if remainingTime > 0 && numMatched < numItems / 2 {
            remainingTime -= 1
        } else {
            timer.invalidate()
            
            self.performSegue(withIdentifier: "highScoreSegue", sender: self)
        }
        
        timerLabel.text = "\(remainingTime)"
    }
    
    func drawGrid() {
        let numCol: Int = difficulty + 3
        numItems = numCol * 4
        
        let height = self.view.frame.height / 4 - 50
        //let width = self.view.frame.width / CGFloat(numCol)
        let width = height
        
        imageSource.shuffle()
        
        for index in 0..<numItems / 2 {
            imageArray.append(imageSource[index])
            imageArray.append(imageSource[index])
        }
        
        imageArray.shuffle()
        
        var count = 100
        for i in 0..<numCol {
            for j in 0..<4 {
                let subview = UIButton(frame: CGRect(x: 50 + width * CGFloat(i), y: 150 + height * CGFloat(j), width: width, height: height))
                
                subview.setTitle("✉️", for: .normal)
                subview.titleLabel?.font = .systemFont(ofSize: height - 5)
                
                subview.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
                
                subview.tag = count
                self.view.addSubview(subview)
                
                count += 1
            }
        }
    }
    
    var previousFoundTime: Int = -1
    
    func calculateScore() -> Int {
        if previousFoundTime == -1 {
            previousFoundTime = remainingTime
        }
        
        var score: Int = 0
        let timeElapsed: Int = previousFoundTime - remainingTime - 1
        
        if timeElapsed < 3 {
            score = 5
        } else if timeElapsed <= 7 {
            score = 4
        } else {
            score = 3
        }
        
        previousFoundTime = remainingTime
        return score
    }
    
    @objc func iconTapped(sender: UIButton) {
        if !started {
            startTimer()
            started = true
        }
        
        sender.isEnabled = false
        sender.setTitle(imageArray[sender.tag - 100], for: .normal)
        
//        print(sender.title(for: .normal), sender.tag)
        
        if cardSelected {
            let firstCard = self.view.viewWithTag(selectedCard) as! UIButton
            
            if sender.title(for: .normal) == firstCard.title(for: .normal) {
                selectedCard = -1
                numMatched += 1
                
                let scoreTobeAdded = calculateScore()
                let animationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 32))
                animationLabel.text = "+\(scoreTobeAdded)"
                animationLabel.font = .systemFont(ofSize: 32)
                animationLabel.textAlignment = .center
                animationLabel.alpha = 0
                
                animationLabel.center.x = scoreLabel.center.x + 56
                animationLabel.center.y = scoreLabel.center.y
                
                view.addSubview(animationLabel)
                view.bringSubviewToFront(animationLabel)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    animationLabel.center.y = animationLabel.center.y + 32
                    animationLabel.alpha = 1
                }, completion: { (finished: Bool) in
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                        animationLabel.alpha = 0
                    }, completion: { (finished: Bool) in
                        animationLabel.removeFromSuperview()
                    })
                })
                
                addScore(scoreToBeAdded: scoreTobeAdded)
                
                GSAudio.sharedInstance.playSound(soundFileName: "match")
            } else {
                self.view.isUserInteractionEnabled = false
                
                let when = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        sender.setTitle("✉️", for: .normal)
                    })
                    UIView.transition(with: firstCard, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        firstCard.setTitle("✉️", for: .normal)
                    })
                    
                    sender.isEnabled = true
                    firstCard.isEnabled = true
                    
                    self.view.isUserInteractionEnabled = true
                }
            }
            
            cardSelected = false
        } else {
            selectedCard = sender.tag
            cardSelected = true
        }
        
        GSAudio.sharedInstance.playSound(soundFileName: "flip")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HighScores
        
        destinationVC.gameTitle = self.title ?? "Unknown"
        destinationVC.difficulty = difficulty
        
        if numMatched >= numItems / 2 {
            destinationVC.didWin = true
            destinationVC.score = score
        } else {
            destinationVC.didWin = false
        }
        
        view.subviews.forEach({ $0.removeFromSuperview() })
        self.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        score = 0
        selectedCard = -1
        cardSelected = false
        
        numMatched = 0
        
        started = false
        
        imageArray.removeAll()
        
        previousFoundTime = -1
        drawGrid()
        drawScore()
        setupTimer()
    }
    
    //prevent memory leak
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
    }
}
