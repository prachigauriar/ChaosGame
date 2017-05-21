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
import SpriteKit


public class ChaosGamePlotViewController : NSViewController {
    // Model
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

    private var scene: SKScene?
    
    // View
    let pointView: SKView = SKView()
    @IBOutlet weak var iterationLabel: NSTextField!
    
    
    // MARK: -

    public override func viewDidLoad() {
        super.viewDidLoad()
        pointView.frame = view.bounds
        pointView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        view.addSubview(pointView, positioned: .below, relativeTo: iterationLabel)
    }
    
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetWithDidEndLiveResizeNotification(_:)),
                                               name: .NSWindowDidEndLiveResize,
                                               object: self.view.window)

        reset()
    }
    
    
    public override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self, name: .NSWindowDidEndLiveResize, object: nil)
    }
    
    
    public func startMonitoringGameRunner() {
        guard gameRunner != nil else {
            return
        }
        
        interfaceUpdateTimer?.invalidate()
        interfaceUpdateTimer = QueueTimer(label: "ChaosGamePlotViewController.interfaceUpdateTimer", interval: 1 / 30) { [unowned self] _ in
            self.updateInterface()
        }
        
        interfaceUpdateTimer?.schedule()
    }
    
    
    public func stopMonitoringGameRunner() {
        interfaceUpdateTimer?.invalidate()
    }
    
    
    public func reset() {
        let scene = SKScene(size: pointView.bounds.size)
        scene.scaleMode = .fill
        scene.backgroundColor = .black
        self.scene = scene
        pointView.presentScene(scene)
        
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        plot(gameRunner.polygon.vertices, color: .blue, diameter: 10)
        plot(gameRunner.allPoints)
        plot([gameRunner.initialPoint], color: .red, diameter: 6)
        iterationLabel.integerValue = gameRunner.iteration
    }

    
    @objc private func resetWithDidEndLiveResizeNotification(_ note: Notification) {
        reset()
    }
    
    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        OperationQueue.main.addOperation {
            self.plot(gameRunner.flushAccumulatedPoints())
            self.iterationLabel.integerValue = gameRunner.iteration
        }
    }
    
    
    private func plot(_ points: [CGPoint], color: NSColor = .white, diameter: CGFloat = 1) {
        guard let scene = scene else {
            return
        }

        let affineTransform = AffineTransform.init(scaleByX: scene.size.width, byY: scene.size.height)
        for point in points {
            let node: SKNode
            if diameter == 1 {
                node = SKSpriteNode(color: color, size: CGSize(width: diameter, height: diameter))
            } else {
                let shapeNode = SKShapeNode(circleOfRadius: diameter / 2)
                shapeNode.fillColor = color
                shapeNode.lineWidth = 0
                node = shapeNode
            }
            
            node.position = affineTransform.transform(point)
            scene.addChild(node)
        }
    }
}
