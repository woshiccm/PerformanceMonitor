//
//  PerformanceViewController.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/26.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit

class PerformanceViewController: UIViewController {

    enum Constants {
        static let infoButtonWidthConstraint: CGFloat = 90
        static let infoButtonHeightConstraint: CGFloat = 50
        static let infoButtonCornerRadius: CGFloat = 12
        static let delta: CGFloat = 2.0
    }

    private var isShow = false
    private weak var transitionContext: UIViewControllerContextTransitioning!

    private var originalCenter = CGPoint.zero

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.init(name: "Menlo", size: 8.0)
        label.backgroundColor = .black
        label.layer.cornerRadius = Constants.infoButtonCornerRadius
        label.layer.masksToBounds = true
        label.textColor = .green
        label.isUserInteractionEnabled = true
        label.numberOfLines = 3
        label.textAlignment = .center
        label.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPanInfoLabel(_:))))
        return label
    }()

    lazy var fpsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.init(name: "Menlo", size: 8.0)
        label.backgroundColor = .black
        label.textColor = .green
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    func configureTitle(_ title: String) {
        infoLabel.text = title
    }

    func configureFPS(_ fps: Double) {
        fpsLabel.text = "FPS: \(String.init(format: "%.1f", fps))"

        if fps > 55.0 {
            fpsLabel.textColor = .green
        } else if (fps >= 50.0 && fps <= 55.0) {
            fpsLabel.textColor = .yellow
        } else {
            fpsLabel.textColor = .red
        }
    }

    override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.delegate?.window??.rootViewController?.prefersStatusBarHidden ?? false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.delegate?.window??.rootViewController?.preferredStatusBarStyle ?? .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(infoLabel)
        infoLabel.addSubview(fpsLabel)

        NSLayoutConstraint.activate([
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.delta),
            infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -52),
            infoLabel.widthAnchor.constraint(equalToConstant: Constants.infoButtonWidthConstraint),
            infoLabel.heightAnchor.constraint(equalToConstant: Constants.infoButtonHeightConstraint),

            fpsLabel.centerXAnchor.constraint(equalTo: infoLabel.centerXAnchor),
            fpsLabel.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: -5),
            fpsLabel.widthAnchor.constraint(equalTo: infoLabel.widthAnchor, constant: -5),
            fpsLabel.heightAnchor.constraint(equalToConstant: Constants.infoButtonHeightConstraint/3)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if originalCenter != .zero {
            infoLabel.center = originalCenter
        }
    }

    @objc dynamic private func onPanInfoLabel(_ panGesture: UIPanGestureRecognizer) {
        let offset = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)

        var center = infoLabel.center
        center.x += offset.x
        center.y += offset.y
        infoLabel.center = center

        guard panGesture.state == .ended || panGesture.state == .cancelled else { return }

        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.snapInfoLabelToSocket()
        }
    }

    private func snapInfoLabelToSocket() {
        enum Direction: Int {
            case top, left, bottom, right
        }

        let viewSize = view.bounds.size
        var center = infoLabel.center
        let width = infoLabel.bounds.size.width
        let height = infoLabel.bounds.size.height
        let distances = [center.y, center.x, viewSize.height - center.y, viewSize.width - center.x]

        for (idx, distance) in distances.enumerated() {
            if distance != distances.min() {
                continue
            }

            let direction = Direction(rawValue: idx)!

            switch direction {
            case .top: center = CGPoint(x: center.x, y: height / 2 + Constants.delta)
            case .left: center = CGPoint(x: width / 2 + Constants.delta, y: center.y)
            case .bottom: center = CGPoint(x: center.x, y: viewSize.height - height / 2 - Constants.delta)
            case .right: center = CGPoint(x: viewSize.width - width / 2 - Constants.delta, y: center.y)
            }
        }

        infoLabel.center = center
        originalCenter = center
    }
}

// MARK: - Transition
extension PerformanceViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isShow = true
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        isShow = false
    }
}

extension PerformanceViewController: UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }

        fromVC.view.frame = transitionContext.initialFrame(for: fromVC)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)

        animatePresentingTransition(from: fromVC, to: toVC)
    }

    private func animatePresentingTransition(from fromVC: UIViewController, to toVC: UIViewController) {
        let containerView = transitionContext.containerView
        let fromView = fromVC.view!
        let toView = toVC.view!

        let point = containerView.center
        let radius = CGFloat(sqrtf(powf(Float(point.x), 2) + powf(Float(point.y), 2)))
        let startPath = UIBezierPath(arcCenter: containerView.center, radius: 0.01, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath
        let endPath = UIBezierPath(arcCenter: containerView.center, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath
        let maskLayer = CAShapeLayer(layer: startPath)

        let animationDuration = transitionDuration(using: transitionContext)
        let circleAnimation = CABasicAnimation(keyPath: "path")
        circleAnimation.duration = animationDuration
        // Avoid screen flash
        circleAnimation.isRemovedOnCompletion = false
        circleAnimation.fillMode = CAMediaTimingFillMode.both

        if isShow {
            containerView.addSubview(toView)
            toView.layer.mask = maskLayer
            circleAnimation.fromValue = startPath
            circleAnimation.toValue = endPath
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
            fromView.layer.mask = maskLayer
            circleAnimation.fromValue = endPath
            circleAnimation.toValue = startPath
        }
        maskLayer.add(circleAnimation, forKey: "cirleAnimation")

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            fromView.layer.mask = nil
            toView.layer.mask = nil
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
        }
    }
}
