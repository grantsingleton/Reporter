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
import Drawsana

class PhotoEditingViewController: UIViewController, UINavigationControllerDelegate, FloatyDelegate, TextToolDelegate, SelectionToolDelegate, DrawingOperationStackDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoView: UIImageView!
    
    //MARK: Editing Buttons
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    
    // passed to this view from the job content view
    var photo: UIImage?
    
    // Initialize drawing view. The CGRect for this view will be updated according to photo dimensions
    let drawingView = DrawsanaView()
    
    // font selection
    var fontButton = UIButton()
    var fontView = UIView()
    var selectedFont: String = "Helvetica"
    var fontSize: Float = 18
    
    // The tools used for drawing
    let arrowTool = ArrowTool()
    let ellipseTool = EllipseTool()
    let lineTool = LineTool()
    let dashLineTool = DashedLineTool()
    let rectTool = RectTool()
    let eraserTool = EraserTool()
    lazy var textTool = { return TextTool(delegate: self) }()
    lazy var selectionTool = { return SelectionTool(delegate: self) }()
    
    
    // Editing tool floating action button
    var toolFloaty = Floaty()
    let eraseItem = FloatyItem()
    let textItem = FloatyItem()
    let imageItem = FloatyItem()
    let selectItem = FloatyItem()
    let lineItem = FloatyItem()
    let dashedItem = FloatyItem()
    let arrowItem = FloatyItem()
    let rectangleItem = FloatyItem()
    let circleItem = FloatyItem()

    // Line width floating action button
    var lineWidthFloaty = Floaty()
    let minWidthItem = FloatyItem()
    let mediumWidthItem = FloatyItem()
    let maxWidthItem = FloatyItem()
    
    // Color palette floating action button
    var paletteFloaty = Floaty()
    let redItem = FloatyItem()
    let blueItem = FloatyItem()
    let yellowItem = FloatyItem()
    let greenItem = FloatyItem()
    let orangeItem = FloatyItem()
    let blackItem = FloatyItem()
    let whiteItem = FloatyItem()
    
    // editor selector enum
    enum SelectedEdit {
        case CIRCLE, RECTANGLE, DASHED, LINE, TEXT, IMAGE, SELECT, ARROW, ERASER, NONE
    }
    
    var editTypeSelected: SelectedEdit = .NONE
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // layout the floating action buttons
        let fabWidth: CGFloat = 78 //56
        let sideMargin: CGFloat = 40
        let bottomMargin: CGFloat = 60
        let viewWidth: CGFloat = self.view.frame.width
        let viewHeight: CGFloat = self.view.frame.height
        let navBarHeight: CGFloat = (self.navigationController?.navigationBar.frame.height)!
        
        toolFloaty = Floaty(frame: CGRect(x: viewWidth - sideMargin - fabWidth, y: viewHeight - navBarHeight - bottomMargin, width: fabWidth, height: fabWidth))
        
        lineWidthFloaty = Floaty(frame: CGRect(x: sideMargin, y: viewHeight - navBarHeight - bottomMargin, width: fabWidth, height: fabWidth))
        
        paletteFloaty = Floaty(frame: CGRect(x: (viewWidth / 2) - (fabWidth / 2), y: viewHeight - navBarHeight - bottomMargin, width: fabWidth, height: fabWidth))
                
        // set background color
        self.view.backgroundColor = UIColor.black
                
        // Do any additional setup after loading the view.
        if let photo = photo {
            
            photoView.image = sizePhotoAndView(photo: photo)
            view.addSubview(drawingView)
        }
        layoutFloatingActionButton()
        
        // Set default drawsana settings
        drawingView.userSettings.strokeWidth = 5
        drawingView.userSettings.strokeColor = .red
        drawingView.userSettings.fillColor = .clear
        drawingView.userSettings.fontSize = 18
        drawingView.userSettings.fontName = "Helvetica"
        
        drawingView.operationStack.delegate = self
        
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        saveButton.isEnabled = false
        
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
        //let renderer = UIGraphicsImageRenderer(size: photoView!.bounds.size)
        /*let editedImage = renderer.image { ctx in
            photoView!.drawHierarchy(in: photoView!.bounds, afterScreenUpdates: true)
        }*/
        let editedImage = drawingView.render(over: photoView.image)
        
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
        
        // layout DrawsanaView same as PhotoView
        drawingView.frame = CGRect(x: originX, y: originY, width: width, height: height)
        //drawingView.layer.borderWidth = 5
        //drawingView.layer.borderColor = UIColor.red.cgColor
        
        return newPhoto!
    }

    
    @IBAction func cancel(_ sender: UIBarButtonItem) {

        navigationController?.popViewController(animated: false)
    }
    
    
    //MARK: UI Components
    func layoutFloatingActionButton() {
        
        
        /*
         Configure Tool Floaty Items
         */
        circleItem.buttonColor = UIColor.white
        circleItem.circleShadowColor = UIColor.blue
        circleItem.titleShadowColor = UIColor.black
        circleItem.icon = UIImage(named: "circle")
        circleItem.handler = { item in
            // Switch to ellipse tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.ellipseTool)
            self.toolFloaty.buttonImage = UIImage(named: "circle")
            self.editTypeSelected = .CIRCLE
        }
        
        rectangleItem.buttonColor = UIColor.white
        rectangleItem.circleShadowColor = UIColor.blue
        rectangleItem.titleShadowColor = UIColor.black
        rectangleItem.icon = UIImage(named: "rectangle")
        rectangleItem.handler = { item in
            // Switch to ellipse tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.rectTool)
            self.toolFloaty.buttonImage = UIImage(named: "rectangle")
            self.editTypeSelected = .RECTANGLE
        }
        
        arrowItem.buttonColor = UIColor.white
        arrowItem.circleShadowColor = UIColor.blue
        arrowItem.titleShadowColor = UIColor.black
        arrowItem.icon = UIImage(named: "arrow")
        arrowItem.handler = { item in
            // Switch to arrow tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.arrowTool)
            self.toolFloaty.buttonImage = UIImage(named: "arrow")
            self.editTypeSelected = .ARROW
        }
        
        dashedItem.buttonColor = UIColor.white
        dashedItem.circleShadowColor = UIColor.blue
        dashedItem.titleShadowColor = UIColor.black
        dashedItem.icon = UIImage(named: "dashed")
        dashedItem.handler = { item in
            // Switch to dashed line tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.dashLineTool)
            self.toolFloaty.buttonImage = UIImage(named: "dashed")
            self.editTypeSelected = .DASHED
        }
        
        lineItem.buttonColor = UIColor.white
        lineItem.circleShadowColor = UIColor.blue
        lineItem.titleShadowColor = UIColor.black
        lineItem.icon = UIImage(named: "line")
        lineItem.handler = { item in
            // Switch to line tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.lineTool)
            self.toolFloaty.buttonImage = UIImage(named: "line")
            self.editTypeSelected = .LINE
        }
        
        textItem.buttonColor = UIColor.white
        textItem.circleShadowColor = UIColor.blue
        textItem.titleShadowColor = UIColor.black
        textItem.icon = UIImage(named: "textBox")
        textItem.handler = { item in
            // Switch to text tool
            self.drawingView.set(tool: self.textTool)
            self.toolFloaty.buttonImage = UIImage(named: "textBox")
            self.editTypeSelected = .TEXT
            // Place and configure font selection button
            self.placeFontButton()
        }
        
        imageItem.buttonColor = UIColor.white
        imageItem.circleShadowColor = UIColor.blue
        imageItem.titleShadowColor = UIColor.black
        imageItem.icon = UIImage(named: "addImage")
        imageItem.handler = { item in
            // Switch to add image tool
            self.checkForFontButton()
            //self.drawingView.set(tool: self.textTool)
            self.toolFloaty.buttonImage = UIImage(named: "addImage")
            self.editTypeSelected = .IMAGE
        }
        
        eraseItem.buttonColor = UIColor.white
        eraseItem.circleShadowColor = UIColor.blue
        eraseItem.titleShadowColor = UIColor.black
        eraseItem.icon = UIImage(named: "erase")
        eraseItem.handler = { item in
            // switch to eraser
            self.checkForFontButton()
            self.drawingView.set(tool: self.eraserTool)
            self.toolFloaty.buttonImage = UIImage(named: "erase")
            self.editTypeSelected = .ERASER
        }
        
        selectItem.buttonColor = UIColor.white
        selectItem.circleShadowColor = UIColor.blue
        selectItem.titleShadowColor = UIColor.black
        selectItem.icon = UIImage(named: "select")
        selectItem.handler = { item in
            // switch to selection tool
            self.checkForFontButton()
            self.drawingView.set(tool: self.selectionTool)
            self.toolFloaty.buttonImage = UIImage(named: "select")
            self.editTypeSelected = .SELECT
        }
        
        toolFloaty.addItem(item: circleItem)
        toolFloaty.addItem(item: rectangleItem)
        toolFloaty.addItem(item: arrowItem)
        toolFloaty.addItem(item: dashedItem)
        toolFloaty.addItem(item: lineItem)
        toolFloaty.addItem(item: textItem)
        toolFloaty.addItem(item: imageItem)
        toolFloaty.addItem(item: eraseItem)
        toolFloaty.addItem(item: selectItem)
        
        /*
         Configure palette Floaty Items
         */
        redItem.buttonColor = UIColor.red
        redItem.circleShadowColor = UIColor.white
        redItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .red
            self.paletteFabColor(color: .red)
        }
        
        blueItem.buttonColor = UIColor.blue
        blueItem.circleShadowColor = UIColor.white
        blueItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .blue
            self.paletteFabColor(color: .blue)
        }
        
        yellowItem.buttonColor = UIColor.yellow
        yellowItem.circleShadowColor = UIColor.white
        yellowItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .yellow
            self.paletteFabColor(color: .yellow)

        }
        
        greenItem.buttonColor = UIColor.green
        greenItem.circleShadowColor = UIColor.white
        greenItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .green
            self.paletteFabColor(color: .green)

        }
        
        orangeItem.buttonColor = UIColor.orange
        orangeItem.circleShadowColor = UIColor.white
        orangeItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .orange
            self.paletteFabColor(color: .orange)

        }
        
        blackItem.buttonColor = UIColor.black
        blackItem.circleShadowColor = UIColor.white
        blackItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .black
            self.paletteFabColor(color: .darkGray)
        }
        
        whiteItem.buttonColor = UIColor.white
        whiteItem.circleShadowColor = UIColor.white
        whiteItem.handler = { item in
            self.drawingView.userSettings.strokeColor = .white
            self.paletteFabColor(color: .white)
        }
        
        paletteFloaty.addItem(item: redItem)
        paletteFloaty.addItem(item: blueItem)
        paletteFloaty.addItem(item: yellowItem)
        paletteFloaty.addItem(item: greenItem)
        paletteFloaty.addItem(item: orangeItem)
        paletteFloaty.addItem(item: blackItem)
        paletteFloaty.addItem(item: whiteItem)
                
        /*
         Configure width floaty item
         */
        minWidthItem.buttonColor = UIColor.white
        minWidthItem.circleShadowColor = UIColor.black
        minWidthItem.icon = UIImage(named: "thinLine")
        minWidthItem.handler = { item in
            self.drawingView.userSettings.strokeWidth = 3
            self.lineWidthFloaty.buttonImage = UIImage(named: "thinLine")
        }
        
        mediumWidthItem.buttonColor = UIColor.white
        mediumWidthItem.circleShadowColor = UIColor.black
        mediumWidthItem.icon = UIImage(named: "mediumLine")
        mediumWidthItem.handler = { item in
            self.drawingView.userSettings.strokeWidth = 5
            self.lineWidthFloaty.buttonImage = UIImage(named: "mediumLine")
        }
        
        maxWidthItem.buttonColor = UIColor.white
        maxWidthItem.circleShadowColor = UIColor.black
        maxWidthItem.icon = UIImage(named: "thickLine")
        maxWidthItem.handler = { item in
            self.drawingView.userSettings.strokeWidth = 7
            self.lineWidthFloaty.buttonImage = UIImage(named: "thickLine")
        }
        
        lineWidthFloaty.addItem(item: minWidthItem)
        lineWidthFloaty.addItem(item: mediumWidthItem)
        lineWidthFloaty.addItem(item: maxWidthItem)

        
        toolFloaty.buttonImage = UIImage(named: "paint")
        lineWidthFloaty.buttonImage = UIImage(named: "lineWidth")
        paletteFloaty.buttonImage = UIImage(named: "palette")
        
        toolFloaty.fabDelegate = self
        lineWidthFloaty.fabDelegate = self
        paletteFloaty.fabDelegate = self
        
        toolFloaty.isDraggable = true
        lineWidthFloaty.isDraggable = true
        paletteFloaty.isDraggable = true
        
        toolFloaty.friendlyTap = true
        lineWidthFloaty.friendlyTap = true
        paletteFloaty.friendlyTap = true
        
        toolFloaty.openAnimationType = .slideUp
        paletteFloaty.openAnimationType = .slideUp
        lineWidthFloaty.openAnimationType = .slideUp
        
        self.view.addSubview(toolFloaty)
        self.view.addSubview(lineWidthFloaty)
        self.view.addSubview(paletteFloaty)
        
    }
    
    func paletteFabColor(color: UIColor) {
       
        paletteFloaty.selectedColor = color
        paletteFloaty.buttonColor = color
    }
    
    //MARK: Text Tool Delegate Functions
    func textToolPointForNewText(tappedPoint: CGPoint) -> CGPoint {
        return tappedPoint
    }
    
    func textToolDidTapAway(tappedPoint: CGPoint) {
        drawingView.set(tool: self.selectionTool)
    }
    
    func textToolWillUseEditingView(_ editingView: TextShapeEditingView) {
        // This example implementation of `textToolWillUseEditingView` shows how you
        // can customize the appearance of the text tool
        //
        // Important note: each handle's layer.anchorPoint is set to a non-0.5,0.5
        // value, so the positions are offset from where AutoLayout puts them.
        // That's why `halfButtonSize` is added and subtracted depending on which
        // control is being configured.
        //
        // The anchor point is changed so that the controls can be scaled correctly
        // in `textToolDidUpdateEditingViewTransform`.
        let makeView: (UIImage?) -> UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.layer.cornerRadius = 6
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 1, height: 1)
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 0.5
            if let image = $0 {
                view.frame = CGRect(origin: .zero, size: CGSize(width: 16, height: 16))
                let imageView = UIImageView(image: image)
                imageView.translatesAutoresizingMaskIntoConstraints = true
                imageView.frame = view.bounds.insetBy(dx: 4, dy: 4)
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .white
                view.addSubview(imageView)
            }
            return view
        }
        
        let buttonSize: CGFloat = 36
        let halfButtonSize = buttonSize / 2
        
        let deleteImage = UIImage(named: "delete")
        let widthImage = UIImage(named: "changeWidth")
        //let resizeImage = UIImage(named: "resizeRotate")
        
        editingView.addControl(dragActionType: .delete, view: makeView(deleteImage)) { (textView, deleteControlView) in
            deleteControlView.layer.anchorPoint = CGPoint(x: 1, y: 1)
            NSLayoutConstraint.activate([
                deleteControlView.widthAnchor.constraint(equalToConstant: buttonSize),
                deleteControlView.heightAnchor.constraint(equalToConstant: buttonSize),
                deleteControlView.rightAnchor.constraint(equalTo: textView.leftAnchor, constant: halfButtonSize),
                deleteControlView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -3 + halfButtonSize),
            ])
        }
        /*
        editingView.addControl(dragActionType: .resizeAndRotate, view: makeView(resizeImage)) { (textView, resizeAndRotateControlView) in
            resizeAndRotateControlView.layer.anchorPoint = CGPoint(x: 0, y: 0)
            NSLayoutConstraint.activate([
                resizeAndRotateControlView.widthAnchor.constraint(equalToConstant: buttonSize),
                resizeAndRotateControlView.heightAnchor.constraint(equalToConstant: buttonSize),
                resizeAndRotateControlView.leftAnchor.constraint(equalTo: textView.rightAnchor, constant: 5 - halfButtonSize),
                resizeAndRotateControlView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4 - halfButtonSize),
            ])
        } */
        
        editingView.addControl(dragActionType: .changeWidth, view: makeView(widthImage)) { (textView, changeWidthControlView) in
            changeWidthControlView.layer.anchorPoint = CGPoint(x: 0, y: 1)
            NSLayoutConstraint.activate([
                changeWidthControlView.widthAnchor.constraint(equalToConstant: buttonSize),
                changeWidthControlView.heightAnchor.constraint(equalToConstant: buttonSize),
                changeWidthControlView.leftAnchor.constraint(equalTo: textView.rightAnchor, constant: 5 - halfButtonSize),
                changeWidthControlView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -4 + halfButtonSize),
            ])
        }
    }
    
    func textToolDidUpdateEditingViewTransform(_ editingView: TextShapeEditingView, transform: ShapeTransform) {
        for control in editingView.controls {
            control.view.transform = CGAffineTransform(scaleX: 1/transform.scale, y: 1/transform.scale)
        }
    }
    
    //MARK: Selection tool delegate functions
    func selectionToolDidTapOnAlreadySelectedShape(_ shape: ShapeSelectable) {
        if shape as? TextShape != nil {
            drawingView.set(tool: textTool, shape: shape)
            placeFontButton()
        } else {
            drawingView.toolSettings.selectedShape = nil
        }
    }
    
    //MARK: Drawing Operation Stack Delegate
    func drawingOperationStackDidUndo(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
        applyUndoViewState()
    }
    
    func drawingOperationStackDidRedo(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
        applyUndoViewState()
    }
    
    func drawingOperationStackDidApply(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
        applyUndoViewState()
        
    }
    
    //MARK: Editing Buttons
    @IBAction func undo(_ sender: UIBarButtonItem) {
        drawingView.operationStack.undo()
    }
    
    @IBAction func redo(_ sender: UIBarButtonItem) {
        drawingView.operationStack.redo()
    }
    
    // Update button states to reflect undo stack
    private func applyUndoViewState() {
        
        undoButton.isEnabled = drawingView.operationStack.canUndo
        redoButton.isEnabled = drawingView.operationStack.canRedo
        
        saveButton.isEnabled = drawingView.operationStack.canUndo
        
    }
    
    private func placeFontButton() {
        
        let navBarHeight: CGFloat = (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        let buttonWidth: CGFloat = 150
        let buttonHeight: CGFloat = 40
        
        fontButton = UIButton(frame: CGRect(x: 0, y: navBarHeight, width: buttonWidth, height: buttonHeight))
        
        fontButton.backgroundColor = .white
        fontButton.titleLabel?.font = UIFont(name: selectedFont, size: 18)
        fontButton.setTitle(selectedFont, for: .normal)
        fontButton.setTitleColor(.black, for: .normal)
        fontButton.layer.cornerRadius = 5
        fontButton.layer.borderWidth = 1
        fontButton.layer.borderColor = UIColor.black.cgColor
        fontButton.layer.shadowColor = UIColor.white.cgColor
        fontButton.addTarget(self, action: #selector(fontChange(sender:)), for: .touchUpInside)
    
        self.view.addSubview(fontButton)
    }
    
    @objc func fontChange(sender: UIButton) {
        
        let buttonHeight: CGFloat = 40
        
        let viewHeight: CGFloat = buttonHeight * 4
        
        fontView = UIView(frame: CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y + sender.frame.height, width: sender.frame.width, height: viewHeight))
        
        fontView.clipsToBounds = true
        fontView.backgroundColor = .white
        fontView.layer.cornerRadius = 5
        fontView.layer.shadowColor = UIColor.white.cgColor
                
        /*
         Helvetica Font Button
         */
        let helveticaButton = UIButton(frame: CGRect(x: 0, y: 0, width: fontView.frame.width, height: buttonHeight))
        
        helveticaButton.setTitle("Helvetica", for: .normal)
        helveticaButton.setTitleColor(.black, for: .normal)
        helveticaButton.titleLabel?.font = UIFont(name: "Helvetica", size: 18)
        
        if (selectedFont == "Helvetica") {
            helveticaButton.backgroundColor = .lightGray
        } else {
            helveticaButton.backgroundColor = .white
        }
        
        helveticaButton.addTarget(self, action: #selector(fontHelvetica(sender:)), for: .touchUpInside)
        
        /*
         Georgia Font Button
         */
        let georgiaButton = UIButton(frame: CGRect(x: 0, y: buttonHeight, width: fontView.frame.width, height: buttonHeight))
        
        georgiaButton.setTitle("Georgia", for: .normal)
        georgiaButton.setTitleColor(.black, for: .normal)
        georgiaButton.titleLabel?.font = UIFont(name: "Georgia", size: 18)
        
        if (selectedFont == "Georgia") {
            georgiaButton.backgroundColor = .lightGray
        } else {
            georgiaButton.backgroundColor = .white
        }
        
        georgiaButton.addTarget(self, action: #selector(fontGeorgia(sender:)), for: .touchUpInside)
        
        /*
         Noteworthy Font Button
         */
        let noteworthyButton = UIButton(frame: CGRect(x: 0, y: buttonHeight * 2, width: fontView.frame.width, height: buttonHeight))
        
        noteworthyButton.setTitle("Noteworthy", for: .normal)
        noteworthyButton.setTitleColor(.black, for: .normal)
        noteworthyButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 18)
        
        if (selectedFont == "Noteworthy") {
            noteworthyButton.backgroundColor = .lightGray
        } else {
            noteworthyButton.backgroundColor = .white
        }
        
        noteworthyButton.addTarget(self, action: #selector(fontNoteworthy(sender:)), for: .touchUpInside)
        
        let fontSizeSlider = UISlider(frame: CGRect(x: 0, y: buttonHeight * 3, width: fontView.frame.width, height: buttonHeight))
        fontSizeSlider.minimumValue = 10
        fontSizeSlider.maximumValue = 36
        fontSizeSlider.isContinuous = true
        fontSizeSlider.tintColor = .green
        fontSizeSlider.setValue(fontSize, animated: true)
        fontSizeSlider.addTarget(self, action: #selector(fontSizeDidChange(sender:)), for: .valueChanged)
        
        fontView.addSubview(helveticaButton)
        fontView.addSubview(georgiaButton)
        fontView.addSubview(noteworthyButton)
        fontView.addSubview(fontSizeSlider)
        
        self.view.addSubview(fontView)

    }
    
    @objc func fontHelvetica(sender: UIButton) {
        
        fontView.removeFromSuperview()
        selectedFont = "Helvetica"
        changeFont(font: "Helvetica")
        updateFontButton(fontName: "Helvetica")
    }
    
    @objc func fontGeorgia(sender: UIButton) {
        
        fontView.removeFromSuperview()
        selectedFont = "Georgia"
        changeFont(font: "Georgia")
        updateFontButton(fontName: "Georgia")

    }
    
    @objc func fontNoteworthy(sender: UIButton) {
        
        fontView.removeFromSuperview()
        selectedFont = "Noteworthy"
        changeFont(font: "Noteworthy")
        updateFontButton(fontName: "Noteworthy")
    }
    
    func changeFont(font: String) {
        
        drawingView.userSettings.fontName = font
    }
    
    func updateFontButton(fontName: String) {
        
        fontButton.setTitle(fontName, for: .normal)
        fontButton.titleLabel?.font = UIFont(name: fontName, size: 18)
    }
    
    func removeFontButton() {
        fontButton.removeFromSuperview()
        fontButton.isHidden = true
    }
    
    func checkForFontButton() {
        if (editTypeSelected == .TEXT) {
            removeFontButton()
        }
    }
    
    @objc func fontSizeDidChange(sender: UISlider) {
        
    }
}


