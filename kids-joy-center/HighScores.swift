//
//  HighScores.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/26/22.
//

import UIKit

class HighScores: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaults = UserDefaults.standard
    
    var gameTitle: String = ""
    var didWin: Bool = false
    var difficulty: Int = 0
    var score: Int = 0
    
    var highScores: [HighScore] = []
    let topScoreIcons: [String] = ["🥇", "🥈", "🥉", "4️⃣", "5️⃣"]
    let recentIcon: String = "🌟"
    
    var header: UILabel = UILabel()
    var footer: UILabel = UILabel()
    var swipeAway: UILabel = UILabel()
    
    var tableView: UITableView!
    
    var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawHomeButton()
        drawLabels()
        
        fetchHighScores()
        addHighScore()
        
        drawTable()
        
        addConstraints()
    }
    
    func addConstraints() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        header.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.topAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: 50).isActive = true
        footer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        footer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        footer.heightAnchor.constraint(equalToConstant: 24).isActive = true

        swipeAway.translatesAutoresizingMaskIntoConstraints = false
        swipeAway.topAnchor.constraint(equalTo: footer.bottomAnchor, constant: 10).isActive = true
        swipeAway.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        swipeAway.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        swipeAway.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        header.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10).isActive = true
        homeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        homeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
    }
    
    func fetchHighScores() {
        let remoteHighScores: [String] = defaults.stringArray(forKey: "highScores") ?? []
        
        for score in remoteHighScores {
            let splitEntry = score.split(separator: ",")
            highScores.append(HighScore(title: String(splitEntry[0]), difficulty: Int(splitEntry[1]) ?? -1, score: Int(splitEntry[2]) ?? 0, isRecent: false))
            
        }
    }
    
    func addHighScore() {
        if didWin {
            highScores.append(HighScore(title: gameTitle, difficulty: difficulty, score: score, isRecent: true))
        }
        
        if highScores.count > 1 {
            highScores = highScores.sorted(by: { $0.score > $1.score })
            
            if highScores.count > 5 {
                highScores.removeSubrange(5..<highScores.count)
            }
        }
        
        encodeHighScores()
    }
    
    func encodeHighScores() {
        var entries: [String] = []
        
        for index in 0..<highScores.count {
            entries.append("\(highScores[index].title),\(highScores[index].difficulty),\(highScores[index].score)")
        }
        
        defaults.set(entries, forKey: "highScores")
    }
    
    func drawHomeButton() {
        homeButton = UIButton(type: .roundedRect)
        homeButton.setTitle("Home", for: .normal)
        homeButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        homeButton.tintColor = .white
        homeButton.backgroundColor = .link
        homeButton.layer.cornerRadius = 25
        
        homeButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        self.view.addSubview(homeButton)
    }
    
    @objc func buttonClicked() {
        performSegue(withIdentifier: "unwind", sender: nil)
    }
    
    func drawLabels() {
        switch didWin {
        case true:
            GSAudio.sharedInstance.playSound(soundFileName: "win")
            
            header.text = "🎉 You scored \(score) points!"
            footer.text = "Do you want to try for higher?"
        case false:
            GSAudio.sharedInstance.playSound(soundFileName: "lose")
            
            header.text = "🙈 Better luck next time!"
            footer.text = "Try to be quicker than the clock!"
        }
        
        header.font = .boldSystemFont(ofSize: 40)
        header.textAlignment = .center
        self.view.addSubview(header)
        
        footer.font = .systemFont(ofSize: 24)
        footer.textAlignment = .center
        self.view.addSubview(footer)
        
        swipeAway.text = "Swipe down to restart..."
        swipeAway.font = .boldSystemFont(ofSize: 24)
        swipeAway.textAlignment = .center
        self.view.addSubview(swipeAway)
    }
    
    func drawTable() {
        tableView = UITableView()
        
        tableView.isUserInteractionEnabled = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "🏆 High Scores"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var labelText = "\(topScoreIcons[indexPath.row]) \(highScores[indexPath.row])"
        
        if highScores[indexPath.row].isRecent {
            labelText += " \(recentIcon)"
            
            cell.textLabel?.font = .boldSystemFont(ofSize: 24)
        } else {
            cell.textLabel?.font = .systemFont(ofSize: 24)
        }
        
        cell.textLabel?.text = labelText
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        GSAudio.sharedInstance.playSound(soundFileName: "swipe")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //encodeHighScores()
    }
}
