//
//  JobContentViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/24/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobContentViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    //MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var severitySelector: UISegmentedControl!
    
    
    // The job which was selected, if one was selected
    // Or this is constructed as part of adding a new content item
    var content: JobContentItem?
    var severity = JobContentItem.Severity.GREEN
    var longDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        if let content = content {
            titleTextField.text = content.shortDescription
            photoImageView.image = content.photo
            severity = content.status
            setSeveritySelector(severity: content.status)
            longDescription = content.longDescription
        }
        
        updateSaveButtonState()
    }
    

    
    // MARK: - Navigation
    // this function is called when we navigate back to JobContentTableView
    // Use this to pass new table cell back to table
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // good habit, doesnt do anything here
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        // configure destination view controller only when save button is pressed
        // the following code verifies that the saveButton was pressed
        
        switch(segue.identifier ?? "") {
        
        case "AddDescription":
            guard let navigation = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let longDescriptionViewController = navigation.topViewController as? LongDescriptionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let longDescriptionText = self.content?.longDescription
            longDescriptionViewController.longDescription = longDescriptionText
        
        case "EditPhoto":
            os_log("Editing Photo", log: OSLog.default, type: .debug)
        
        default:
            guard let button = sender as? UIBarButtonItem, button == saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            
            let shortDescription = titleTextField.text ?? "No description (please update)"
            let photo = photoImageView.image
            let severityStatus = severity
            let longDescriptionText = longDescription
            
            // set the content to be passed to JobContentTableViewController after unwind segue
            content = JobContentItem(shortDescription: shortDescription, photo: photo, status: severityStatus, severityIconPhoto: nil, longDescription: longDescriptionText)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddContentMode = presentingViewController is UINavigationController
        if isPresentingInAddContentMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The JobContentViewController is not inside a navigation controller")
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // sets the selected picture to the photo in the content view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }

    
    //MARK: Actions
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {

        // Hide the keyboard
        titleTextField.resignFirstResponder()
        
        // find out whether they want to take a photo or pick from library
        // Pick from camera
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                
                // Only allow photos to be picked, not taken
                imagePickerController.sourceType = .camera
                
                // Make sure ViewController is notified when the user picks an image
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        
        // Pick from library
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePickerController = UIImagePickerController()
                
                // Only allow photos to be picked, not taken
                imagePickerController.sourceType = .photoLibrary
                
                // Make sure ViewController is notified when the user picks an image
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        
        // cancel button (for iphone only, wont show up on ipad)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert:UIAlertAction!) -> Void in
            print("user canceled image select action sheet")
        }))

        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
                
        self.present(alert, animated: true)
    }
    
    @IBAction func severitySelected(_ sender: UISegmentedControl) {
        
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            severity = JobContentItem.Severity.GREEN
        case 1:
            severity = JobContentItem.Severity.YELLOW
        case 2:
            severity = JobContentItem.Severity.RED
        default:
            print("An option not on the segment control was selected")
        }
    }
    
    // This function receieves the changes from the long description editor and the image editor
    // I still need to add the condition for the image editor
    @IBAction func unwindToJobContentView(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? LongDescriptionViewController, let longDescriptionText = sourceViewController.longDescription {
            longDescription = longDescriptionText
        }
    }
    
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    private func setSeveritySelector(severity: JobContentItem.Severity) {
        
        switch severity {
        case JobContentItem.Severity.GREEN:
            severitySelector.selectedSegmentIndex = 0
        case JobContentItem.Severity.YELLOW:
            severitySelector.selectedSegmentIndex = 1
        case JobContentItem.Severity.RED:
            severitySelector.selectedSegmentIndex = 2
        }
    }
        
}
