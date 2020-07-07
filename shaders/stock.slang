#version 450

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float black;
	float white;
	float noise;
	float satoffset;
	float red;
	float green;
	float blue;
	float noiseoffset;
	float noiseden;
	float gammabefore;
	float gammaafter;
} params;

//Advanced stock by Danila Zabiaka
//#define white 240.0
//#define black 10.0
#pragma parameter gammabefore "Gamma before levels correction - I dont know how is better" 1.0 0.0 10.0 0.05
#pragma parameter black "Black point - min value" 10.0 0.0 255.0 5.0
#pragma parameter white "White point - max value" 240.0 0.0 255.0 5.0
#pragma parameter gammaafter "Gamma after levels correction - I dont know how is better" 1.0 0.0 10.0 0.05
#pragma parameter noise "Noise" 24.0 0.0 255.0 2.0
#pragma parameter satoffset "Saturation - REDUCE IT (usual lcd display is oversaturated)" 50.0 0.0 100.0 5.0
#pragma parameter red "Red max value, usually 255" 255.0 0.0 300.0 5.0
#pragma parameter green "Green" 255.0 0.0 300.0 5.0
#pragma parameter blue "Blue" 255.0 0.0 300.0 5.0
#pragma parameter noiseoffset "Noise offset. Noise should return 0..1" -0.5 -1.0 1.5 0.05
#pragma parameter noiseden "Остаток от шума" 120.0 0.0 10000.0 10.0


#define black params.black
#define white params.white
#define noise params.noise
#define gammabefore params.gammabefore
#define gammaafter params.gammaafter
#define satoffset params.satoffset
#define red params.red
#define green params.green
#define blue params.blue
#define noiseoffset params.noiseoffset
#define FrameCount params.FrameCount
#define noiseden params.noiseden



layout(std140, set = 0, binding = 0) uniform UBO
{
	mat4 MVP;
} global;

float pseudoNoise3(vec2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}
float pseudoNoise2(vec2 co)
{
return fract(sin(dot(vec2(co.x,co.y) ,vec2(12.9898,78.233))) * 43758.5453) *fract(sin(dot(vec2(co.x,co.y) ,vec2(12.9898,78.233)*2.0)) * 43758.5453); //pseudo random number generator
}

float pseudoNoise(vec2 co)
{
return fract(sin(dot(vec2(co.x,co.y) ,vec2(12.9898,78.233))) * 43758.5453)  ; //pseudo random number generator
}

vec3 czm_saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main()
{
   FragColor = vec4(texture(Source, vTexCoord).rgb, 1.0);
   FragColor.xyz = czm_saturation(FragColor.xyz, 1.0+(satoffset-50.0)/50.0);
   FragColor.x = FragColor.x*(red/255.0);
   FragColor.y=FragColor.y*(green/255.0);
   FragColor.z=FragColor.z*(blue/255.0);
   FragColor.xyz=pow(FragColor.xyz, vec3(1.0/gammabefore));
   FragColor = FragColor *white/255.0+black/255.0-FragColor*black/255.0;
   FragColor.xyz=pow(FragColor.xyz, vec3(1.0/gammaafter));
//	gl_FragColor = gl_FragColor +(pseudoNoise(TEX0.xy*float(FrameCount))+ noiseoffset)*noise/255.0;
   	FragColor = FragColor +(pseudoNoise(vTexCoord.xy*(mod(FrameCount, noiseden)+1))+ noiseoffset)*noise/255.0;
	//FragColor = FragColor +(pseudoNoise(vTexCoord.xy*vec2(mod(FrameCount, noiseden)+22.759))+ noiseoffset)*noise/255.0;
}
