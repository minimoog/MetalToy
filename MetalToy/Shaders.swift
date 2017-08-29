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
    "fragment float4 fragmentShader(FragmentData in [[stage_in]],\n" +
    "                               constant float2 *resolution [[buffer(0)]],\n" +
    "                               constant float *time [[buffer(1)]])\n" +
    "{\n" +
    "    float2 uv = in.fragCoord.xy / *resolution;\n" +
    "    return float4(uv, 0.5 + 0.5 * sin(*time), 1.0);\n" +
    "}\n"
