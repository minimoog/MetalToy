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

class MetalViewController: UIViewController, MTKViewDelegate {
    
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
        }
    }
    
    var device: MTLDevice! = nil
    var computePipelineState: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue! = nil
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
        mtkView.framebufferOnly = false
        
        //start paused
        mtkView.isPaused = true
        
        //float size + padding = 4 floats
        uniformBuffer = device.makeBuffer(length: 4 * MemoryLayout<Float>.stride, options: [])
        
        if setComputePipeline(computeShader: DefaultFragmentShader) == nil {
            fatalError("Default fragment shader has problem compiling")
        }
        
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
    
    public func setComputePipeline(computeShader: String) -> MTLComputePipelineState? {
        if let computeProgram = loadShaders(device: device, computeShader: computeShader) {
            computePipelineState = try? device.makeComputePipelineState(function: computeProgram)
            
            return computePipelineState
        }
        
        return nil
    }
    
    fileprivate func loadShaders(device: MTLDevice, computeShader: String) -> MTLFunction? {
        do {
            let library = try device.makeLibrary(source: computeShader, options: nil)
            let computeProgram = library.makeFunction(name: "shader")
            
            if let onCompilerResult = finishedCompiling {
                onCompilerResult(true, nil)
            }
            
            return computeProgram
        } catch let error as NSError {
            let compilerMessages = parseCompilerOutput(error.localizedDescription)
            
            if let onCompilerResult = finishedCompiling {
                onCompilerResult(false, compilerMessages)
            }
        }
        
        return nil
    }
    
    public func loadTexture(filename: String, index: Int) {
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: device)
        textures[index] = try? textureLoader.newTexture(URL: URL(fileURLWithPath: filename), options: nil)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    internal func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        if (numFrames == 0) { startTime = CACurrentMediaTime() }
        
        let currentTime = CACurrentMediaTime()
        let timeToShader = Float(currentTime - startTime)
        
        let pointerUniformBuffer = uniformBuffer.contents().bindMemory(to: Float.self, capacity: 1)
        let arrayPointer = UnsafeMutableBufferPointer(start: pointerUniformBuffer, count: 1)
        arrayPointer[0] = timeToShader
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(computePipelineState!)
        computeEncoder?.setBuffer(uniformBuffer, offset: 0, index: 0)
        computeEncoder?.setTextures(textures, range: 0 ..< textures.count)
        computeEncoder?.setTexture(drawable.texture, index: 4)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width,
                                       drawable.texture.height / threadGroupCount.height,
                                       1)
        
        computeEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder?.endEncoding()
        
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

