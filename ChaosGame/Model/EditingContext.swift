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


/// `EditingContext`s provide minimal structure so that a value can be edited as a draft and then explictly saved or
/// discarded. It is meant primarily to act as a model for views that provide an editing interface for some specific
/// type of value.
public final class EditingContext<Value> : ObservableObject {
    /// Whether the value is being edited. This should be set to `true` when an editing interface is being displayed.
    @Published public var isEditing = false

    /// The current value.
    @Published public private(set) var value: Value

    /// The draft value being edited. Editing interfaces should work this value exclusively.
    @Published public var draft: Value


    /// Creates a new `EditingContext` for the specified value and draft.
    ///
    /// - Parameters:
    ///   - value: The value to edit.
    ///   - draft: The draft that should be used when editing. If `nil`, `value` will be used. Note that this only makes
    ///     sense for value types. If your value is a mutable reference type, you should provide a different reference
    ///     as the draft.
    public init(_ value: Value, draft: Value? = nil) {
        self.value = value
        self.draft = draft ?? value
    }


    /// Saves the current draft by overwriting the current value with the draft value.
    public func save() {
        value = draft
    }


    /// Discards the current draft by overwriting the draft value with the current value.
    public func discard() {
        draft = value
    }
}
