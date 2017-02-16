//
//  ViewController.swift
//  BrachistochroneDemo
//
//  Created by liaojinhua on 2017/2/16.
//  Copyright © 2017年 Daisy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    let gravity = UIGravityBehavior()
    let collision = UICollisionBehavior()
    var animator:UIDynamicAnimator?
    
    let xOffset:CGFloat = 50
    let gap:CGFloat = 40
    let pathHeight:CGFloat = (UIScreen.main.bounds.height - 64 - 95 - 40 - 40 )/3 - 20
    
    var balls = [Ball]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBorder()
        
        self.title = "最速降线"
        
        let width = UIScreen.main.bounds.width - 80 - 25
        var yOffset:CGFloat = 10 + 40
        
        for index in 0..<3 {
            
            addBall(index:index)
            
            let startPoint = CGPoint(x:xOffset, y:yOffset)
            let endPoint = CGPoint(x:width + xOffset, y:yOffset + pathHeight)
            
            collision.addBoundary(withIdentifier: self.pathIdentifierAt(index: index) as NSCopying, for: self.pathAtIndex(index:index, startPoint: startPoint, endPoint: endPoint))
            
            collision.addBoundary(withIdentifier: self.lineIdentifierAt(index: index) as NSCopying, from: CGPoint(x:endPoint.x,y:startPoint.y), to: endPoint)
            yOffset += pathHeight + gap
        }
        
        collision.translatesReferenceBoundsIntoBoundary = true
        collision.collisionDelegate = self
        self.animator = UIDynamicAnimator(referenceView: self.view)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAction(UIButton())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func startAction(_ sender: Any) {
        
        for (index, ball) in balls.enumerated() {
            ball.center = self.ballPositionAtIndex(index: index)
            self.gravity.addItem(ball)
            self.collision.addItem(ball)
        }
        self.animator?.addBehavior(gravity)
        self.animator?.addBehavior(collision)
    }
    
    func pathIdentifierAt(index:Int) -> NSCopying {
        return ("BeziperPath" + "\(index)") as NSCopying
    }
    func lineIdentifierAt(index:Int) -> NSCopying {
        return ("VerticalLine" + "\(index)") as NSCopying
    }
    
    func addBorder() {
        self.firstView.layer.borderWidth = 2.0
        self.firstView.layer.borderColor = UIColor.gray.cgColor
        
        self.secondView.layer.borderWidth = 2.0
        self.secondView.layer.borderColor = UIColor.gray.cgColor
        
        self.thirdView.layer.borderWidth = 2.0
        self.thirdView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func addShapeLayerWithPath(path:UIBezierPath) {
        let pathLayer = CAShapeLayer();
        pathLayer.path = path.cgPath;
        pathLayer.fillColor = UIColor.clear.cgColor;
        pathLayer.strokeColor = UIColor(hexValue:0xf27b9a).cgColor
        pathLayer.lineWidth = 2.0;
        self.view.layer.addSublayer(pathLayer)
    }
    
    let ballSize:CGFloat = 20
    func addBall(index:Int) {
        let ball = Ball(image: UIImage(named: "ball"))
        ball.frame = CGRect(x:0, y:0, width:ballSize, height:ballSize)
        ball.center = self.ballPositionAtIndex(index: index)
        self.view.addSubview(ball)
        self.balls.append(ball)
    }
    
    func ballPositionAtIndex(index:Int) -> CGPoint {
        var point = CGPoint(x:xOffset + ballSize/2, y: CGFloat(index) * (pathHeight + gap) + 50)
        if index == 0 {
            point.y -= 7
        }
        return point
    }
    
    func pathAtIndex(index:Int, startPoint:CGPoint, endPoint:CGPoint) -> UIBezierPath {
        if index == 0 {
            return self.straightPath(startPoint: startPoint, endPoint: endPoint)
        } else if index == 1 {
            return self.curvePath1(startPoint: startPoint, endPoint: endPoint)
        }
        return self.curvePath2(startPoint: startPoint, endPoint: endPoint)
    }
    
    func straightPath(startPoint:CGPoint, endPoint:CGPoint) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)
        addShapeLayerWithPath(path: bezierPath)
        return bezierPath
    }
    
    func curvePath1(startPoint:CGPoint, endPoint:CGPoint) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: startPoint)
        
        bezierPath.addQuadCurve(to: endPoint, controlPoint: CGPoint(x:xOffset + 50.0, y:endPoint.y))
        bezierPath.addQuadCurve(to: startPoint, controlPoint: CGPoint(x:xOffset + 50.0, y:endPoint.y))
        addShapeLayerWithPath(path: bezierPath)
        
        return bezierPath
    }
    
    func curvePath2(startPoint:CGPoint, endPoint:CGPoint) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: startPoint)
        
        bezierPath.addCurve(to: endPoint, controlPoint1: CGPoint(x:xOffset + 5.0, y:endPoint.y - 5), controlPoint2: CGPoint(x:xOffset + 15.0, y:endPoint.y))
        bezierPath.addCurve(to: startPoint, controlPoint1: CGPoint(x:xOffset + 15.0, y:endPoint.y), controlPoint2: CGPoint(x:xOffset + 5.0, y:endPoint.y - 5))
        addShapeLayerWithPath(path: bezierPath)
        
        return bezierPath
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        let ball = item as! Ball
        let index = balls.index(of: ball)
        if identifier as! String == self.lineIdentifierAt(index: index!) as! String {
            self.gravity.removeItem(item)
            self.collision.removeItem(ball)
            if self.gravity.items.count == 0 {
                self.animator?.removeBehavior(gravity)
                self.animator?.removeBehavior(collision)
            }
        }
    }
}

class Ball:UIImageView {
    @available(iOS 9.0, *)
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

extension UIColor {
    public convenience init(hexValue:NSInteger) {
        self.init(red: (CGFloat)((hexValue & 0xFF0000) >> 16)/255.0, green: (CGFloat)((hexValue & 0xFF00) >> 8)/255.0, blue: (CGFloat)(hexValue & 0xFF)/255.0, alpha: 1)
    }
}

