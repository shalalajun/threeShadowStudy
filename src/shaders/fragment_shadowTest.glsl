uniform vec3 uColor;
uniform sampler2D uDepthMap;
uniform vec3 uLightPos;
uniform vec4 uIntensity_0;

varying vec3 vNormal;
varying vec4 vShadowCoord;

// https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/packing.glsl.js#L24
#include <packing>

float frustumTest(vec3 shadowCoord, float shadowFactor){
    bvec4 inFrustumVec = bvec4 ( shadowCoord.x >= 0.0, shadowCoord.x <= 1.0, shadowCoord.y >= 0.0, shadowCoord.y <= 1.0 );
    bool inFrustum = all( inFrustumVec );

    bvec2 frustumTestVec = bvec2( inFrustum, shadowCoord.z <= 1.0 );
    bool frustumTest = all( frustumTestVec );

    if(frustumTest == false){
        shadowFactor = 1.0;
    }

    return shadowFactor;
}

void main(){
    
    
    vec3 shadowCoord = (vShadowCoord.xyz / vShadowCoord.w * 0.5 + 0.5);

    float depth_shadowCoord = shadowCoord.z;

    vec2 depthMapUv = shadowCoord.xy;
    float depth_depthMap = unpackRGBAToDepth(texture2D(uDepthMap, depthMapUv));

    // Compare and if the depth value is smaller than the value in the depth map, then there is an occluder and the shadow is drawn.
    
    float cosTheta = dot(normalize(uLightPos), vNormal);
    float bias = 0.005 * tan(acos(cosTheta)); // cosTheta is dot( n,l ), clamped between 0 and 1
    bias = clamp(bias, 0.0, 0.01);

    float shadowFactor = step(depth_shadowCoord - bias, depth_depthMap);

    // Assume no shadow except for viewing frustum.
    // https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/packing.glsl.js#L24
    bvec4 inFrustumVec = bvec4 ( shadowCoord.x >= 0.0, shadowCoord.x <= 1.0, shadowCoord.y >= 0.0, shadowCoord.y <= 1.0 );
    bool inFrustum = all( inFrustumVec );

    bvec2 frustumTestVec = bvec2( inFrustum, shadowCoord.z <= 1.0 );
    bool frustumTest = all( frustumTestVec );

    if(frustumTest == false){
        shadowFactor = 1.0;
    }

    float difLight = max(0.0, cosTheta);

    float shading = shadowFactor * difLight;


    vec3 color = mix(uColor - 0.1, uColor + 0.1, shading );
    //vec3 color = mix(uColor  - 0.3 , uColor + 0.5, mix(uColor, vec3(1.0,1.0,0.0), 1.0 - shading ));//그림자 컬러? 가능할까?
    // check the result of the shadow factor.
    gl_FragColor = vec4(vec3(color), 1.0);
}