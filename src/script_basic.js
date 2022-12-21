import './style.css'
import * as THREE from 'three'
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls.js'
import vertex from './shaders/vertex.glsl'
import shadowFragment from './shaders/shadowFragment.glsl' 
import fragment from './shaders/fragment.glsl'
import { ShadowMapViewer} from 'three/examples/jsm/utils/ShadowMapViewer.js'
import { GUI } from 'three/examples/jsm/libs/lil-gui.module.min.js';
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js';

let intensity_0 = new THREE.Vector4(1, 0, 0, 0);
const color = new THREE.Color(0xE1E5EA);
const shadowColor = new THREE.Color(0x1e9c7a);

let isMobile = false;
// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

scene.background = new THREE.Color(0xE1E5EA)



/**
 * 라이트를 먼저 만든다.
 */

const light = new THREE.DirectionalLight(0xffffff, 1.0);
light.position.set(-60, 50, 40);
scene.add(light)

const girlMaterial = new THREE.MeshStandardMaterial();


/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}
/**
 * Camera
 */
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 1, 10000)
camera.position.set(90,60,90).multiplyScalar(2);
scene.add(camera)


const frustumSize = 200;


light.shadow.camera = new THREE.OrthographicCamera(

    -frustumSize / 2,
    frustumSize / 2,
    frustumSize / 2,
    -frustumSize / 2,
    1,
   200
)

light.shadow.camera.position.copy(light.position)
light.shadow.camera.lookAt(scene.position)

scene.add(light.shadow.camera);

light.shadow.mapSize.x = 2048;
light.shadow.mapSize.y = 2048;

const pars = {
    minFilter: THREE.NearestFilter,
    magFilter: THREE.NearestFilter, 
    format: THREE.RGBAFormat
}

light.shadow.map = new THREE.WebGLRenderTarget(light.shadow.mapSize.x, light.shadow.mapSize.y, pars)
const shadowCameraHelper = new THREE.CameraHelper( light.shadow.camera );
scene.add( shadowCameraHelper );
/**
 * Object
 */

const uniforms = {
    shadowColor:{
        value: shadowColor
    },
    uTime: {
        value: 0
    },
    uColor: {
        value: new THREE.Color(color)
    },
    uLightPos: {
        value: light.position
    },
    uDepthMap: {
        value: light.shadow.map.texture
    },
    uShadowCameraP: {
        value: light.shadow.camera.projectionMatrix
    },
    uShadowCameraV: {
        value: light.shadow.camera.matrixWorldInverse
    },
    uIntensity_0: {
        value: intensity_0
    },
}
const material = new THREE.ShaderMaterial({
    vertexShader : vertex,
    fragmentShader : fragment,
    uniforms: uniforms
});
 
const geometry = new THREE.BoxGeometry(40, 40, 40)
const mesh = new THREE.Mesh(geometry, material)
mesh.position.set(40,20,-30)
scene.add(mesh)

const groundGeo = new THREE.BoxGeometry(250,250,250)
const groundMat = new THREE.MeshStandardMaterial({ color: 0xffffff})
const ground = new THREE.Mesh(groundGeo, groundMat)
ground.position.set(0,-125,0)

scene.add(ground);


/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
    alpha: true
})
renderer.setSize(sizes.width, sizes.height)
renderer.render(scene, camera)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    isMobile = sizes.width <= 768
})

const controls = new OrbitControls(camera, canvas);




const shadowMaterial = new THREE.ShaderMaterial({
    vertexShader : vertex,
    fragmentShader : shadowFragment
})



const depthViewer = new ShadowMapViewer(light);
depthViewer.size.set( 600, 600 );


renderer.setRenderTarget(null);




const clock = new THREE.Clock();


const tick = () =>
{
    const elapsedTime = clock.getElapsedTime();
    
    controls.update();

    mesh.material = shadowMaterial
    ground.material = shadowMaterial
    girl.traverse((gltf)=>{
        gltf.material = shadowMaterial
    })
   
   

    renderer.setRenderTarget(light.shadow.map)
    renderer.render(scene, light.shadow.camera)

    mesh.material = material
    ground.material = material
    girl.traverse((gltf)=>{
        gltf.material = material
    })
   

    renderer.setRenderTarget(null);
    renderer.render(scene, camera);

    depthViewer.render( renderer );

    //renderer.render(scene, camera);

    window.requestAnimationFrame(tick);

}



modelLoad('Girl_mesh');
const girl = scene.getObjectByName('Girl_mesh')
createControls();
tick();



function createControls(){
    let params = {
        depthmapViewer: isMobile ? false : true,
        visibleShadowCamera: true,
        output: "color shading"
    }

    let gui = new GUI();
    gui.add(params, "depthmapViewer").onChange((value) => {
        depthViewer.enabled = value;
    });
    gui.add(params, "visibleShadowCamera");
    gui.add(params, "output", [
        "color shading",
        "shadow * lighting",
        "shadow",
        "lighting",
    ]).onChange((value) => {
       intensity_0.set(0, 0, 0, 0);

        switch(value){
            case "color shading": 
               intensity_0.x = 1;
                break;
            case "shadow * lighting":
                intensity_0.y = 1;
                break;
            case "shadow":
                intensity_0.z = 1;
                break;
            case "lighting":
                intensity_0.w = 1;
                break;
        }
    });
}

function modelLoad(name)
    {
        var parent = new THREE.Object3D();
        parent.name = name;
        scene.add(parent);

        const loader = new GLTFLoader();
        loader.load(
            './mamondegirl_1.glb',(gltf)=>{
             const model = gltf.scene;
             var parent = scene.getObjectByName(name);
             
             if(parent)
             {
                parent.add(model);
             }
            
            }
        )
    }

