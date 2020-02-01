// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

/**
 This structure holds the display parameters for the overlay to be drawon on a detected object.
 */
struct ObjectOverlay {
  let name: String
  let borderRect: CGRect
  let nameStringSize: CGSize
  let color: UIColor
  let font: UIFont
}

/**
 This UIView draws overlay on a detected object.
 */
class OverlayView: UIView {

  var objectOverlays: [ObjectOverlay] = []
  private let cornerRadius: CGFloat = 10.0
  private let stringBgAlpha: CGFloat
    = 0.7
  private let lineWidth: CGFloat = 3
  private let stringFontColor = UIColor.white
  private let stringHorizontalSpacing: CGFloat = 13.0
  private let stringVerticalSpacing: CGFloat = 7.0
    
  var lines: [UIBezierPath] = []
  let line = UIBezierPath()
  var x_axis: CGFloat = 0
  var y_axis: CGFloat = 0
  var preNodeX: CGFloat = -1
  var preNodeY: CGFloat = -1
    
  @IBOutlet weak var resultLabel: UILabel!
  var classifier: DigitClassifier?
    
    
    func initClassifier(){
        DigitClassifier.newInstance { result in
          switch result {
          case let .success(classifier):
            self.classifier = classifier
          case .error(_):
            self.resultLabel.text = "Failed to initialize."
          }
        }
    }

  override func draw(_ rect: CGRect) {
        

    // Drawing code
    for objectOverlay in objectOverlays {

      drawBorders(of: objectOverlay)
      drawBackground(of: objectOverlay)
      drawName(of: objectOverlay)
        
        if objectOverlays.count >  2{
            self.resetAll()
        }
        else if objectOverlays.count == 2{
            reset()
        }
        else if objectOverlays.count == 1 {
            let x = objectOverlay.borderRect.origin.x
            let y = objectOverlay.borderRect.origin.y
            if preNodeX != -1 && (x != preNodeX || y != preNodeY){
               graph(of: x, of: y)
                
            }
            else{
                line.move(to: CGPoint(x:x, y:y))
              }
            preNodeX = x
            preNodeY = y
        }
    }
    if objectOverlays.count == 0 {
        reset()
    }
    classifyDrawing()
    UIColor.black.setStroke()
    line.stroke()
    
  }
    
    func resetAll(){
        preNodeX = -1
        preNodeY = -1
        line.removeAllPoints()
    }
    
    func reset(){
        preNodeX = -1
        preNodeY = -1
        
    }
    // Get UIImage
    func image() -> UIImage {
        let imageWidth: CGFloat = bounds.width
        let imageHeight: CGFloat = bounds.height*0.76
        
        let p = UIBezierPath()
        p.move(to: CGPoint(x:0, y:imageHeight))
        p.addLine(to: CGPoint(x: imageWidth, y: imageHeight))
        p.stroke()
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        let path = line
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.yellow.setStroke()
            path.lineWidth = 10
            path.stroke()
        }
    }

    
    func graph(of x: CGFloat, of y: CGFloat){
        
        line.addLine(to: .init(x: x, y: y))
        UIColor.black.setStroke()
        line.lineWidth = 10
        
        
  }
    
     private func classifyDrawing(){
        guard let classifier = self.classifier else { return }
        
        // Capture drawing to RGB file.
        let size = CGSize(width: 112, height: 112)
        var drawing = image()
        drawing = drawing.resize(targetSize: size)
        
        
        // UIImageWriteToSavedPhotosAlbum(drawing,nil,nil,nil);
    //    guard drawing != nil else {
    //      resultLabel.text = "Invalid drawing."
    //      return
    //    }

        // Run digit classifier.
        classifier.classify(image: drawing) { result in
          // Show the classification result on screen.
          switch result {
          case let .success(classificationResult):
    //        self.resultLabel.text = classificationResult
            if self.resultLabel != nil {
                    print("Contains a value!")
                } else {
                    
                }
          case .error(_):
            self.resultLabel.text = "Failed to classify drawing."
          }
        }
        
      }

  /**
   This method draws the borders of the detected objects.
   */
  func drawBorders(of objectOverlay: ObjectOverlay) {

    let path = UIBezierPath(rect: objectOverlay.borderRect)
    path.lineWidth = lineWidth
    objectOverlay.color.setStroke()

    path.stroke()
  }

  /**
   This method draws the background of the string.
   */
  func drawBackground(of objectOverlay: ObjectOverlay) {

    let stringBgRect = CGRect(x: objectOverlay.borderRect.origin.x, y: objectOverlay.borderRect.origin.y , width: 2 * stringHorizontalSpacing + objectOverlay.nameStringSize.width, height: 2 * stringVerticalSpacing + objectOverlay.nameStringSize.height
    )

    let stringBgPath = UIBezierPath(rect: stringBgRect)
    objectOverlay.color.withAlphaComponent(stringBgAlpha).setFill()
    stringBgPath.fill()
  }

  /**
   This method draws the name of object overlay.
   */
  func drawName(of objectOverlay: ObjectOverlay) {

    // Draws the string.
    let stringRect = CGRect(x: objectOverlay.borderRect.origin.x + stringHorizontalSpacing, y: objectOverlay.borderRect.origin.y + stringVerticalSpacing, width: objectOverlay.nameStringSize.width, height: objectOverlay.nameStringSize.height)

    let attributedString = NSAttributedString(string: objectOverlay.name, attributes: [NSAttributedString.Key.foregroundColor : stringFontColor, NSAttributedString.Key.font : objectOverlay.font])
    attributedString.draw(in: stringRect)
  }

}
