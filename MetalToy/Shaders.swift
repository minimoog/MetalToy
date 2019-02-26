//
//  Shaders.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/24/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import Foundation

public let DefaultVertexShader = """
    #include <metal_stdlib>
    using namespace metal;

    typedef struct
    {
       packed_float2 position;
    } Vertex;

    typedef struct
    {
        float4 fragCoord [[position]];
    } FragmentData;

    vertex FragmentData
    vertexShader(uint               vertexID    [[vertex_id]],
                 constant   Vertex  *vertices   [[buffer(0)]])
    {
        FragmentData out;
        out.fragCoord = float4(0.0, 0.0, 0.0, 1.0);
        float2 pixelSpacePosition = vertices[vertexID].position;
        out.fragCoord.xy = pixelSpacePosition;
        return out;
    }

    //--------------------------------------------------

    """

public let DefaultFragmentShader = """
    typedef struct
    {
       float2 resolution;
       float time;
    } Uniforms;

    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

    fragment float4 fragmentShader(FragmentData in [[stage_in]],
                                   texture2d<float> texture0 [[texture(0)]],
                                   texture2d<float> texture1 [[texture(1)]],
                                   texture2d<float> texture2 [[texture(2)]],
                                   texture2d<float> texture3 [[texture(3)]],
                                   constant Uniforms& uniforms [[buffer(1)]])
    {
        float2 uv = in.fragCoord.xy / uniforms.resolution;
        return float4(uv, 0.5 + 0.5 * sin(uniforms.time), 1.0);
    }
    """
