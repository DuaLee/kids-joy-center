//
//  SortingGame.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/25/22.
//

import UIKit

class SortingGame: UIViewController {
    
    var difficulty: Int = -1
    
    var scoreLabel: UILabel = UILabel()
    var score: Int = 0
    
    var started: Bool = false
    
    var moved: Bool = false
    var startingLocation: CGPoint = CGPoint()
    
    var timerLabel: UILabel = UILabel()
    var timer: Timer!
    var remainingTime: Int = 0
    
    var numItems: Int = 0
    var numMatched: Int = 0
    
    //var panGesture = UIPanGestureRecognizer()
    
    let backgroundImage: UIImage = UIImage(named: "sortingBackground")!
    var backgroundImageView: UIImageView = UIImageView()
    
    let subviewAir = UIView()
    let subviewWater = UIView()
    let subviewLand = UIView()
    
    var landImageSource: [String] = ["🚗", "🚌", "🚓", "🚑", "🚒", "🚲", "🛵", "🛺"]
    var waterImageSource: [String] = ["⛵️", "🛶", "🚤", "🛥"]
    var airImageSource: [String] = ["🛩", "🚀", "🚁", "🛰", "🛸"]
    
    var imageArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
    }
    
    func drawScore() {
        scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 50, y: 150, width: -200, height: 32))
        
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
            remainingTime = 1 * 60 //1 minute
        case 1:
            remainingTime = Int(0.75 * 60) //0.75 minutes
        case 2:
            remainingTime = Int(0.5 * 60) //0.5 minutes
        default:
            break
        }
        
        timerLabel = UILabel(frame: CGRect(x: 50, y: 150, width: 100, height: 32))
        
        timerLabel.text = "\(remainingTime)"
        timerLabel.font = .systemFont(ofSize: 32)
        timerLabel.textAlignment = .left
        
        self.view.addSubview(timerLabel)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stepTimer), userInfo: nil, repeats: true)
    }
    
    @objc func stepTimer() {
        if remainingTime > 0 && numMatched < numItems {
            remainingTime -= 1
        } else {
            timer.invalidate()
            
            self.performSegue(withIdentifier: "highScoreSegue", sender: self)
        }
        
        timerLabel.text = "\(remainingTime)"
    }
    
    func drawBackground() {
        let imageView = UIImageView(image: backgroundImage)
        
        imageView.frame = CGRect(x: 0, y: 228, width: self.view.bounds.width, height: self.view.bounds.height - 228)
        
        view.addSubview(imageView)
    }
    
    var helpLabel: UILabel!
    
    func drawHelpLabel() {
        helpLabel = UILabel(frame: CGRect(x: 0, y: 64, width: 500, height: 32))
        
        helpLabel.text = "Drag the vehicles to the correct spot!"
        helpLabel.font = .systemFont(ofSize: 24)
        helpLabel.textAlignment = .center
        helpLabel.alpha = 1
        
        helpLabel.center.x = view.center.x
        
        view.addSubview(helpLabel)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn, .repeat, .autoreverse], animations: {
            self.helpLabel.alpha = 0.2
            self.helpLabel.center.y = self.helpLabel.center.y + 20
        }, completion: nil)
    }
    
    func drawItems() {
        numItems = 8 + difficulty * 2
        
        let height: CGFloat = 50
        //let width = self.view.frame.width / CGFloat(numCol)
        let width = height
        
        var imageSource: [String] = []
        imageSource.append(contentsOf: landImageSource)
        imageSource.append(contentsOf: waterImageSource)
        imageSource.append(contentsOf: airImageSource)
        
        imageSource.shuffle()
        
        for index in 0..<numItems {
            imageArray.append(imageSource[index])
        }
        
        imageArray.shuffle()
        
        var count = 200
        for i in 0..<numItems {
            let subview = UILabel(frame: CGRect(x: 150 + (width + 4) * CGFloat(i), y: 138, width: width, height: height))
            
            subview.text = imageArray[i]
            subview.font = .systemFont(ofSize: height - 5)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(iconDragged))
            
            subview.isUserInteractionEnabled = true
            subview.addGestureRecognizer(panGesture)
            
            subview.tag = count
            self.view.addSubview(subview)
            
            count += 1
        }
    }
    
    func drawSensors() {
        subviewAir.frame = CGRect(x: 0, y: 228, width: self.view.bounds.width, height: 154)
        subviewWater.frame = CGRect(x: 0, y: 382, width: self.view.bounds.width, height: 215)
        subviewLand.frame = CGRect(x: 0, y: 597, width: self.view.bounds.width, height: 171)
        
//        subviewAir.backgroundColor = .red
//        subviewWater.backgroundColor = .blue
//        subviewLand.backgroundColor = .black
        
        view.addSubview(subviewAir)
        view.addSubview(subviewWater)
        view.addSubview(subviewLand)
    }
    
    var previousFoundTime: Int = -1
    
    func calculateScore() -> Int {
        if previousFoundTime == -1 {
            previousFoundTime = remainingTime
        }
        
        var score: Int = 0
        let timeElapsed: Int = previousFoundTime - remainingTime - 1
        
        if timeElapsed < 2 {
            score = 5
        } else if timeElapsed <= 4 {
            score = 4
        } else {
            score = 3
        }
        
        previousFoundTime = remainingTime
        return score
    }
    
    @objc func iconDragged(sender: UIPanGestureRecognizer) {
        if !started {
            startTimer()
            helpLabel.removeFromSuperview()
            
            started = true
        }
        
        if !moved {
            startingLocation = sender.view!.center
            //print(startingLocation)
            moved = true
        }
        
        self.view.bringSubviewToFront(sender.view!)
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let senderLabel = sender.view! as! UILabel
        
        if (sender.state == UIGestureRecognizer.State.began) {
            sender.view!.frame.size.width *= 2
            sender.view!.frame.size.height *= 2
            senderLabel.font = .systemFont(ofSize: senderLabel.font.pointSize * 2)
            
            GSAudio.sharedInstance.playSound(soundFileName: "pickup")
        } else if (sender.state == UIGestureRecognizer.State.ended) {
            sender.view!.frame.size.width /= 2
            sender.view!.frame.size.height /= 2
            senderLabel.font = .systemFont(ofSize: senderLabel.font.pointSize / 2)
            
            var isMatched = false
            
            if sender.view!.frame.intersects(subviewAir.frame) && airImageSource.contains(senderLabel.text!) {
                sender.view!.isUserInteractionEnabled = false
                
                isMatched = true
            } else if sender.view!.frame.intersects(subviewWater.frame) && waterImageSource.contains(senderLabel.text!) {
                sender.view!.isUserInteractionEnabled = false
                
                isMatched = true
            } else if sender.view!.frame.intersects(subviewLand.frame) && landImageSource.contains(senderLabel.text!) {
                sender.view!.isUserInteractionEnabled = false
                
                isMatched = true
            } else {
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                    sender.view!.center = self.startingLocation
                })
            }
            
            moved = false
            
            if (isMatched) {
                numMatched += 1
                
                let scoreTobeAdded = calculateScore()
                let animationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 32))
                animationLabel.text = "+\(scoreTobeAdded)"
                animationLabel.font = .systemFont(ofSize: 32)
                animationLabel.textAlignment = .center
                animationLabel.alpha = 0
                
                animationLabel.center.x = scoreLabel.center.x + 81
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
                
                GSAudio.sharedInstance.playSound(soundFileName: "place")
            } else {
                GSAudio.sharedInstance.playSound(soundFileName: "flip")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HighScores
        
        destinationVC.gameTitle = self.title ?? "Unknown"
        destinationVC.difficulty = difficulty
        
        if numMatched >= numItems {
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
        
        numMatched = 0
        
        started = false
        moved = false
        
        imageArray.removeAll()
        
        drawBackground()
        drawSensors()
        
        drawItems()
        drawScore()
        setupTimer()
        
        drawHelpLabel()
    }
    
    //prevent memory leak
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
    }
}
