//
//  KeyboardViewController.swift
//  BabelBoard
//
//  Created by Jared Moskowitz on 9/20/14.
//  Copyright (c) 2014 MFTech. All rights reserved.
//

import UIKit
import Alamofire

class KeyboardViewController: UIInputViewController, NSURLConnectionDataDelegate {
    let rows = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]]
    
    let mathematicalRows = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["+", "-", "*", "/", "(", ")", "^", "ln", "log"],
        ["e", "pi", "%", "d", "b", "n", "m"]]
    
    let languages = ["es", "fr", "math", "la", "de"]
    var currentRows: [Array<String>]!
    var currentLanguageIndex = 0
    
    
    let topPadding: CGFloat = 12
    let keyHeight: CGFloat = 40
    let keyWidth: CGFloat = 26
    let keySpacing: CGFloat = 6
    let rowSpacing: CGFloat = 15
    let shiftWidth: CGFloat = 40
    let shiftHeight: CGFloat = 40
    let spaceWidth: CGFloat = 210
    let spaceHeight: CGFloat = 40
    let nextWidth: CGFloat = 50
    
    
    var connectionResponse: NSData?
    
    
    let DELETE_TAG = 1
    let SPACE_TAG = 0
    
    
    var translationTextScrollView: UIScrollView?
    var translationView: UIView?
    var buttons: Array<UIButton> = []
    var shiftKey: UIButton?
    var deleteKey: UIButton?
    var spaceKey: UIButton?
    var nextKeyboardButton: KeyButton?
    var returnButton: KeyButton?
    
    var shiftPosArr = [0]
    var numCharacters = 0
    var untranslatedStartIndex = 0
    var untranslatedString = " "
    var spacePressed = false
    var spaceTimer: NSTimer?
    
    let spacing: CGFloat = 4.0

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 241.0/255, green: 235.0/255, blue: 221.0/255, alpha: 1)
        
        untranslatedString = ""

        let border = UIView(frame: CGRect(x:CGFloat(0.0), y:CGFloat(0.0), width:self.view.frame.size.width, height:CGFloat(0.5)))
        border.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        border.backgroundColor = UIColor(red: 210.0/255, green: 205.0/255, blue: 193.0/255, alpha: 1)
        self.view.addSubview(border)
        
        self.addKeys()
    }
    
    override func viewDidAppear(animated: Bool) {

        
        var keyboardRowView = UIView(frame: CGRect(x: 0, y: -50, width: 320, height: 50))
        keyboardRowView.backgroundColor = UIColor.redColor()
        self.view .addSubview(keyboardRowView)
    }
    
    
    func setLanguage(lang: String) {
        
    }
    
    
    func addKeys() {
        self.addNextKeyboardKey()
        self.addDeleteKey()
        self.addQwertyKeys()
        self.addReturnKey()
        self.addLanguageKey()
        self.addSpaceKey()
    }
    
    func addReturnKey() {
         var bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 10
        
        returnButton = KeyButton(frame: CGRect(x:320 - nextWidth - 2, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight))
        returnButton!.setTitle(NSLocalizedString("Ret", comment: "Title for 'Return Key' button"), forState:.Normal)
        returnButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        returnButton!.addTarget(self, action: "returnKeyPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(returnButton!)
    }
    
    func addDeleteKey() {
        var thirdRowTopPadding: CGFloat = topPadding + (keyHeight + rowSpacing) * 2
        
        deleteKey = KeyButton(frame: CGRect(x:320 - shiftWidth - 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        deleteKey?.tag = DELETE_TAG
        deleteKey!.addTarget(self, action: Selector("deleteKeyPressed:"), forControlEvents: .TouchUpInside)
        deleteKey!.setImage(UIImage(named: "delete.png"), forState:.Normal)
        deleteKey!.setImage(UIImage(named: "delete-selected.png"), forState:.Highlighted)
        self.view.addSubview(deleteKey!)
    }
    
    func addNextKeyboardKey() {
        var bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 10
        
        nextKeyboardButton = KeyButton(frame:CGRect(x:2, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight))
        nextKeyboardButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        nextKeyboardButton!.setTitle(NSLocalizedString("Next", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        nextKeyboardButton!.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        view.addSubview(self.nextKeyboardButton!)
    }
    
    func addSpaceKey() {
        var bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 10
        spaceKey = KeyButton(frame: CGRect(x:(320.0 - spaceWidth) / 2, y: bottomRowTopPadding, width:spaceWidth, height:spaceHeight))
        spaceKey?.tag = SPACE_TAG
        spaceKey!.setTitle(" ", forState: .Normal)
        spaceKey!.addTarget(self, action: Selector("spaceKeyPressed:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(spaceKey!)
    }
    
    func returnKeyPressed(sender: UIButton) {
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        while (untranslatedStartIndex > 0 ) {
            proxy.deleteBackward()
            untranslatedStartIndex--
            numCharacters--
        }
        let str = spaceKey?.titleLabel?.text
        proxy.insertText(str!)
        numCharacters += countElements(untranslatedString)
        untranslatedString = ""
        untranslatedStartIndex = 0
        spaceKey!.setTitle(" ", forState: .Normal)
        
//        proxy.insertText("\n")
//        numCharacters++
//        untranslatedStartIndex++
//        shiftPosArr[shiftPosArr.count - 1]++
//        if shiftKey!.selected {
//            shiftPosArr.append(0)
//            setShiftValue(true)
//        }
//        
//        spacePressed = false
    }
    
    
    func addLanguageKey() {
        var thirdRowTopPadding: CGFloat = topPadding + (keyHeight + rowSpacing) * 2
        
        shiftKey = KeyButton(frame: CGRect(x: 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        shiftKey!.addTarget(self, action: Selector("languageKeyPressed:"), forControlEvents: .TouchUpInside)
        shiftKey!.selected = true
        shiftKey!.setImage(UIImage(named: "shift.png"), forState:.Normal)
        shiftKey!.setImage(UIImage(named: "shift-selected.png"), forState:.Selected)
        self.view.addSubview(shiftKey!)
    }
    
    
    func addQwertyKeys() {
        
        var y: CGFloat = topPadding
        var width = UIScreen.mainScreen().applicationFrame.size.width
        for row in rows {
            var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (keySpacing + keyWidth) - keyWidth) / 2.0)
            for label in row {
                let button = KeyButton(frame: CGRect(x: x, y: y, width: keyWidth, height: keyHeight))
                button.setTitle(label.uppercaseString, forState: .Normal)
                button.addTarget(self, action: Selector("keyPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                
                self.view.addSubview(button)
                buttons.append(button)
                x += keyWidth + keySpacing
            }
            
            y += keyHeight + rowSpacing
        }
    }
    
    
    func deleteKeyPressed(sender: UIButton) {
        if numCharacters > 0 {
            var proxy = self.textDocumentProxy as UITextDocumentProxy
            proxy.deleteBackward()
            numCharacters--
            if countElements(untranslatedString) > 0 {
                untranslatedStartIndex--
                let stringLength = countElements(untranslatedString)
                let substringIndex = stringLength - 1
                untranslatedString = untranslatedString.substringToIndex(advance(untranslatedString.startIndex, substringIndex))
            }
            var charactersSinceShift = shiftPosArr[shiftPosArr.count - 1]
            if charactersSinceShift > 0 {
                charactersSinceShift--
            }
            
            setShiftValue(charactersSinceShift == 0)
            if charactersSinceShift == 0 && shiftPosArr.count > 1 {
                shiftPosArr.removeLast()
            } else {
                shiftPosArr[shiftPosArr.count - 1] = charactersSinceShift
            }
        }
        
        spacePressed = false
    }
    
    
    func languageKeyPressed(sender: UIButton) {
        
        if currentLanguageIndex >= countElements(languages) {
            currentLanguageIndex = 0
        } else {
            currentLanguageIndex--
        }
        
        self.setLanguage(languages[currentLanguageIndex])
        
        spacePressed = false
    }
    
    func keyPressed(sender: UIButton) {
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        let str = sender.titleLabel?.text
        proxy.insertText(str!)
        
        numCharacters++
        untranslatedStartIndex++
        untranslatedString += str!
        self.translateIt(untranslatedString, lang: "es")
        shiftPosArr[shiftPosArr.count - 1]++
        spacePressed = false
        if (shiftKey!.selected) {
            self.setShiftValue(false)
        }
    }
    
    
    func spaceKeyPressed(sender: UIButton) {
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if spacePressed {
            self.translateInline()
            spacePressed = false
        } else {
            proxy.insertText(" ")
            untranslatedString += " "
            numCharacters++
            spacePressed = true
            self.translateIt(untranslatedString, lang: "es")
        }
    }
    
    func spaceTimeout() {
        spaceTimer = nil
        spacePressed = false
    }
    
    
    func translateInline () {
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        var end = countElements(untranslatedString)
        //possible logic error here
        while (untranslatedStartIndex <= end ) {
            proxy.deleteBackward()
            end--
            numCharacters--
        }
        let str = spaceKey?.titleLabel?.text
        proxy.insertText(str!)
        numCharacters += countElements(untranslatedString)
        untranslatedString = ""
        untranslatedStartIndex = 0
        spaceKey!.setTitle(" ", forState: .Normal)
    }
    
    
    func setShiftValue(shiftVal: Bool) {
        if shiftKey?.selected != shiftVal {
            shiftKey!.selected = shiftVal
            for button in buttons {
                var text = button.titleLabel?.text
                if shiftKey!.selected {
                    text = text?.uppercaseString
                } else {
                    text = text?.lowercaseString
                }
                
                button.setTitle(text, forState: UIControlState.Normal)
                button.titleLabel?.sizeToFit()
            }
        }
    }
    
    func translateIt(message: String, lang: String){
        println("MESSAGE: " + message)
        
        var myparams:[String:String] = [:]
        var myLink = ""
        if (lang == "math") {
            myparams = ["message": message]
            myLink = "https://api.parse.com/1/functions/math"
            var request = NSMutableURLRequest(URL:NSURL.URLWithString(myLink));
            request.HTTPMethod = "POST"
            request.setValue("u19o03YiCWzeonVWaTNueubVC8UupUiP7HVibWF1", forHTTPHeaderField: "X-Parse-Application-Id")
            request.setValue("BY0NkbNymGC0n0pK3TicPHIosksEdK2DG8M1uCzE", forHTTPHeaderField: "X-Parse-REST-API-Key")
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(myparams, options: nil, error: &err)
            println(request)
            request.setValue( "application/json", forHTTPHeaderField:"Content-Type")
            var connection = NSURLConnection(request: request, delegate: self)
            connection.start()
            //TO DO: implement a function to catch the data using NSURLConnectionDelegate
        } else {
            myparams = ["key": "AIzaSyCSA2RH0SWp2HgP-WvssMT0lFY3V0tKdsk", "source": "en", "target": lang, "q": message]
            myLink = "https://www.googleapis.com/language/translate/v2"
            Alamofire.request(.GET, myLink, parameters: myparams)
                .responseJSON { (request, response, data, error) in
                    if (data != nil) {
                        println(data)
                        let jsonObject = JSONValue(data!)
                        let foreignWord = jsonObject["data"]["translations"][0]["translatedText"].string!
                        //TODO: FIX
                        self.spaceKey?.setTitle(foreignWord, forState: .Normal)
                    } else {
                        println("DATA IS NULL")
                    }
            }
        }
        
    }
    
    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
        
    }
    
    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        //self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }
    
}
