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
    #include <metal_stdlib>
    using namespace metal;

    typedef struct
    {
       float time;
    } Uniforms;

    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

    kernel void shader(texture2d<float, access::read> texture0 [[texture(0)]],
                       texture2d<float, access::read> texture1 [[texture(1)]],
                       texture2d<float, access::read> texture2 [[texture(2)]],
                       texture2d<float, access::read> texture3 [[texture(3)]],
                       texture2d<float, access::write> output [[texture(4)]],
                       constant Uniforms& uniforms [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
    {
        int width = output.get_width();
        int height = output.get_height();
        float2 uv = float2(gid) / float2(width, height);

        float4 result = float4(uv, 0.5 + 0.5 * sin(uniforms.time), 1.0);
        output.write(result, gid);
    }
    """
