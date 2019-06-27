//
//  ChaosGamePlotter.swift
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


/// A `ChaosGamePlotter` plots the points from `ChaosGameSequence` to an `SCNScene`. The rate at which it generates and
/// plots points can be modified using `rate`, and plotting can be started and stopped using the `isRunning` property.
///
/// `ChaosGamePlotter`s are meant to be used as the models for views that display a `ChaosGameSequence`’s points.
public final class ChaosGamePlotter : BindableObject {
    public let didChange = PassthroughSubject<ChaosGamePlotter, Never>()

    /// An iterator for the Chaos Game’s points.
    private var chaosGamePointIterator: ChaosGameSequence.Iterator

    /// The queue on which points are generated.
    private let pointGenerationQueue = DispatchQueue(label: "PointGenerationQueue")

    /// The subscriber that receives published points from the sequence.
    private var pointSubscriber: AnyCancellable?

    /// The number of points that have been generated.
    private(set) var pointCount = 0 {
        didSet {
            didChange.send(self)
        }
    }

    /// The SceneKit scene to which points are plotted.
    public private(set) var scene = SCNScene()

    /// The maximum rate at which the instance’s SceneKit scene will be updated. Must be positive. Increasing the frame
    /// rate beyond 240 will probably negatively impact performance.
    public var maximumFrameRate: Int = 60 {
        didSet {
            precondition(maximumFrameRate > 1)
            schedulePointSubscriber()
        }
    }




    // MARK: - Controlling Point Generation

    /// Whether the instance is currently generating and plotting points.
    public var isRunning = false {
        didSet {
            if isRunning != oldValue {
                if isRunning {
                    schedulePointSubscriber()
                } else {
                    pointSubscriber = nil
                }

                didChange.send(self)
            }
        }
    }


    /// The rate at which points are generated. Represented in points/sec. Must be 1 or larger.
    public var rate: Int = 1 {
        didSet {
            precondition(rate > 0)

            if rate != oldValue {
                if isRunning {
                    schedulePointSubscriber()
                }

                didChange.send(self)
            }
        }
    }


    /// Creates a new `ChaosGamePlotter`.
    public init() {
        let chaosGame = ChaosGameSequence()
        self.chaosGamePointIterator = chaosGame.makeIterator()
        resetScene(chaosGame: chaosGame)
    }


    /// Resets the plotter to use the specified settings.
    ///
    /// After invoking this method, the plotter will have 0 points and not be running.
    ///
    /// - Parameter settings: The `ChaosGameSettings` to use when generating points.
    public func reset(with settings: ChaosGameSettings) {
        isRunning = false
        pointCount = 0

        let chaosGame = ChaosGameSequence(settings: settings)
        chaosGamePointIterator = chaosGame.makeIterator()
        resetScene(chaosGame: chaosGame)

        didChange.send(self)
    }


    /// Schedules the point subscriber.
    private func schedulePointSubscriber() {
        let rate = self.rate
        let frameRate = min(rate, maximumFrameRate)
        let batchSize = Int(Double(rate) / Double(frameRate))

        // The frame number that we’re drawing in the given second. This value will range from 0 ..< frameRate. This is
        // incremented (modulo the rame rate) every time the timer fires.
        var frameNumber = 0

        // We fire the timer at our frame rate. When the timer fires, we generate a batch of points and plot them and
        // update our point count.
        let subscriber = DispatchSource.timerPublisher(interval: 1 / Double(frameRate), queue: pointGenerationQueue)
            .compactMap { [weak self] (_) -> [CGPoint]? in
                guard let self = self else {
                    return nil
                }

                // Because batchSize (rate/frameRate) is an integer, we may not actually hit our rate. As such, every
                // first frame in a second, we add on remainder that we would have missed (rate % frameRate).
                let batchSizeAdjustment = (frameNumber == 0) ? rate % frameRate : 0
                frameNumber = (frameNumber + 1) % frameRate
                return Array(self.chaosGamePointIterator.next(batchSize + batchSizeAdjustment))
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] (points) in
                guard let self = self else {
                    return
                }

                self.plotPoints(points)
                self.pointCount += points.count
        }

        // Note that setting pointSubscriber cancels the previous point subscriber if it was active
        self.pointSubscriber = AnyCancellable(subscriber)
    }

    
    // MARK: - Working with the scene

    /// Removes all points from the scene and then adds back the vertices and initial point.
    ///
    /// - Parameter chaosGame: The `ChaosGameSequence` with which to initialize the scene.
    private func resetScene(chaosGame: ChaosGameSequence) {
        for childNode in scene.rootNode.childNodes {
            childNode.removeFromParentNode()
        }

        plotEmphasizedPoints(chaosGame.polygon.vertices, color: .blue, radius: 0.005)
        plotEmphasizedPoints([chaosGame.initialPoint], color: .red, radius: 0.003)
    }


    /// Plots the specified points as spheres with the specified color and radius.
    ///
    /// - Parameters:
    ///   - points: The points to plot.
    ///   - Parameter color: The color for the plotted points.
    ///   - Parameter radius: The radius of the sphere that represents the points.
    private func plotEmphasizedPoints(_ points: [CGPoint], color: UIColor, radius: CGFloat) {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color

        for point in points {
            let node = SCNNode(geometry: sphere)
            node.position = SCNVector3(point.x, point.y, 0)
            scene.rootNode.addChildNode(node)
        }
    }


    /// Plots the specified points as primitive points in SceneKit scene.
    /// - Parameter points: The points to plot.
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

