//
//  ViewController.swift
//  Waltr
//
//  Created by Pavel B on 12/18/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Private properties

    var radarView: RadarView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        radarView = RadarView(frame: CGRect.zero)
        radarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(radarView)
        let c1 = radarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let c2 = radarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        let c3 = radarView.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        let c4 = radarView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        NSLayoutConstraint.activate([c1, c2, c3, c4])
    }

    // MARK: - IBActions
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            radarView.bouncingType = .still
        case 1:
            radarView.bouncingType = .inbound
        case 2:
            radarView.bouncingType = .outbound
        default:
            radarView.bouncingType = .still
        }
    }
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            radarView.mode = .search
        case 1:
            radarView.mode = .device
        default:
            radarView.mode = .search
        }
        
    }

}
