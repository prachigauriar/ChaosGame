//
//  PlotView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/24/2019.
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

import Foundation
import SceneKit
import SwiftUI


struct PlotView : View {
    let scene: SCNScene
    let pointCount: Int

    private static let pointCountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        return formatter
    }()


    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneKitView(scene: scene)
                .edgesIgnoringSafeArea(.all)
            (Text("Points: ").fontWeight(.heavy) + Text(formattedPointCount))
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
        }
    }


    private var formattedPointCount: String {
        return type(of: self).pointCountFormatter.string(from: NSNumber(value: pointCount))!
    }
}


private struct SceneKitView : View, UIViewRepresentable {
    let scene: SCNScene


    func makeUIView(context: UIViewRepresentableContext<SceneKitView>) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .black
        view.scene = scene
        view.allowsCameraControl = true
        return view
    }


    func updateUIView(_ uiView: SCNView, context: UIViewRepresentableContext<SceneKitView>) {
        uiView.scene = scene
    }
}