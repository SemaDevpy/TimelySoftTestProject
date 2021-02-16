//
//  WordManager.swift
//  TimelySoftTestProject
//
//  Created by Syimyk on 2/16/21.
//  Copyright © 2021 Syimyk. All rights reserved.
//

import Foundation


protocol WordManagerDelegate {
    func didTranslate(_ wordManager : WordManager, wordModel: WordModel)
    func didFailWithError(error : Error , noTranslateWord : String)
}


struct WordManager {
    
    let wordURL = "https://aucatranslator.azurewebsites.net/api/v1/wordtranslation/?word="
    
    var globeWord = ""
    
    var delegate : WordManagerDelegate?
    
    mutating func fetchWord(word: String){
        globeWord = word
        let urlString = "\(wordURL)\(word)"
        performRequest(with: urlString)
    }
    
    
    func performRequest(with urlString: String){
        //1.create a URL
        if let url = URL(string: urlString){
            //2.create a URLSession
            let session = URLSession(configuration: .default)
            //3.Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!, noTranslateWord: self.globeWord)
                    return
                }
                
                if let safeData = data{
                    if let words = self.parseJSON(safeData){
                        self.delegate?.didTranslate(self, wordModel: words)
                    }
                }
            }
            //4.start the task
            task.resume()
        }
    }
    
    
    
    
    
    
    func parseJSON(_ wordData: Data) -> WordModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WordData.self, from: wordData)
            let word = decodedData.translation
            let originalWord = decodedData.originalWord
            let wordModel = WordModel(originalWord: originalWord, translatedWord: word)
            return wordModel
            
            
        }catch{
            delegate?.didFailWithError(error: error, noTranslateWord: globeWord)
            return nil
        }
        
    }
    
    
    
    
}
