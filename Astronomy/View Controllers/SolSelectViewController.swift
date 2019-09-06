//
//  SolSelectViewController.swift
//  Astronomy
//
//  Created by Marlon Raskin on 9/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol SolSelectViewControllerDelegate {
	func didSelect(solarDay: Int)
}

class SolSelectViewController: UIViewController {

	@IBOutlet weak var slider: UISlider!

	override func viewDidLoad() {
        super.viewDidLoad()
    }

	var delegate: SolSelectViewControllerDelegate?

	@IBAction func cancelTapped(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func selectTapped(_ sender: UIButton) {

	}
}
