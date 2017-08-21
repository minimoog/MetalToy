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
    let r: Float
    let g: Float
    let b: Float
    let a: Float
    
    func toFloatArray() -> [Float] {
        return [x, y, r, g, b, a]
    }
}

class ViewController: UIViewController, MTKViewDelegate {

    let vertices: [Vertex] = [
        Vertex(x:  250, y: -250, r: 1, g: 0, b: 0, a: 1),
        Vertex(x: -250, y: -250, r: 0, g: 1, b: 0, a: 1),
        Vertex(x:    0, y:  250, r: 0, g: 0, b: 1, a: 1)
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
    
    var device: MTLDevice! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var vertexBuffer: MTLBuffer!
    var viewPortBuffer: MTLBuffer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        
        //arrange the vertex array
        for vertex in vertices {
            vertexData += vertex.toFloatArray()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let viewPortDataSize = viewPortData.count * MemoryLayout.size(ofValue: viewPortData[0])
        viewPortBuffer = device.makeBuffer(bytes: viewPortData, length: viewPortDataSize, options: [])
        
        let defaultLibrary = device.newDefaultLibrary()
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentProgram = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortData[0] = Float(size.width)
        viewPortData[1] = Float(size.height)
        
        viewPortBuffer.contents().copyBytes(from: viewPortData, count: viewPortData.count * MemoryLayout<Float>.stride)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewPortData[0]), height: Double(viewPortData[1]), znear: -1.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(viewPortBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
