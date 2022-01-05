//
//  SDWebImage+Concurrency.swift
//  Allie
//
//  Created by Waqar Malik on 12/23/21.
//

import SDWebImage
import UIKit

extension SDImageCache {
	func store(image: UIImage?, forKey: String?, toDisk: Bool) async -> UIImage? {
		await withCheckedContinuation { checkedContinuation in
			self.store(image, forKey: forKey, toDisk: toDisk) {
				checkedContinuation.resume(returning: image)
			}
		}
	}
}
