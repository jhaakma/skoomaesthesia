// Skooma Effects

extern float intensity = 0;
extern float cycle = 0;
extern float radius = 0; // do not exceed 1.0

const static float blurinner = 0.5;

//#define DEBUGBLUR
#define OPTI

float2 rcpres;

texture lastshader;
sampler2D s0 = sampler_state { texture = <lastshader>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };

texture tex1 < string src="x0_psychedelic.tga"; >;
sampler SamplerLUT = sampler_state { texture = <tex1>; 
addressu = wrap; addressv = wrap; magfilter = linear; minfilter = linear;
 mipfilter = NONE; };

texture lastpass;

sampler s1 = sampler_state { texture = <lastpass>; addressu = clamp; addressv = clamp; magfilter = linear; minfilter = linear; };

float4 sample0(sampler2D s, float2 t)
{
	return tex2Dlod(s, float4(t, 0, 0));
}

float3 ClutFunc( float3 colorIN, sampler2D LutSampler )
{
	float3 color_offset = float3(0.2, 0.4, 0.3);
	colorIN += color_offset * cycle;
	float2 CLut_pSize = float2(0.00390625, 0.0625);// 1 / float2(256, 16);
	float4 CLut_UV;
	colorIN = saturate(colorIN) * 15.0;
	CLut_UV.w  = floor(colorIN.b);
	CLut_UV.xy = (colorIN.rg + 0.5) * CLut_pSize;
	CLut_UV.x += CLut_UV.w * CLut_pSize.y;
	CLut_UV.z  = CLut_UV.x + CLut_pSize.y;
	return lerp( tex2Dlod(LutSampler, CLut_UV.xyzz).rgb, tex2Dlod(LutSampler, CLut_UV.zyzz).rgb, colorIN.b - CLut_UV.w);
}
float4 lut(in float2 tex:TEXCOORD0): COLOR0
{
	float4 scene = tex2D(s0,tex);
	float3 orig = tex2D(s0,tex).rgb;
	scene.rgb = lerp(orig, ClutFunc(scene.rgb, SamplerLUT), intensity);
	return scene;
}

float4 blurx( float2 TexD : TEXCOORD0 ) : COLOR0
{
	float2 p = TexD * (1.0 - TexD);
	float vig = saturate(p.x * p.y * 15.0);
	vig = smoothstep(0.70, 1.0, 1.0 - vig);
	float2 rcprcp = 1/rcpres.xy;
	vig = radius * vig;
	rcprcp /= vig;

	float4 blr = 0.0;

	#ifdef OPTI
	if(vig > 0.0) {
	#endif
	blr += 0.026109*sample0( s1, (TexD+float2(-15.5,0.0)/rcprcp.xy) );
	blr += 0.034202*sample0( s1, (TexD+float2(-13.5,0.0)/rcprcp.xy) );
	blr += 0.043219*sample0( s1, (TexD+float2(-11.5,0.0)/rcprcp.xy) );
	blr += 0.052683*sample0( s1, (TexD+float2( -9.5,0.0)/rcprcp.xy) );
	blr += 0.061948*sample0( s1, (TexD+float2( -7.5,0.0)/rcprcp.xy) );
	blr += 0.070266*sample0( s1, (TexD+float2( -5.5,0.0)/rcprcp.xy) );
	blr += 0.076883*sample0( s1, (TexD+float2( -3.5,0.0)/rcprcp.xy) );
	blr += 0.081149*sample0( s1, (TexD+float2( -1.5,0.0)/rcprcp.xy) );
	blr += 0.041312*sample0( s1, (TexD+float2(  0.0,0.0)/rcprcp.xy) );
	blr += 0.081149*sample0( s1, (TexD+float2(  1.5,0.0)/rcprcp.xy) );
	blr += 0.076883*sample0( s1, (TexD+float2(  3.5,0.0)/rcprcp.xy) );
	blr += 0.070266*sample0( s1, (TexD+float2(  5.5,0.0)/rcprcp.xy) );
	blr += 0.061948*sample0( s1, (TexD+float2(  7.5,0.0)/rcprcp.xy) );
	blr += 0.052683*sample0( s1, (TexD+float2(  9.5,0.0)/rcprcp.xy) );
	blr += 0.043219*sample0( s1, (TexD+float2( 11.5,0.0)/rcprcp.xy) );
	blr += 0.034202*sample0( s1, (TexD+float2( 13.5,0.0)/rcprcp.xy) );
	blr += 0.026109*sample0( s1, (TexD+float2( 15.5,0.0)/rcprcp.xy) );
	//blr += 0.019227*samplePremul( s0, (TexD+float2( 17.5,0.0)/rcprcp.xy) ).xyz;
	//blr += 0.013658*samplePremul( s0, (TexD+float2( 19.5,0.0)/rcprcp.xy) ).xyz;

	blr /= 0.93423; // renormalize to compensate for the 4 taps I skipped
	#ifdef OPTI
	}
	#endif

	float4 pcol = sample0(s1, TexD);
	float4 col = lerp(blr, pcol, 1.0 - vig);
	return float4(col.rgb, 1.0);
}

