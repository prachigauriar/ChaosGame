//
//  EditingContext.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/26/2019.
//  Copyright © 2019 Prachi Gauriar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import Foundation
import SwiftUI


final class EditingContext<Value> : BindableObject {
    let didChange = PassthroughSubject<EditingContext<Value>, Never>()
    private let didSave = PassthroughSubject<Value, Never>()
    lazy private(set) var savePublisher: AnyPublisher = {
        didSave.eraseToAnyPublisher()
    }()


    init(_ value: Value, draft: Value? = nil) {
        self.value = value
        self.draft = draft ?? value
    }


    var isEditing: Bool = false {
        didSet {
            didChange.send(self)
        }
    }


    var draft: Value {
        didSet {
            didChange.send(self)
        }
    }


    var value: Value {
        didSet {
            didChange.send(self)
        }
    }


    func save() {
        value = draft
        didSave.send(value)
    }


    func discard() {
        draft = value
    }
}
