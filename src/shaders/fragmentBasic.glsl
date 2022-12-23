  #define USE_SKINNING

uniform vec3 uColor;
uniform sampler2D uDepthMap;
uniform vec3 uLightPos;
uniform vec4 uIntensity_0;
uniform vec3 shadowColor;
uniform sampler2D u_texture;

varying vec2 vUv;
varying vec3 vNormal;
varying vec4 vShadowCoord;


// https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/packing.glsl.js#L24
#include <packing>
#include <common>




void main(){

    
    vec4 tex = texture(u_texture, vUv.xy);
    gl_FragColor = vec4(vec3(tex.rgb), 1.0);
   
}