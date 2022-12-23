uniform mat4 uShadowCameraP;
uniform mat4 uShadowCameraV;

varying vec4 vShadowCoord;

varying vec3 vNormal;
varying vec2 vUv;

void main(){

    vUv = uv;
    vNormal = normal;
    vec3 pos = position;

    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
     // Coordinates from the shadow camera viewpoint
    // Pass to fragment shader and compare with depth map.

    vShadowCoord = uShadowCameraP * uShadowCameraV * modelMatrix * vec4(pos, 1.0);

 
}