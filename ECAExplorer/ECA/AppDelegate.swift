//
//  AppDelegate.swift
//  ECA
//
//  Created by nst on 03.06.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, RuleViewDelegate, ECAViewDelegate, NSTextFieldDelegate {

    var ecaModel: ECAModel = ECAModel(width: 73)
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ruleView: RuleView!
    @IBOutlet weak var ecaView: ECAView!
    @IBOutlet weak var ruleTextField: NSTextField!
    
    var rule: UInt8 {
        get { return ecaModel.rule }
        set {
            ruleTextField.stringValue = "\(newValue)"
            ecaModel.rule = newValue
            ecaView.needsDisplay = true
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        checkForUpdates()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ecaModel.rule = 110
        ecaModel.firstRow[63] = 1

        ruleView.delegate = self
        ecaView.delegate = self
        
        ruleTextField.stringValue = "\(ecaModel.rule)"
    }
    
    @IBAction func textDidChange(sender: NSControl) {
        
        let newRuleString = ruleTextField.stringValue
 
        if let newRuleInt = UInt8(newRuleString) {
            ecaModel.rule = newRuleInt
            ruleView.needsDisplay = true
            ecaView.needsDisplay = true
        } else {
            print("ruleView:", ruleView)            
            ruleTextField.stringValue = "\(ecaModel.rule)"
        }
    }

    @IBAction func saveImageAction(sender: NSMenuItem?) {
        
        guard let window = self.window else { return }
        
        guard let pngData = ecaView.PNGRepresentation() else { return }
        
        let savePanel = NSSavePanel()
        let timestamp = Date().timeIntervalSince1970
        savePanel.nameFieldStringValue = "rule_\(ecaModel.rule)_\(timestamp).png"
        
        savePanel.beginSheetModal(for: window) { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                guard let exportedFileURL = savePanel.url else { return }
                do {
                    try pngData.write(to: exportedFileURL)
                } catch let e {
                    Swift.print(e)
                }
            }
        }
    }
    
    func checkForUpdates() {
        
        let url = URL(string:"http://www.seriot.ch/ecaexplorer/ecaexplorer.json")
        
        URLSession.shared.dataTask(with: url!) { (optionalData, response, error) in
            
            DispatchQueue.main.async {
                
                guard let data = optionalData,
                    let optionalDict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject],
                    let d = optionalDict,
                    let latestVersionString = d["latest_version_string"] as? String,
                    let latestVersionURL = d["latest_version_url"] as? String
                    else {
                        return
                }
                
                print("-- latestVersionString: \(latestVersionString)")
                print("-- latestVersionURL: \(latestVersionURL)")
                
                guard let currentVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }
                
                let needsUpdate = currentVersionString < latestVersionString
                
                print("-- needsUpdate: \(needsUpdate)")
                if needsUpdate == false { return }
                
                let a = NSAlert()
                a.messageText = "ECAExplorer \(latestVersionString) is Available"
                a.informativeText = "Please download it and replace the current version.";
                a.addButton(withTitle: "Download")
                a.addButton(withTitle: "Cancel")
                a.alertStyle = .critical
                
                let modalResponse = a.runModal()
                
                if modalResponse == NSAlertFirstButtonReturn {
                    if let downloadURL = URL(string:latestVersionURL) {
                        NSWorkspace.shared().open(downloadURL)
                    }
                }
            }
            }.resume()
    }

}
