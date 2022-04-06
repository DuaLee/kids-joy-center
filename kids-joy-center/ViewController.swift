//
//  ViewController.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/25/22.
//

import UIKit

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var matchingButton: UIButton!
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var poppingButton: UIButton!
    
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var gameID: Int = -1
    var difficulty: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        easyButton.isEnabled = false
        normalButton.isEnabled = false
        hardButton.isEnabled = false
        
        playButton.isEnabled = false
    }
    
    
    @IBAction func gameButtonPressed(_ sender: UIButton) {
        GSAudio.sharedInstance.playSound(soundFileName: "marimbaC")
        
        matchingButton.isSelected = false
        sortingButton.isSelected = false
        poppingButton.isSelected = false
        matchingButton.alpha = 0.4
        sortingButton.alpha = 0.4
        poppingButton.alpha = 0.4
        
        sender.isSelected = true
        sender.alpha = 1
        
        easyButton.isEnabled = true
        normalButton.isEnabled = true
        hardButton.isEnabled = true
        easyButton.isSelected = false
        normalButton.isSelected = false
        hardButton.isSelected = false
        
        playButton.isEnabled = false
        
        gameID = sender.tag
    }
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        GSAudio.sharedInstance.playSound(soundFileName: "marimbaD")
        
        easyButton.isSelected = false
        normalButton.isSelected = false
        hardButton.isSelected = false
        
        switch sender.tag {
        case 11:
            sender.isSelected = true
            difficulty = 0
        case 12:
            sender.isSelected = true
            difficulty = 1
        case 13:
            sender.isSelected = true
            difficulty = 2
        default:
            break
        }
        
        playButton.isEnabled = true
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        GSAudio.sharedInstance.playSound(soundFileName: "marimbaE")
        
        if gameID > 0 && difficulty >= 0 {
            self.performSegue(withIdentifier: "game\(gameID)", sender: UIButton.self)
        } else { //debug just in case
            viewDidLoad()
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to clear all high scores?", message: "This action cannot be reversed.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            self.defaults.set([], forKey: "highScores")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch gameID {
        case 1:
            let destinationVC = segue.destination as! MatchingGame
            
            destinationVC.difficulty = difficulty
        case 2:
            let destinationVC = segue.destination as! SortingGame
            
            destinationVC.difficulty = difficulty
        case 3:
            let destinationVC = segue.destination as! PoppingGame
            
            destinationVC.difficulty = difficulty
        default:
            break
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        print("unwind")
    }
}