float4 blury( float2 TexD : TEXCOORD0 ) : COLOR0
{
	float2 p = TexD * (1.0 - TexD);
	float vig = saturate(p.x * p.y * 15.0);
	vig = smoothstep(blurinner, 1.0, 1.0 - vig);

	float2 rcprcp = 1/rcpres.xy;
	vig = radius * vig;
	rcprcp /= vig;
	float4 blr  = 0.0;

	#ifdef OPTI
	if(vig > 0.0) {
	#endif
	//blr += 0.013658*sample0( s1, (TexD+float2(0.0,-19.5)/rcprcp.xy) ).xyz;
	//blr += 0.019227*sample0( s1, (TexD+float2(0.0,-17.5)/rcprcp.xy) ).xyz;
	blr += 0.026109*sample0( s1, (TexD+float2(0.0,-15.5)/rcprcp.xy) );
	blr += 0.034202*sample0( s1, (TexD+float2(0.0,-13.5)/rcprcp.xy) );
	blr += 0.043219*sample0( s1, (TexD+float2(0.0,-11.5)/rcprcp.xy) );
	blr += 0.052683*sample0( s1, (TexD+float2(0.0, -9.5)/rcprcp.xy) );
	blr += 0.061948*sample0( s1, (TexD+float2(0.0, -7.5)/rcprcp.xy) );
	blr += 0.070266*sample0( s1, (TexD+float2(0.0, -5.5)/rcprcp.xy) );
	blr += 0.076883*sample0( s1, (TexD+float2(0.0, -3.5)/rcprcp.xy) );
	blr += 0.081149*sample0( s1, (TexD+float2(0.0, -1.5)/rcprcp.xy) );
	blr += 0.041312*sample0( s1, (TexD+float2(0.0,  0.0)/rcprcp.xy) );
	blr += 0.081149*sample0( s1, (TexD+float2(0.0,  1.5)/rcprcp.xy) );
	blr +=  0.076883*sample0( s1, (TexD+float2(0.0,  3.5)/rcprcp.xy) );
	blr += 0.070266*sample0( s1, (TexD+float2(0.0,  5.5)/rcprcp.xy) );
	blr +=  0.061948*sample0( s1, (TexD+float2(0.0,  7.5)/rcprcp.xy) );
	blr += 0.052683*sample0( s1, (TexD+float2(0.0,  9.5)/rcprcp.xy) );
	blr += 0.043219*sample0( s1, (TexD+float2(0.0, 11.5)/rcprcp.xy) );
	blr += 0.034202*sample0( s1, (TexD+float2(0.0, 13.5)/rcprcp.xy) );
	blr += 0.026109*sample0( s1, (TexD+float2(0.0, 15.5)/rcprcp.xy) );
	//blr += 0.019227*sample0( s1, (TexD+float2(0.0, 17.5)/rcprcp.xy) ).xyz;
	//blr += 0.013658*sample0( s1, (TexD+float2(0.0, 19.5)/rcprcp.xy) ).xyz;

	blr /= 0.93423; // renormalize to compensate for the 4 taps I skipped
	//blr *= 16;
	#ifdef OPTI
	}
	#endif

	float4 pcol = sample0(s1, TexD);
	float4 col = lerp(blr, pcol, 1.0 - vig);

	#ifdef DEBUGBLUR
	return float4(vig.xxx, 1.0);
	#endif

	return float4(col.rgb, 1.0);
}

technique T0 < string MGEinterface="MGE XE 0"; >
{
	pass { PixelShader = compile ps_3_0 lut(); }
	pass { PixelShader = compile ps_3_0 blurx(); }
	pass { PixelShader = compile ps_3_0 blury(); }
	
}
