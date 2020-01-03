//
//  PhotoEditingViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/27/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log
import Floaty

class PhotoEditingViewController: UIViewController, UINavigationControllerDelegate, FloatyDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoView: UIImageView!
    
    // passed to this view from the job content view
    var photo: UIImage?
    
    // floating action button
    var fab = Floaty()
    
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
            
            photoView.image = sizePhotoAndView(photo: photo)
            
        }
        layoutFloatingActionButton()
    }
    
    //MARK: Orientation Transition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // wait for transition to happen
        DispatchQueue.main.async {
            
            // resize photo and view to new constraints
            self.photoView.image = self.sizePhotoAndView(photo: self.photo!)
            
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
        let renderer = UIGraphicsImageRenderer(size: photoView!.bounds.size)
        let editedImage = renderer.image { ctx in
            photoView!.drawHierarchy(in: photoView!.bounds, afterScreenUpdates: true)
        }
        
        photo = editedImage
    }
    
    //MARK: Methods
    func sizePhotoAndView(photo: UIImage) -> UIImage {
        print("Width: " + String(Double(self.view.frame.width)))
        print("Height: " + String(Double(self.view.frame.height)))
        
        let navBarHeight = self.navigationController!.navigationBar.frame.height
        let viewHeight = self.view.frame.height - navBarHeight
        let viewWidth = self.view.frame.width
        
        let viewHeightToWidthRatio = viewWidth / viewHeight
        let photoHeightToWidthRatio = photo.size.width / photo.size.height
        let photoWidthToHeightRatio = photo.size.height / photo.size.width
        var width: CGFloat
        var height: CGFloat
        var originX: CGFloat
        var originY: CGFloat
        
        
        if (viewHeightToWidthRatio > photoHeightToWidthRatio) {
            // constrained by the height of the superview
            height = viewHeight
            width = height * photoHeightToWidthRatio
            originY = 0.0 + navBarHeight
            originX = (viewWidth / 2) - (width / 2)
        }
        else {
            // constrained by width of superview
            width = viewWidth
            height = width * photoWidthToHeightRatio
            originY = ((viewHeight + navBarHeight) / 2) - (height / 2)
            originX = 0.0
        }
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        photo.draw(in: frame)
        let newPhoto = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        photoView.frame = CGRect(x: originX, y: originY, width: width, height: height)
        //photoView.layer.borderWidth = 5
        //photoView.layer.borderColor = UIColor.red.cgColor
        
        return newPhoto!
    }

    
    //MARK: Actions
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        let tapPoint = sender.location(in: self.photoView)
        
        switch editTypeSelected {
        case .CIRCLE:
            print("DRaw Circle")
            drawCircle(tapPoint: tapPoint)
            
        case .ARROW:
            
            drawArrow(tapPoint: tapPoint)
            
        case .ERASER:
            
            print("handled by shapeviews own tapGR action")
            
        case .NONE:
            
            print("Do nothing, no edit selected")
            
        default:
            print("Do nothing")
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {

        navigationController?.popViewController(animated: false)
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
        
        let shapeView = Circle(origin: tapPoint)
        
        self.photoView!.addSubview(shapeView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoEditingViewController.didTapShape(_:)))
        shapeView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func drawArrow(tapPoint: CGPoint) {
        
        let shapeView = Arrow(origin: tapPoint)
        
        self.photoView!.addSubview(shapeView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoEditingViewController.didTapShape(_:)))
        shapeView.addGestureRecognizer(tapGestureRecognizer)
    }

    
    @IBAction func didTapShape(_ sender: UIPinchGestureRecognizer) {
        if editTypeSelected == SelectedEdit.ERASER {
            sender.view?.removeFromSuperview()
        }
    }
    
    
    //MARK: UI Components
    func layoutFloatingActionButton() {
        
        let circleItem = FloatyItem()
        circleItem.buttonColor = UIColor.white
        circleItem.circleShadowColor = UIColor.blue
        circleItem.titleShadowColor = UIColor.black
        circleItem.icon = UIImage(named: "circle")
        circleItem.title = "Circle"
        circleItem.handler = { item in
            // Add handler here
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.editTypeSelected = SelectedEdit.CIRCLE
        }
        
        let arrowItem = FloatyItem()
        arrowItem.buttonColor = UIColor.white
        arrowItem.circleShadowColor = UIColor.blue
        arrowItem.titleShadowColor = UIColor.black
        arrowItem.icon = UIImage(named: "arrow")
        arrowItem.title = "Arrow"
        arrowItem.handler = { item in
            // Add handler here
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.editTypeSelected = SelectedEdit.ARROW
        }
        
        let dashedItem = FloatyItem()
        dashedItem.buttonColor = UIColor.white
        dashedItem.circleShadowColor = UIColor.blue
        dashedItem.titleShadowColor = UIColor.black
        dashedItem.icon = UIImage(named: "dashed")
        dashedItem.title = "Dashed Line"
        dashedItem.handler = { item in
            // Add handler here
            print("HANDLE")
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.performSegue(withIdentifier: "AddDescription", sender: self)
        }
        
        let lineItem = FloatyItem()
        lineItem.buttonColor = UIColor.white
        lineItem.circleShadowColor = UIColor.blue
        lineItem.titleShadowColor = UIColor.black
        lineItem.icon = UIImage(named: "line")
        lineItem.title = "Line"
        lineItem.handler = { item in
            // Add handler here
            print("HANDLE")
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.performSegue(withIdentifier: "AddDescription", sender: self)
        }
        
        let textItem = FloatyItem()
        textItem.buttonColor = UIColor.white
        textItem.circleShadowColor = UIColor.blue
        textItem.titleShadowColor = UIColor.black
        textItem.icon = UIImage(named: "textBox")
        textItem.title = "Text Box"
        textItem.handler = { item in
            // Add handler here
            print("HANDLE")
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.performSegue(withIdentifier: "AddDescription", sender: self)
        }
        
        let eraseItem = FloatyItem()
        eraseItem.buttonColor = UIColor.white
        eraseItem.circleShadowColor = UIColor.blue
        eraseItem.titleShadowColor = UIColor.black
        eraseItem.icon = UIImage(named: "erase")
        eraseItem.title = "Delete Item"
        eraseItem.handler = { item in
            // Add handler here
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.editTypeSelected = SelectedEdit.ERASER
        }
        
        fab.addItem(item: circleItem)
        fab.addItem(item: arrowItem)
        fab.addItem(item: dashedItem)
        fab.addItem(item: lineItem)
        fab.addItem(item: textItem)
        fab.addItem(item: eraseItem)
                
        fab.paddingX = 40
        fab.paddingY = 40
        
        fab.fabDelegate = self
        fab.isDraggable = true
        
        self.view.addSubview(fab)
        
    }

}
