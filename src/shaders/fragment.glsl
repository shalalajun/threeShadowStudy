  #define USE_SKINNING

uniform vec3 uColor;
uniform sampler2D uDepthMap;
uniform sampler2D u_texture;
uniform vec3 uLightPos;
uniform vec4 uIntensity_0;
uniform vec3 shadowColor;


varying vec2 vUv;
varying vec3 vNormal;
varying vec4 vShadowCoord;


// https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/packing.glsl.js#L24
#include <packing>
#include <common>


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

   
    vec4 tex = texture2D(u_texture, vUv.xy);
    float cosTheta = dot(normalize(uLightPos), vNormal);
    float difLight = max(0.0, cosTheta);

    vec3 shadowCoord = (vShadowCoord.xyz / vShadowCoord.w * 0.5 + 0.5);

    float depth_shadowCoord = shadowCoord.z;

    vec2 depthMapUv = shadowCoord.xy;
    float depth_depthMap = unpackRGBAToDepth(texture2D(uDepthMap, depthMapUv));

   //http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/
    float bias = 0.005 * tan(acos(cosTheta)); // cosTheta is dot( n,l ), clamped between 0 and 1
    bias = clamp(bias, 0.0, 0.01);

    float shadowFactor = step(depth_shadowCoord - bias, depth_depthMap);
    
    shadowFactor = frustumTest(shadowCoord, shadowFactor);
    
    float shading = shadowFactor * difLight;
    
    vec3 color = vec3(0.0);

    if(uIntensity_0.x == 1.0){
       //color = mix(uColor - 0.1, uColor + 0.1, shading);//기본 아래는 컬러그림자
        // color = mix(shadowColor,1.0 - vec3(0.0,0.0,0.0), shading);
        // color += uColor * 0.5;
        color = mix(shadowColor,uColor, shading)+ 0.1; 
    } 
    else if(uIntensity_0.y == 1.0){
       // color = vec3(shading);
    }
    else if(uIntensity_0.z == 1.0){
        color = vec3(shadowFactor);
    }
    else if(uIntensity_0.w == 1.0){
        color = vec3(difLight);
    }

   
   

    //vec3 color = mix(uColor  - 0.3 , uColor + 0.5, mix(uColor, vec3(1.0,1.0,0.0), 1.0 - shading ));//그림자 컬러? 가능할까?
    // check the result of the shadow factor.
    vec3 finCol = tex.rgb * color;
    gl_FragColor = vec4(vec3(finCol), 1.0);
   
}