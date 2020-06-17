
import Foundation
import Charts

public class CustomYAxisRenderer : YAxisRenderer {
    
    public override func renderGridLines(context: CGContext) {
           super.renderGridLines(context: context)
           
           renderLimitArea(context: context)
    }
    
    public func transformedLimitPositions() -> [CGPoint] {
        guard
            let yAxis = self.axis as? YAxis,
            let transformer = self.transformer
            else { return [CGPoint]() }
        
        var positions = [CGPoint]()
        positions.reserveCapacity(yAxis.limitLines.count)
        
    
        let limitLines = yAxis.limitLines

        for i in stride(from: 0, to: yAxis.limitLines.count, by: 1)
        {
            positions.append(CGPoint(x: 0.0, y: limitLines[i].limit))
        }
        
        transformer.pointValuesToPixel(&positions)
        
        return positions
    }
    
    public func renderLimitArea(context: CGContext) {
        guard let
            yAxis = self.axis as? YAxis
            else { return }
        
        if !yAxis.isEnabled {
            return
        }
        if yAxis.limitLines.count > 1 {
            var limitPositions = transformedLimitPositions()
            
            let viewPortHandler = self.viewPortHandler
           
            var width =  (viewPortHandler.contentBottom) - (viewPortHandler.contentTop)
            if limitPositions.count > 1 {
                width = abs(limitPositions[0].y -  limitPositions[1].y)
            }
            
            context.saveGState()
            defer { context.restoreGState() }
            context.clip(to: self.gridClippingRect)
            

            context.setShouldAntialias(yAxis.gridAntialiasEnabled)
            context.setStrokeColor(yAxis.gridColor.cgColor)
            context.setLineWidth(yAxis.gridLineWidth)
            context.setLineCap(yAxis.gridLineCap)
            
            if yAxis.gridLineDashLengths != nil {
                context.setLineDash(phase: yAxis.gridLineDashPhase, lengths: yAxis.gridLineDashLengths)
            }
            else {
                context.setLineDash(phase: 0.0, lengths: [])
            }
        
            for i in stride(from: 0, to: limitPositions.count, by: 2){
                let currentColor = getColor(index: i)
                context.setStrokeColor(currentColor)
                context.setLineWidth(width)
                context.beginPath()
                context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: (limitPositions[i].y + limitPositions[i+1].y)/2))
                context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y:  (limitPositions[i].y + limitPositions[i+1].y)/2))
                context.strokePath()
            }
        }
    }
    
//    func getColor(index : Int) -> CGColor{
//        var color:CGColor
//        color = UIColor.systemPink.withAlphaComponent(0.2).cgColor
//       return color
//    }

    
    func getColor(index : Int) -> CGColor{
           var color:CGColor
           color = UIColor.systemPurple.withAlphaComponent(0.2).cgColor
          return color
       }

    
    
}

    
    
//
//       func getColor(index : Int) -> CGColor{
//           var color:CGColor
//
//           if index == 0 {
//            color = UIColor.clear.withAlphaComponent(0.2).cgColor
//           }else {
//            color = UIColor.clear.withAlphaComponent(0.2).cgColor
//           }
//           print(color.alpha)
//           return color
//       }







    
