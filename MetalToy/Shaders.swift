//
//  Shaders.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/24/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import Foundation

public let DefaultVertexShader =
    "#include <metal_stdlib>\n" +
    "using namespace metal;\n" +
    "\n" +
    "typedef struct\n" +
    "{\n" +
    "   packed_float2 position;\n" +
    "} Vertex;\n" +
    "\n" +
    "typedef struct\n" +
    "{\n" +
    "    float4 fragCoord [[position]];\n" +
    "} FragmentData;\n" +
    "\n" +
    "vertex FragmentData\n" +
    "vertexShader(uint               vertexID    [[vertex_id]],\n" +
    "             constant   Vertex  *vertices   [[buffer(0)]])\n" +
    "{\n" +
    "    FragmentData out;\n" +
    "    out.fragCoord = float4(0.0, 0.0, 0.0, 1.0);\n" +
    "    float2 pixelSpacePosition = vertices[vertexID].position;\n" +
    "    out.fragCoord.xy = pixelSpacePosition;\n" +
    "    return out;\n" +
    "}\n" +
    "\n" +
    "//--------------------------------------------------\n"

public let DefaultFragmentShader =
    "typedef struct\n" +
    "{\n" +
    "   float2 resolution;\n" +
    "   float time;\n" +
    "} Uniforms;\n" +
    "\n" +
    "constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);\n" +
    "\n" +
    "fragment float4 fragmentShader(FragmentData in [[stage_in]],\n" +
    "                               texture2d<float> texture0 [[texture(0)]],\n" +
    "                               texture2d<float> texture1 [[texture(1)]],\n" +
    "                               texture2d<float> texture2 [[texture(2)]],\n" +
    "                               texture2d<float> texture3 [[texture(3)]],\n" +
    "                               constant Uniforms& uniforms [[buffer(1)]])\n" +
    "{\n" +
    "    float2 uv = in.fragCoord.xy / uniforms.resolution;\n" +
    "    return float4(uv, 0.5 + 0.5 * sin(uniforms.time), 1.0);\n" +
    "}\n"
