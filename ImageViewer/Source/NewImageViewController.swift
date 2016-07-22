//
//  NewImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class NewImageViewController: UIViewController, ItemController {

    let index: Int
    var delegate: ItemControllerDelegate?
    var displacedViewsDatasource: GalleryDisplacedViewsDatasource?
    var isInitialController = false
    let fetchImage: FetchImage

    //CONFIGURATION
    private var displacementDuration: NSTimeInterval = 0.6
    private var displacementTimingCurve: UIViewAnimationCurve = .Linear
    private var displacementSpringBounce: CGFloat = 0.7
    private var overlayAccelerationFactor: CGFloat = 1

    var imageView = UIImageView()

    init(index: Int, fetchImageBlock: FetchImage, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.index = index
        self.fetchImage = fetchImageBlock
        self.isInitialController = isInitialController

        for item in configuration {

            switch item {

            case .DisplacementDuration(let duration):       displacementDuration = duration
            case .DisplacementTimingCurve(let curve):       displacementTimingCurve = curve
            case .OverlayAccelerationFactor(let factor):    overlayAccelerationFactor = factor

            case .DisplacementTransitionStyle(let style):

            switch style {

                case .SpringBounce(let bounce):             displacementSpringBounce = bounce
                case .Normal:                               displacementSpringBounce = 1
                }

            default: break
            }
        }

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .Custom

        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dismissRecognizer.numberOfTapsRequired = 1

        self.view.addGestureRecognizer(dismissRecognizer)

        self.imageView.hidden = isInitialController
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImage { [weak self] image in

            if let image = image {

                self?.imageView.image = image
                self?.imageView.bounds.size = aspectFitContentSize(forBoundingSize: self!.view.bounds.size, contentSize: image.size)
                self?.imageView.center = self!.view.boundsCenter

                self?.view.addSubview(self!.imageView)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func presentItem(alongsideAnimation alongsideAnimation: Duration -> Void) {

        //Get the displaced view
        guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
            let image = displacedView.image else { return }

        //Prepare the animated image view
        let animatedImageView = displacedView.clone()
        animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
        animatedImageView.clipsToBounds = true
        self.view.addSubview(animatedImageView)

        displacedView.hidden = true

        alongsideAnimation(displacementDuration * Double(overlayAccelerationFactor))

        UIView.animateWithDuration(displacementDuration, delay: 0, usingSpringWithDamping: displacementSpringBounce, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

            if UIApplication.isPortraitOnly == true {
                animatedImageView.transform = rotationTransform()
            }
            /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

            let boundingSize = rotationAdjustedBounds().size
            let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)

            animatedImageView.bounds.size = aspectFitSize
            animatedImageView.center = self.view.boundsCenter

            }, completion: { _ in

                self.imageView.hidden = false
                self.imageView  = animatedImageView
        })
    }
    
    func dismiss() {
        
        self.delegate?.dismiss()
    }
}


