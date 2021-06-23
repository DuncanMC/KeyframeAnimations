//
//  ViewController.swift
//  KeyframeAnimations
//
//  Created by Duncan Champney on 6/21/21.
//

import UIKit

extension UIView.KeyframeAnimationOptions {
    static var curveLinear: UIView.KeyframeAnimationOptions =
        UIView.KeyframeAnimationOptions(rawValue:UIView.AnimationOptions.curveLinear.rawValue)

    static var curveEaseInOut: UIView.KeyframeAnimationOptions =
        UIView.KeyframeAnimationOptions(rawValue:UIView.AnimationOptions.curveEaseInOut.rawValue)

    static var curveEaseIn: UIView.KeyframeAnimationOptions =
        UIView.KeyframeAnimationOptions(rawValue:UIView.AnimationOptions.curveEaseIn.rawValue)

    static var curveEaseOut: UIView.KeyframeAnimationOptions =
        UIView.KeyframeAnimationOptions(rawValue:UIView.AnimationOptions.curveEaseOut.rawValue)

    init(animationOptions: UIView.AnimationOptions) {
        self.init(rawValue: animationOptions.rawValue)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var viewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var animateButton: UIButton!
    @IBOutlet weak var viewToAnimate: UIView!
    @IBOutlet weak var animationParentView: UIView!

    @IBOutlet weak var timingCurveControl: UISegmentedControl!
    @IBOutlet weak var keyframeCurveControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func logAnimationStep(_ step: Int, point: CGPoint) {
        print("Animation step \(step) to point \(point)")
    }

    func animateBackToStart() {
        self.viewXConstraint.constant = 0
        self.viewYConstraint.constant = 0

        UIView.animate(withDuration: 1,
                       delay: 0.2,
                       options: [],
                       animations: {
                        self.logAnimationStep(5, point: CGPoint(x: 0, y: 0))
                        self.animationParentView.layoutIfNeeded()
                       }) { (finished) in
            self.animateButton.isEnabled = true
        }
    }

    @IBAction func handleAnimateButton(_ sender: UIButton) {
        sender.isEnabled = false
        let totalDuration: Double = 6.0
        let animationSteps = 3
        let animateViewSize = viewToAnimate.bounds.size
        let viewBounds = animationParentView.bounds
        let yStep = (viewBounds.height-animateViewSize.height) / CGFloat(animationSteps)
        let rightSideX = viewBounds.maxX - animateViewSize.width
        // UIView.AnimationOptions: curveLinear, curveEaseInOut, curveEaseIn, curveEaseOut
        // UIView.KeyframeAnimationOptions: calculationModeLinear, calculationModeCubicPaced
        var keyFrameOptions: UIView.KeyframeAnimationOptions {
            var options: UIView.KeyframeAnimationOptions = []
            switch timingCurveControl.selectedSegmentIndex {
            case 0: options = .curveLinear
            case 1: options = .curveEaseIn
            case 2: options = .curveEaseOut
            case 3: options = .curveEaseInOut
            default: break
            }
            switch keyframeCurveControl.selectedSegmentIndex {
            case 0: options.insert(.calculationModeLinear)
            case 1: options.insert(.calculationModeCubic)
            case 2: options.insert(.calculationModeCubicPaced)
            default: break
            }
            return options
        }
        UIView.animateKeyframes(withDuration: totalDuration * 5.0 / 6.0, delay: 0, options: keyFrameOptions, animations: {
            for index in 1...animationSteps {
                let newX = index.isMultiple(of: 2) ? 0 : rightSideX
                let newY = CGFloat(index) * yStep
                self.viewXConstraint.constant = newX
                self.viewYConstraint.constant = newY

                let startTime = Double(index-1) / Double(animationSteps)
                UIView.addKeyframe(withRelativeStartTime: startTime,
                                   relativeDuration: 1.0 / Double(animationSteps),
                                   animations: {
                                    self.logAnimationStep(index, point: CGPoint(x: newX, y: newY))
                                    self.animationParentView.layoutIfNeeded()
                                   }
                )
            }
        },
        completion: { finished in
            self.animateBackToStart()
        }
        )
    }
}

