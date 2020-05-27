//Advanced stock by Danila Zabiaka
//#define white 240.0
//#define black 10.0
#pragma parameter black "Black" 10.0 0.0 255.0 5.0
#pragma parameter white "White" 240.0 0.0 255.0 5.0
#pragma parameter noise "Noise" 25.0 0.0 255.0 1.0
#pragma parameter satoffset "Saturation" 50.0 0.0 100.0 5.0
#pragma parameter red "Red" 255.0 0.0 300.0 5.0
#pragma parameter green "Green" 255.0 0.0 300.0 5.0
#pragma parameter blue "Blue" 255.0 0.0 300.0 5.0

//#define noise 25.0
//#define offset -25.0
//#define red -0.0  
//#define green -0.0
//#define blue -0.5
//#define satoffset 5.0 //5 as start point. sat=satoffset-5.0, 6 means 1.1

float pseudoNoise(vec2 co)
{
return fract(sin(dot(vec2(co.x,co.y) ,vec2(12.9898,78.233))) * 43758.5453);// *fract(sin(dot(vec2(co.x,co.y) ,vec2(12.9898,78.233)*2.0)) * 43758.5453); //pseudo random number generator
}
vec3 czm_saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = VertexCoord.x * MVPMatrix[0] + VertexCoord.y * MVPMatrix[1] + VertexCoord.z * MVPMatrix[2] + VertexCoord.w * MVPMatrix[3];
    TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float black;
uniform COMPAT_PRECISION float white;
uniform COMPAT_PRECISION float noise;
uniform COMPAT_PRECISION float satoffset;
uniform COMPAT_PRECISION float red;
uniform COMPAT_PRECISION float green;
uniform COMPAT_PRECISION float blue;

#else
#endif

void main()
{
    FragColor = COMPAT_TEXTURE(Texture, TEX0.xy);
	gl_FragColor.xyz = czm_saturation(gl_FragColor.xyz, 1.0+(satoffset-50.0)/50.0);
	
	gl_FragColor.x = gl_FragColor.x*(red/255.0);
	gl_FragColor.y=gl_FragColor.y*(green/255.0);
	gl_FragColor.z=gl_FragColor.z*(blue/255.0);
	
	gl_FragColor = gl_FragColor *white/255.0+black/255.0-gl_FragColor*black/255.0;
	gl_FragColor = gl_FragColor +(pseudoNoise(TEX0.xy*float(FrameCount))-0.6)*noise/255.0;
//	gl_FragColor = gl_FragColor +(pseudoNoise(vec2((TEX0.x+gl_FragColor.x+gl_FragColor.z)*float(FrameCount),(TEX0.y+gl_FragColor.y+gl_FragColor.z)*float(FrameCount)))-0.5)*noise/255.0;
//	FragColor = gl_FragColor + 0.0;
} 
#endif
