//
//  PoppingGame.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/25/22.
//

import UIKit

class PoppingGame: UIViewController {
    
    var difficulty: Int = -1
    
    var scoreLabel: UILabel = UILabel()
    var score: Int = 0
    
    var started: Bool = false
    
    var timerLabel: UILabel = UILabel()
    var timer: Timer!
    var remainingTime: Int = 0
    var bonusRemainingTime: Int = 0
    var deathRemainingTime: Int = 0
    
    let backgroundImage: UIImage = UIImage(named: "poppingBackground")!
    var backgroundImageView: UIImageView = UIImageView()
    
    var colorPalette: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemMint, .systemBlue, .systemPurple, .systemPink, .systemCyan, .systemIndigo, .systemBrown]
    let bonusImage: String = "👑"
    let deathImage: String = "☠️"
    
    let numSpawnPoints: Int = 10
    let screenPadding: Float32 = 100
    var locations: [Int] = []
    
    var speedModifier: Double = 1
    
    let balloonWidth: Int = 75
    let balloonHeight: Int = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        bonusRemainingTime = Int.random(in: 20...25)
        deathRemainingTime = Int.random(in: 20...25)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stepTimer), userInfo: nil, repeats: true)
    }
    
    @objc func stepTimer() {
        if remainingTime > 0 {
            var isBonus = false
            var isDeath = false
            
            if bonusRemainingTime > 0 {
                bonusRemainingTime -= 1
            } else {
                bonusRemainingTime = Int.random(in: 20...25)
                isBonus = true
            }
        
            if deathRemainingTime > 0 {
                deathRemainingTime -= 1
            } else {
                deathRemainingTime = Int.random(in: 20...25)
                isDeath = true
            }
            
            drawBalloon(isBonus: isBonus, isDeath: isDeath)
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
    
    var startButton: UIButton!
    
    func drawStartButton() {
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        
        startButton.setTitle("Click to Start!", for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 32)
        startButton.tintColor = .white
        startButton.backgroundColor = .systemGreen
        startButton.layer.cornerRadius = 50
        
        startButton.center.x = view.center.x
        startButton.center.y = view.center.y
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        
        view.addSubview(startButton)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .repeat, .autoreverse], animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    @objc func startButtonPressed() {
        startButton.isUserInteractionEnabled = false
        
        GSAudio.sharedInstance.playSound(soundFileName: "whoosh")
        
        startTimer()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.startButton.alpha = 0.5
            self.startButton.frame.origin.y -= 20
        }, completion: { (finished: Bool) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.startButton.alpha = 0
                self.startButton.frame.origin.y += 500
            }, completion: { (finished: Bool) in
                self.startButton.removeFromSuperview()
            })
        })
    }
    
    func determineLocations() {
        let totalWidth: Int = Int(self.view.frame.width) - Int(screenPadding) * 2
        let spacing: Float32 = Float(totalWidth) / (Float32(numSpawnPoints) - 1)
        
        for index in 0..<numSpawnPoints {
            locations.append(Int(Float32(index) * spacing + screenPadding))
        }
    }
    
    func drawBalloon(isBonus: Bool, isDeath: Bool) {
        var locationsCopy: [Int] = locations
        locationsCopy.shuffle()
        
        let balloonsPerCycleRange: Int = difficulty + 1
        let balloonsPerCycle: Int = Int.random(in: 1...balloonsPerCycleRange)
        
        let pointRange: Int = difficulty * 2 + 5
        
        for _ in 0..<balloonsPerCycle {
            let image = UIImage(named: "balloon")
            let imageView = Balloon(image: image)
            
            imageView.frame = CGRect(x: 0, y: Int(self.view.frame.height) + balloonHeight, width: balloonWidth, height: balloonHeight)
            imageView.tintColor = colorPalette[Int.random(in: 0..<colorPalette.count)]
            imageView.center.x = CGFloat(locationsCopy[0])
            locationsCopy.remove(at: 0)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            label.text = "\(Int.random(in: 1...pointRange))"
            label.font = .boldSystemFont(ofSize: 32)
            label.textAlignment = .center
            label.backgroundColor = .white
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(balloonPopped))
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            
            imageView.addSubview(label)
            view.addSubview(imageView)

            label.center = imageView.convert(imageView.center, from: imageView.superview)
            
            UIView.animate(withDuration: TimeInterval((5 - self.difficulty) * 2) / self.speedModifier, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
                imageView.center = CGPoint(x: imageView.center.x, y: 228)
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseIn], animations: {
                    imageView.alpha = 0
                }, completion: { (finished: Bool) in
                    imageView.removeFromSuperview()
                })
            })
        }
        
        if (isBonus) {
            let image = UIImage(named: "balloon")
            let imageView = Balloon(image: image)
            
            imageView.frame = CGRect(x: 0, y: Int(self.view.frame.height) + balloonHeight, width: Int(Double(balloonWidth) * 0.75), height: Int(Double(balloonHeight) * 0.75))
            imageView.tintColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.00)
            imageView.center.x = CGFloat(locationsCopy[0])
            locationsCopy.remove(at: 0)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            label.text = bonusImage
            label.font = .boldSystemFont(ofSize: 32)
            label.textAlignment = .center
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(balloonPopped))
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            
            imageView.addSubview(label)
            view.addSubview(imageView)

            label.center = imageView.convert(imageView.center, from: imageView.superview)
            
            UIView.animate(withDuration: TimeInterval((5 - self.difficulty) * 2) / 1.5, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
                imageView.center = CGPoint(x: imageView.center.x, y: 228)
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseIn], animations: {
                    imageView.alpha = 0
                }, completion: { (finished: Bool) in
                    imageView.removeFromSuperview()
                })
            })
        }
        
        if (isDeath) {
            let image = UIImage(named: "balloon")
            let imageView = Balloon(image: image)
            
            imageView.frame = CGRect(x: 0, y: Int(self.view.frame.height) + balloonHeight, width: Int(Double(balloonWidth) * 1.5), height: Int(Double(balloonHeight) * 1.5))
            imageView.tintColor = .black
            imageView.center.x = CGFloat(locationsCopy[0])
            locationsCopy.remove(at: 0)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
            label.text = deathImage
            label.font = .boldSystemFont(ofSize: 48)
            label.textAlignment = .center
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(balloonPopped))
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            
            imageView.addSubview(label)
            view.addSubview(imageView)

            label.center = imageView.convert(imageView.center, from: imageView.superview)
            
            UIView.animate(withDuration: TimeInterval((5 - self.difficulty) * 2) / 0.5, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
                imageView.center = CGPoint(x: imageView.center.x, y: 228)
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseIn], animations: {
                    imageView.alpha = 0
                }, completion: { (finished: Bool) in
                    imageView.removeFromSuperview()
                })
            })
        }
    }
    
    @objc func balloonPopped(sender: UITapGestureRecognizer) {
        //sender.view?.removeFromSuperview()
        sender.view!.isUserInteractionEnabled = false
        
        let senderImage = sender.view! as! UIImageView
        senderImage.image = UIImage(named: "balloonPop")
        
        let senderLabel = sender.view!.subviews[0] as! UILabel
        
        if senderLabel.text == deathImage {
            view.isUserInteractionEnabled = false
            remainingTime = 999
            
            for subView in self.view.subviews {
                subView.layer.removeAllAnimations()
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
                    subView.alpha = 0
                    subView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: { (finished: Bool) in
                    subView.removeFromSuperview()
                })
            }
            
            //difficulty = -1
            
            score = -999
            scoreLabel.text = "Score: \(score)"
            
            GSAudio.sharedInstance.playSounds(soundFileNames: ["boom", "pop"])
            
            let explosionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            explosionImage.image = UIImage(named: "explosion")
            explosionImage.center.x = senderImage.center.x
            explosionImage.center.y = senderImage.center.y
            
            view.addSubview(explosionImage)
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                explosionImage.alpha = 0
                explosionImage.transform = CGAffineTransform(scaleX: 2000, y: 2000)
            }, completion: { (finished: Bool) in
                self.remainingTime = 0
                explosionImage.removeFromSuperview()
            })
        } else if senderLabel.text == bonusImage {
            speedModifier = 0.5
            
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.speedModifier = 1
            }
            
            GSAudio.sharedInstance.playSounds(soundFileNames: ["pop", "match"])
        } else {
            let animationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            animationLabel.text = senderLabel.text
            animationLabel.font = .boldSystemFont(ofSize: 32)
            animationLabel.textAlignment = .center
            animationLabel.backgroundColor = .white
            animationLabel.alpha = 0
            
            animationLabel.center = sender.location(in: self.view)
            
            view.addSubview(animationLabel)
            
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeLinear, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    animationLabel.center.x = self.scoreLabel.center.x + 80
                    animationLabel.center.y = self.scoreLabel.center.y
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                    animationLabel.alpha = 0.8
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: {
                    animationLabel.alpha = 0
                })
            }, completion: { (finished: Bool ) in
                animationLabel.removeFromSuperview()
            })
                                    
            addScore(scoreToBeAdded: Int(senderLabel.text!)!)
            
            GSAudio.sharedInstance.playSound(soundFileName: "pop")
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
            senderImage.alpha = 0
            senderImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { (finished: Bool) in
            senderImage.removeFromSuperview()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HighScores
        
        destinationVC.gameTitle = self.title ?? "Unknown"
        
        if score > 0 {
            destinationVC.didWin = true
            destinationVC.difficulty = difficulty
            destinationVC.score = score
        } else {
            destinationVC.didWin = false
        }
        
        view.subviews.forEach({ $0.removeFromSuperview() })
        self.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        score = 0
        speedModifier = 1
        
        started = false
        
        drawBackground()
        determineLocations()
        
        drawScore()
        setupTimer()
        drawStartButton()
        
        view.isUserInteractionEnabled = true
    }
    
    //prevent memory leak
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
    }
}
