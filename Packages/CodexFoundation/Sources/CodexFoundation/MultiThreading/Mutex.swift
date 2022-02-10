//
//  MutexLock.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation

public final class Mutex {
	private var mutex: pthread_mutex_t = {
		var mutex = pthread_mutex_t()
		pthread_mutex_init(&mutex, nil)
		return mutex
	}()

	public init() {}

	public func lock() {
		pthread_mutex_lock(&mutex)
	}

	public func unlock() {
		pthread_mutex_unlock(&mutex)
	}
}
