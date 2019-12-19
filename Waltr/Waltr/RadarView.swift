//
//  RadarView.swift
//  Waltr
//
//  Created by Pavel B on 12/18/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation
import UIKit

enum BouncingType {
    case still
    case inbound
    case outbound
}

enum Mode {
    case search
    case device
}

class RadarView: UIView, CAAnimationDelegate {
    
    // MARK: - Private properties
    
    private var circles: [CAGradientLayer] = []
    private var circlesCount = 13
    private let stepDistance = 30.0
    private let stepRotation = 5.0
    private var initialViewTransform: CGAffineTransform!
    
    // MARK: - Public properties
    
    var bouncingType = BouncingType.still {
        didSet {
            startAnimation(self.bouncingType)
        }
    }
    var mode = Mode.search {
        didSet {
            updateMode(self.mode)
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.removeAllAnimations()
        circles.forEach {$0.removeAllAnimations()}
        circles.forEach {$0.removeFromSuperlayer()}
        circles.removeAll()
        
        setupSublayers()
        
        layer.rasterizationScale = UIScreen.main.scale
        initialViewTransform = self.transform
    }
    
    // MARK: - CAAnimationDelegate
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.startAnimation(self.bouncingType)
        }
    }
    
    // MARK: - Private implementation
    
    private func initialTransform(at index: Int) -> CATransform3D {
        let transform = CATransform3DIdentity
        
        let degree = 90.0 - stepRotation*Double(index)
        let radians = CGFloat(degree*Double.pi/180)
        return CATransform3DRotate(transform, radians, 0.0, 0.0, -1.0)
    }
    
    private func opacity(at index: Int) -> Float {
        return Float(1.0 - (1.0 / Double(circlesCount)) * Double(index))
    }
    
    private func setupSublayers() {
        for i in 0..<circlesCount {
            let width = bounds.size.width/2 + CGFloat(Double(i)*stepDistance)
            let height = bounds.size.height/2 + CGFloat(Double(i)*stepDistance)
            let x = (bounds.size.width - width) / 2.0
            let y = (bounds.size.height - height) / 2.0
            
            let circleLayer = CAShapeLayer()
            circleLayer.rasterizationScale = UIScreen.main.scale
            circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: width, height: height).insetBy(dx: 1, dy: 1)).cgPath
            circleLayer.strokeColor = UIColor.blue.cgColor
            circleLayer.fillColor = UIColor.clear.cgColor
        
            let gradientLayer = CAGradientLayer()
            gradientLayer.rasterizationScale = UIScreen.main.scale
            gradientLayer.frame = CGRect(x: x, y: y, width: width, height: height)
            gradientLayer.mask = circleLayer
            gradientLayer.colors = [UIColor.init(red: 50.0/255.0, green: 120.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor, UIColor.init(red: 20.0/255.0, green: 180.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor, UIColor.init(red: 250.0/255.0, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1.0).cgColor, UIColor.init(red: 255.0/255.0, green: 145.0/255.0, blue: 70.0/255.0, alpha: 1.0).cgColor]
            
            gradientLayer.transform = initialTransform(at: i)
            gradientLayer.opacity = opacity(at: i)
            
            circles.append(gradientLayer)
            self.layer.addSublayer(gradientLayer)
        }
    }
    
    private func updateMode(_ mode: Mode) {
        switch mode {
        case .search:
            UIView.animate(withDuration: 1) {
                self.transform = self.initialViewTransform
            }
        case .device:
            UIView.animate(withDuration: 1) {
                self.transform = CGAffineTransform(scaleX: 3, y: 3).concatenating(CGAffineTransform(translationX: 0, y: self.bounds.height))
            }
        }
    }
    
    private func stopAnimation() {
        bouncingType = .still

        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func startAnimation(_ type: BouncingType) {
        if bouncingType != type {
            stopAnimation()
        }
        if bouncingType == .still {
            return
        }
        
        for i in 0..<circles.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(i*300)) {
                var scale = 0.0
                var index = i
                var lastIndex = 0
                switch self.bouncingType {
                    case .still:
                        return
                    case .inbound:
                        scale = 0.98
                        index = self.circlesCount - index - 1
                        lastIndex = 0
                    case .outbound:
                        scale = 1.02
                        lastIndex = self.circlesCount - 1
                }
                let circle = self.circles[index]
                
                CATransaction.begin()
                
                let scaleTransform = CATransform3DScale(circle.transform, CGFloat(scale), CGFloat(scale), 0.0)
                let scaleTransformAnimation = CABasicAnimation(keyPath: "transform")
                scaleTransformAnimation.autoreverses = true
                scaleTransformAnimation.toValue = NSValue(caTransform3D: scaleTransform)
                scaleTransformAnimation.duration = 1;
                if index == lastIndex {
                    scaleTransformAnimation.delegate = self
                }
                circle.add(scaleTransformAnimation, forKey: "transform")
                
                let opacityAnimation = CABasicAnimation(keyPath:"opacity")
                opacityAnimation.fromValue = circle.opacity
                opacityAnimation.toValue = 1.0
                opacityAnimation.autoreverses = true
                opacityAnimation.duration = 1
                circle.add(opacityAnimation, forKey: "opacity")
                
                CATransaction.commit()
            }
        }
    }
    
}
