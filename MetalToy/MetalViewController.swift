//
//  MetalViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 9/26/17.
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

class MetalViewController: UIViewController, MTKViewDelegate {
    
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
    
    var device: MTLDevice! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var textures: [MTLTexture?] = [MTLTexture?](repeating: nil, count: 4)
    
    var startTime: Double = 0
    var numFrames = 0
    
    public var finishedCompiling: ((Bool, [CompilerErrorMessage]?) -> ())?
    
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
        
        //float2 + float size + padding = 4 floats
        uniformBuffer = device.makeBuffer(length: 4 * MemoryLayout<Float>.stride, options: [])
        
        setRenderPipeline(fragmentShader: DefaultFragmentShader)
        
        commandQueue = device.makeCommandQueue()
        
        //load placeholder test textures so that shader don't throw errors
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: device)
        for index in 0 ..< textures.count {
            textures[index] = try? textureLoader.newTexture(name: "placeholder", scaleFactor: view.contentScaleFactor, bundle: nil, options: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func setRenderPipeline(fragmentShader: String) {
        do {
            if let pipelineStateDescriptor = loadShaders(device: device, vertexShader: DefaultVertexShader, fragmentShader: fragmentShader) {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            }
        } catch {
            print(error)
        }
    }
    
    func loadShaders(device: MTLDevice, vertexShader: String, fragmentShader: String) -> MTLRenderPipelineDescriptor? {
        
        do {
            let library = try device.makeLibrary(source: vertexShader + fragmentShader, options: nil)
            let vertexProgram = library.makeFunction(name: "vertexShader")
            let fragmentProgram = library.makeFunction(name: "fragmentShader")
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            if let onCompilerResult = finishedCompiling {
                onCompilerResult(true, nil)
            }
            
            return pipelineStateDescriptor
            
        } catch let error as NSError {
            let compilerMessages = parseCompilerOutput(error.localizedDescription)
            
            if let onCompilerResult = finishedCompiling {
                onCompilerResult(false, compilerMessages)
            }
        }
        
        return nil
    }
    
    func loadTexture(filename: String, index: Int) {
        print("filename: \(filename) at \(index)")
        
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: device)
        textures[index] = try? textureLoader.newTexture(URL: URL(fileURLWithPath: filename), options: nil)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortData[0] = Float(size.width)
        viewPortData[1] = Float(size.height)
        
        //viewPortBuffer.contents().copyBytes(from: viewPortData, count: viewPortData.count * MemoryLayout<Float>.stride)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        if (numFrames == 0) { startTime = CACurrentMediaTime() }
        
        //ios 11 MTKView bug or not, drawableSizeWillChange is not called, so we need here the viewport sizes
        viewPortData[0] = Float(view.drawableSize.width)
        viewPortData[1] = Float(view.drawableSize.height)
        
        let currentTime = CACurrentMediaTime()
        let timeToShader = Float(currentTime - startTime)
        
        let pointerUniformBuffer = uniformBuffer.contents().bindMemory(to: Float.self, capacity: 3)
        let arrayPointer = UnsafeMutableBufferPointer(start: pointerUniformBuffer, count: 3)
        arrayPointer[0] = viewPortData[0]
        arrayPointer[1] = viewPortData[1]
        arrayPointer[2] = timeToShader
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewPortData[0]), height: Double(viewPortData[1]), znear: -1.0, zfar: 1.0))
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentTextures(textures, range: 0 ..< textures.count)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        numFrames += 1
    }
    
    // MARK: Not used
    func snapshot(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        mtkView.drawHierarchy(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), afterScreenUpdates: false)
        let uiimage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return uiimage
    }
}

