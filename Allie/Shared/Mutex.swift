//
//  MutexLock.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation

final class Mutex {
	private var mutex: pthread_mutex_t = {
		var mutex = pthread_mutex_t()
		pthread_mutex_init(&mutex, nil)
		return mutex
	}()

	func lock() {
		pthread_mutex_lock(&mutex)
	}

	func unlock() {
		pthread_mutex_unlock(&mutex)
	}
}
