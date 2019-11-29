//
//  PhotoEditingViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/27/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class PhotoEditingViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // passed to this view from the job content view
    var photo: UIImage?
    
    // editor selector enum
    enum SelectedEdit {
        case CIRCLE, ARROW, ERASER, NONE
    }
    
    var editTypeSelected: SelectedEdit?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize selected edit to none
        editTypeSelected = SelectedEdit.NONE
        
        // set background color
        self.view.backgroundColor = UIColor.black
        
        // Do any additional setup after loading the view.
        if let photo = photo {
            photoView.image = photo
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        // The following is for saving the image with the markups as a new image
        // It renders the entire photoView and its subviews as an image
        let renderer = UIGraphicsImageRenderer(size: photoView.bounds.size)
        let editedImage = renderer.image { ctx in
            photoView.drawHierarchy(in: photoView.bounds, afterScreenUpdates: true)
        }
        
        photo = editedImage
    }

    
    //MARK: Actions
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        let tapPoint = sender.location(in: self.photoView)
        
        switch editTypeSelected {
        case .CIRCLE:
            
            drawCircle(tapPoint: tapPoint)
            
        case .ARROW:
            
            drawArrow(tapPoint: tapPoint)
            
        case .ERASER:
            
            deleteAtLocation(tapPoint: tapPoint)
            
        case .NONE:
            print("Do nothing, no edit selected")
        default:
            print("Do nothing")
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCircle(_ sender: UIBarButtonItem) {
        editTypeSelected = SelectedEdit.CIRCLE
    }
    
    @IBAction func addArrow(_ sender: UIBarButtonItem) {
        editTypeSelected = SelectedEdit.ARROW
    }
    
    @IBAction func deleteItem(_ sender: UIBarButtonItem) {
        editTypeSelected = SelectedEdit.ERASER
    }
    
    //Mark: Private Methods
    private func drawCircle(tapPoint: CGPoint) {
        
        let shapeView = ShapeView(origin: tapPoint)
        
        self.photoView.addSubview(shapeView)
    }
    
    private func drawArrow(tapPoint: CGPoint) {
        print("Create an arrow")
    }
    
    private func deleteAtLocation(tapPoint: CGPoint) {
        print("ERASE")
    }

}
