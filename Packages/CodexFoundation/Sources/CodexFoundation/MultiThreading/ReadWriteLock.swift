//
//  ReadWriteLock.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation

public final class ReadWriteLock {
	public init() {}

	private var rwlock: pthread_rwlock_t = {
		var rwlock = pthread_rwlock_t()
		pthread_rwlock_init(&rwlock, nil)
		return rwlock
	}()

	public func writeLock() {
		pthread_rwlock_wrlock(&rwlock)
	}

	public func readLock() {
		pthread_rwlock_rdlock(&rwlock)
	}

	public func unlock() {
		pthread_rwlock_unlock(&rwlock)
	}
}
