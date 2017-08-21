//
//  AppDelegate.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    packed_float2 position;
    packed_float4 color;
} Vertex;

typedef struct
{
    float4 clipSpacePosition [[position]];
    float4 color;
} RasterizerData;

// Vertex Function
vertex RasterizerData
vertexShader(uint               vertexID                [[vertex_id]],
             constant   Vertex  *vertices               [[buffer(0)]],
             constant   float2  *viewportSizePointer    [[buffer(1)]])
{
    RasterizerData out;
    
    // Initialize our output clip space position
    out.clipSpacePosition = float4(0.0, 0.0, 0.0, 1.0);
    
    float2 pixelSpacePosition = vertices[vertexID].position;
    
    float2 viewportSize = *viewportSizePointer;
    
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.color = vertices[vertexID].color;
    
    return out;
}

// Fragment function
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // We return the color we just set which will be written to our color attachment.
    return in.color;
}

