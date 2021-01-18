//
//  GridTaskViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitUI
import UIKit

class GridTaskViewController: OCKGridTaskViewController {
	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}
