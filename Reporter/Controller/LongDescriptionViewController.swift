//
//  LongDescriptionViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/26/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class LongDescriptionViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var longDescriptonTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var longDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longDescriptonTextView.delegate = self

        // put a border on the text view
        longDescriptonTextView.layer.borderWidth = 1
        longDescriptonTextView.layer.borderColor = UIColor.black.cgColor
        longDescriptonTextView.clipsToBounds = true
        longDescriptonTextView.layer.cornerRadius = 10
        
        // Need to add done button to text view keyboard
        longDescriptonTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        if let longDescription = longDescription {
            longDescriptonTextView.text = longDescription
        }
        
        updateSaveButtonState()
    }
    

    
    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: false)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        longDescription = longDescriptonTextView.text ?? ""
    }
    
    //MARK: UITextFieldDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        let text = longDescriptonTextView.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    //MARK: @objc Functions
    // adds done button to text view keyboard
    @objc private func tapDone(sender: Any) {
        self.view.endEditing(true)
    }

}
