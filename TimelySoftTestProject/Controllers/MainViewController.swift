//
//  ViewController.swift
//  TimelySoftTestProject
//
//  Created by Syimyk on 2/16/21.
//  Copyright © 2021 Syimyk. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, WordManagerDelegate {

    
  

    let defaults = UserDefaults.standard
    
    var wordManager = WordManager()
    
    var listOfWords = [String]()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addWordButton: UIButton!
    @IBOutlet weak var showFullMessageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemOrange.cgColor
        addWordButton.layer.cornerRadius = 8.0
        addWordButton.layer.masksToBounds = true
        showFullMessageButton.layer.cornerRadius = 8.0
        showFullMessageButton.layer.masksToBounds = true
        
        wordManager.delegate = self
        
    }

    @IBAction func addWordButtonTapped(_ sender: UIButton) {
        if let safeText = textField.text, safeText != ""{
            textField.resignFirstResponder()
            listOfWords.append(safeText)
            textField.text = ""
            tableView.reloadData()
        }else{
            textField.placeholder = "Please enter a word..."
        }
    }
    
    
    @IBAction func showFullMessageBtnTapped(_ sender: UIButton) {
        var longString = ""
        for item in listOfWords{
            if let newItem = defaults.string(forKey: item){
                longString.append(" \(newItem)")
            }
        }

        let alertVC = UIAlertController(title: "Translation", message: "\(longString)", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        self.present(alertVC, animated: true)
    }
    
    
    
    
    func didTranslate(_ wordManager: WordManager, wordModel: WordModel) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Tranlation", message: wordModel.translatedWord, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //adding to UserDefaults
            self.defaults.set(wordModel.translatedWord, forKey: wordModel.originalWord)
            
            
            self.present(alertVC, animated: true)
        }
        
    }
    
    func didFailWithError(error: Error, noTranslateWord: String) {
        DispatchQueue.main.async {
            self.listOfWords.removeAll { $0 == noTranslateWord }

            let alertVC = UIAlertController(title: "Error", message: "No Translation For \(noTranslateWord)", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(alertVC, animated: true)

            self.tableView.reloadData()
        }
        
        
    } 
}


//MARK: - UITableView Methods
extension MainViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = listOfWords[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = listOfWords[indexPath.row]
        wordManager.fetchWord(word: word)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
