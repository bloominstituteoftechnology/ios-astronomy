//
//  SolSelectViewController.swift
//  Astronomy
//
//  Created by Marlon Raskin on 9/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol SolSelectViewControllerDelegate: AnyObject {
	func didSelect(solarDay: Int)
}

class SolSelectViewController: UIViewController {

	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var sliderValueLabel: UILabel!

	var sliderValue: Int?

	override func viewDidLoad() {
        super.viewDidLoad()
		sliderValueLabel.text = "\(Int(slider.value))"
    }

	weak var delegate: SolSelectViewControllerDelegate?

	@IBAction func cancelTapped(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	@IBAction func sliderChanged(_ sender: UISlider) {
		sliderValueLabel.text = String(format: "%i",Int(sender.value))
//		sender.setValue(sender.value.rounded(.down), animated: true)
//		print(sender.value)
//		sliderValueLabel.text = "\(slider.value)"
		sliderValue = Int(sender.value)
	}

	@IBAction func selectTapped(_ sender: UIButton) {
		delegate?.didSelect(solarDay: Int(slider?.value ?? 300))
		dismiss(animated: true, completion: nil)
	}
}
