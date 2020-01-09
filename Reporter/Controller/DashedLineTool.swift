//
//  DashedLineTool.swift
//  Reporter
//
//  Created by Grant Singleton on 1/9/20.
//  Copyright © 2020 Grant Singleton. All rights reserved.
//

import Foundation
import Drawsana

public class DashedLineTool: DrawingTool {
    
    struct AddShapeOperation: DrawingOperation {
        
        func shouldAdd(to operationStack: DrawingOperationStack) -> Bool {
            return true
        }
        
        let shape: Shape
        
        func apply(drawing: Drawing) {
            drawing.add(shape: shape)
        }
        
        func revert(drawing: Drawing) {
            drawing.remove(shape: shape)
        }
    }
    
    public var name: String { return "DashedLineTool" }
    public var shapeInProgress: LineShape?
    public var isProgressive: Bool { return false }
    
    public init() {}
    
    public func handleTap(context: ToolOperationContext, point: CGPoint) {
        
    }
    
    public func handleDragStart(context: ToolOperationContext, point: CGPoint) {
        let dashedLineShape = LineShape()
        dashedLineShape.dashPhase = 5
        dashedLineShape.dashLengths = [15]
        shapeInProgress = dashedLineShape
        shapeInProgress?.a = point
        shapeInProgress?.b = point
        shapeInProgress?.apply(userSettings: context.userSettings)
    }
    
    public func handleDragContinue(context: ToolOperationContext, point: CGPoint, velocity: CGPoint) {
        shapeInProgress?.b = point
    }
    
    public func handleDragEnd(context: ToolOperationContext, point: CGPoint) {
        guard let shape = shapeInProgress else { return }
        shape.b = point
        context.operationStack.apply(operation: AddShapeOperation(shape: shape))
        shapeInProgress = nil
    }
    
    public func handleDragCancel(context: ToolOperationContext, point: CGPoint) {
        // No such thing as a cancel for this tool. If this was recognized as a tap,
        // just end the shape normally.
        handleDragEnd(context: context, point: point)
    }
    
    public func renderShapeInProgress(transientContext: CGContext) {
        shapeInProgress?.render(in: transientContext)
    }
    
    public func apply(context: ToolOperationContext, userSettings: UserSettings) {
        shapeInProgress?.apply(userSettings: userSettings)
        context.toolSettings.isPersistentBufferDirty = true
    }
    
}
