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
             constant   Vertex  *vertices               [[buffer(0)]])
{
    RasterizerData out;
    
    out.clipSpacePosition = float4(0.0, 0.0, 0.0, 1.0);
    
    float2 pixelSpacePosition = vertices[vertexID].position;
    
    out.clipSpacePosition.xy = pixelSpacePosition;
    out.color = vertices[vertexID].color;
    
    return out;
}

// Fragment function
fragment float4 fragmentShader(RasterizerData in [[stage_in]],
                               constant   float2  *resolution    [[buffer(0)]])
{
    float2 uv = in.clipSpacePosition.xy / *resolution;
    
    return float4(uv, 0.0, 1.0);
}

