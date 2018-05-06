//
//  ChaosGamePlotViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar.
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

import Cocoa
import SceneKit


public class ChaosGamePlotViewController : NSViewController {
    // Model
    public var resolution: CGFloat = 1000
    
    public var gameRunner: ChaosGameRunner? {
        didSet {
            if isViewLoaded {
                reset()
            }
        }
    }

    
    // Controller State
    private lazy var iterationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private var interfaceUpdateTimer: QueueTimer?

    private var scene = SCNScene()
    
    // View
    @IBOutlet weak var pointView: SCNView!
    @IBOutlet weak var iterationLabel: NSTextField!
    
    
    // MARK: -

    public override func viewDidLoad() {
        super.viewDidLoad()
        pointView.backgroundColor = .black
    }
    
    
    public func startMonitoringGameRunner() {
        guard gameRunner != nil else {
            return
        }
        
        interfaceUpdateTimer?.invalidate()
        interfaceUpdateTimer = QueueTimer.scheduledTimer(label: "ChaosGamePlotViewController.interfaceUpdateTimer", interval: 1 / 60) { [unowned self] _ in
            self.updateInterface()
        }
    }
    
    
    public func stopMonitoringGameRunner() {
        interfaceUpdateTimer?.invalidate()
    }
    
    
    public func reset() {
        let scene = SCNScene()
        self.scene = scene
        pointView.scene = scene
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        plotEmphasizedPoints(gameRunner.polygon.vertices, color: .blue, resolutionFactor: 0.01)
        plotPoints(gameRunner.allPoints)
        plotEmphasizedPoints([gameRunner.initialPoint], color: .red, resolutionFactor: 0.006)
        iterationLabel.integerValue = gameRunner.iteration
    }

    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        OperationQueue.main.addOperation {
            self.plotPoints(gameRunner.flushAccumulatedPoints())
            self.iterationLabel.integerValue = gameRunner.iteration
        }
    }
    
    
    private func plotEmphasizedPoints(_ points: [CGPoint], color: NSColor, resolutionFactor: CGFloat) {
        let sphere = SCNSphere(radius: resolutionFactor * resolution / 2)
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
        
        let vertexSource = SCNGeometrySource(vertices: points.map { SCNVector3(x: $0.x, y: $0.y, z: 0) })
        let element = SCNGeometryElement(indices: Array(0 ..< points.count), primitiveType: .point)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial!.emission.contents = NSColor.white
        scene.rootNode.addChildNode(SCNNode(geometry: geometry))
    }
}
