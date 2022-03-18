//
//  File.swift
//
//
//  Created by Waqar Malik on 2/12/22.
//

import Foundation

public typealias VoidCompletionHandler = () -> Void
public typealias BoolCompletionHandler = (Bool) -> Void
public typealias ResultCompletionHandler<T> = (Result<T, Error>) -> Void
