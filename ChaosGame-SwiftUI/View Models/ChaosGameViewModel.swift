//
//  ChaosGameViewModel.swift
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
import SceneKit
import SwiftUI


final class ChaosGameViewModel : BindableObject {
    let didChange = PassthroughSubject<ChaosGameViewModel, Never>()

    private var pointGenerator = TimedIterativeGenerator(generator: ChaosGame())
    private var pointSubscriber: AnySubscriber<GeneratedBatch<CGPoint>, Never>!

    private(set) var scene = SCNScene()

    init() {
        subscribeToGeneratedPoints()
        plotEmphasizedPoints(chaosGame.vertices, color: .blue, radius: 50)
        plotEmphasizedPoints([chaosGame.initialPoint], color: .red, radius: 30)
    }


    func reset(with settings: ChaosGameSettings) {
        let previousFrequency = pointGenerator.frequency
        pointGenerator = TimedIterativeGenerator(generator: ChaosGame(settings: settings))
        pointGenerator.frequency = previousFrequency

        subscribeToGeneratedPoints()

        for childNode in scene.rootNode.childNodes {
            childNode.removeFromParentNode()
        }

        plotEmphasizedPoints(chaosGame.vertices, color: .blue, radius: 50)
        plotEmphasizedPoints([chaosGame.initialPoint], color: .red, radius: 30)

        isRunning = false
        iterationCount = 0
        didChange.send(self)
    }


    private func subscribeToGeneratedPoints() {
        pointSubscriber = pointGenerator.batchPublisher
            .receive(on: RunLoop.main)
            .sink { (batch) in
                self.plotPoints(batch.values)
                self.iterationCount = batch.iteration
            }.eraseToAnySubscriber()
    }


    // MARK: - Bindable Properties

    var isRunning: Bool {
        get {
            pointGenerator.isRunning
        }

        set {
            if pointGenerator.isRunning != newValue {
                pointGenerator.isRunning = newValue
                didChange.send(self)
            }
        }
    }


    private(set) var iterationCount: Int = 0 {
        didSet {
            if iterationCount != oldValue {
                didChange.send(self)
            }
        }
    }


    var frequency: Double {
        get {
            Double(pointGenerator.frequency)
        }

        set {
            let intValue = Int(newValue)
            if pointGenerator.frequency != intValue {
                pointGenerator.frequency = Int(newValue)
                didChange.send(self)
            }
        }
    }


    private let frequencyFormatter = MeasurementFormatter()

    var formattedFrequency: String {
        return frequencyFormatter.string(from: Measurement(value: frequency, unit: UnitFrequency.hertz))
    }


    // MARK: - Plotting Points

    private var chaosGame: ChaosGame {
        return pointGenerator.generator
    }


    private func plotEmphasizedPoints(_ points: [CGPoint], color: UIColor, radius: CGFloat) {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color

        for point in points {
            let node = SCNNode(geometry: sphere)
            node.position = SCNVector3(point.x, point.y, 0)
            scene.rootNode.addChildNode(node)
        }
    }


    private func plotPoints(_ points: [CGPoint]) {
        guard !points.isEmpty else {
            return
        }

        let vertexSource = SCNGeometrySource(vertices: points.map { SCNVector3($0.x, $0.y, 0) })
        let element = SCNGeometryElement(indices: (0 ..< points.count).map { UInt32($0) }, primitiveType: .point)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial!.emission.contents = UIColor.white
        scene.rootNode.addChildNode(SCNNode(geometry: geometry))
    }
}

