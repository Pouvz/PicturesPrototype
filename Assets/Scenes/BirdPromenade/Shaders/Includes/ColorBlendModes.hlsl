

float3 Blend_Overlay_float3(float3 Base, float3 Blend, float Opacity)
{
    float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float3 result2 = 2.0 * Base * Blend;
    float3 zeroOrOne = step(Base, 0.5);
    float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    return lerp(Base, Out, Opacity);
}

float4 Blend_Screen_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    return lerp(Base, Out, Opacity);
}

float4 Blend_SoftLight_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
    float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
    float4 zeroOrOne = step(0.5, Blend);
    float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    return lerp(Base, Out, Opacity);
}


float4 Blend_ColorDodge_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base / (1.0 - clamp(Blend, 0.000001, 0.999999));
    return lerp(Base, Out, Opacity);
}


float4 Blend_LinearDodge_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base + Blend;
    return  lerp(Base, Out, Opacity);
}

float4 Blend_Lighten_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = max(Blend, Base);
    return lerp(Base, Out, Opacity);
}

float4 Blend_Darken_float4(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = min(Blend, Base);
    return lerp(Base, Out, Opacity);
}

float3 DesaturateLinear(float3 Color,float saturation)
{
    float grayscale = (Color.r * 0.33333) + (Color.g * 0.33333) + (Color.b * 0.33333);
    return lerp(grayscale,Color,saturation);
}

float3 DesaturateNatural(float3 color, float saturation)
{
    float grayscale = 0.0;

    grayscale += color.r * 0.333333333;
    grayscale += color.g * 0.599999999;
    grayscale += color.b * 0.111111111;

    return lerp(grayscale,color,saturation);
}

float4 Exposure(float4 color,float exposure)
{
    float3 ex = color.rgb * pow(2,exposure);
    return float4(ex,color.a);
}


