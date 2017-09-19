//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit
import Metal
import MetalKit

struct Vertex {
    let x: Float
    let y: Float
    
    func toFloatArray() -> [Float] {
        return [x, y]
    }
}

class ViewController: UIViewController, MTKViewDelegate {

    let vertices: [Vertex] = [
        Vertex(x: -1, y:  -1),
        Vertex(x:  1, y:  -1),
        Vertex(x:  1, y:   1),
        Vertex(x: -1, y:  -1),
        Vertex(x:  1, y:   1),
        Vertex(x: -1, y:   1)
    ]
    
    var vertexData: [Float] = []
    var viewPortData: [Float] = [Float](repeating: 0, count: 2)
    
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var codeView: UITextView!
    
    var device: MTLDevice! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var vertexBuffer: MTLBuffer!
    var viewPortBuffer: MTLBuffer!
    var timeBuffer: MTLBuffer!
    
    var startTime: Double = 0;
    var numFrames = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        
        //start paused
        mtkView.isPaused = true
        
        //arrange the vertex array
        for vertex in vertices {
            vertexData += vertex.toFloatArray()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let viewPortDataSize = viewPortData.count * MemoryLayout.size(ofValue: viewPortData[0])
        viewPortBuffer = device.makeBuffer(bytes: viewPortData, length: viewPortDataSize, options: [])
        
        timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: [])
        
        setRenderPipeline(fragmentShader: DefaultFragmentShader)
        
        commandQueue = device.makeCommandQueue()
        
        codeView.text = DefaultFragmentShader
    }
    
    func setRenderPipeline(fragmentShader: String) {
        do {
            let pipelineStateDescriptor = try loadShaders(device: device, vertexShader: DefaultVertexShader, fragmentShader: fragmentShader)
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
        } catch {
            print(error)
        }
    }
    
    func loadShaders(device: MTLDevice, vertexShader: String, fragmentShader: String) throws -> MTLRenderPipelineDescriptor {
        let library = try device.makeLibrary(source: vertexShader + fragmentShader, options: nil)
        let vertexProgram = library.makeFunction(name: "vertexShader")
        let fragmentProgram = library.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        return pipelineStateDescriptor
    }
    
    @IBAction func onPlayPauseButtonClicked(_ sender: UIButton) {
        if sender.currentTitle == "Play" {
            sender.setTitle("Pause", for: .normal)
            mtkView.isPaused = false
            
            setRenderPipeline(fragmentShader: codeView.text)
            
        } else {
            sender.setTitle("Play", for: .normal)
            mtkView.isPaused = true
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortData[0] = Float(size.width)
        viewPortData[1] = Float(size.height)
        
        viewPortBuffer.contents().copyBytes(from: viewPortData, count: viewPortData.count * MemoryLayout<Float>.stride)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        if (numFrames == 0) { startTime = CACurrentMediaTime() }
        
        //ios 11 MTKView bug or not, drawableSizeWillChange is not called, so we need here the viewport sizes
        viewPortData[0] = Float(view.drawableSize.width)
        viewPortData[1] = Float(view.drawableSize.height)
        viewPortBuffer.contents().copyBytes(from: viewPortData, count: viewPortData.count * MemoryLayout<Float>.stride)
        
        let currentTime = CACurrentMediaTime()
        let timeToShader = Float(currentTime - startTime)
        
        //fill the buffer with time
        timeBuffer.contents().copyBytes(from: [timeToShader], count: MemoryLayout<Float>.stride)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewPortData[0]), height: Double(viewPortData[1]), znear: -1.0, zfar: 1.0))
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentBuffer(viewPortBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentBuffer(timeBuffer, offset: 0, index: 1)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        numFrames += 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
