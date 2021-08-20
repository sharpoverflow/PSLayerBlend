// a => 物体色/混合色
// b => 底色/背景色/缓冲色
// b 使用 ShaderLab command: GrabPass 获取
// 因为GrabPass不支持URP和HDRP, 所以混合模式也不支持 => https://docs.unity3d.com/Manual/SL-GrabPass.html
// https://helpx.adobe.com/photoshop/using/blending-modes.html


fixed4 AlphaMix(fixed4 result, fixed4 a, fixed4 b, float mixValue)
{
	result = clamp(result, 0, 1);
	return result * a.a + result * (1 - mixValue) * (1 - a.a) + b * (1 - a.a) * mixValue;
}


// ==================== 0 ====================

// 清除 Clear

// 溶解 Dissolve
// Edits or paints each pixel to make it the result color. However, the result color is a random replacement of the pixels with the base color or the blend color, depending on the opacity at any pixel location.
float Random(float2 uv)
{
	return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
}
fixed4 Dissolve(fixed4 a, fixed4 b, float2 uv)
{
	float r = Random(uv);
	return r < a.a ? a : b;
}

// 忽略透明 IgnoreAlpha


// ==================== 1 ====================

// 变暗 Darken
// Looks at the color information in each channel and selects the base or blend color—whichever is darker—as the result color. Pixels lighter than the blend color are replaced, and pixels darker than the blend color do not change.
fixed4 Darken(fixed4 a, fixed4 b)
{
	return min(a, b);
}

// 正片叠底 Multiply
// Looks at the color information in each channel and multiplies the base color by the blend color. The result color is always a darker color. Multiplying any color with black produces black. Multiplying any color with white leaves the color unchanged. When you’re painting with a color other than black or white, successive strokes with a painting tool produce progressively darker colors. The effect is similar to drawing on the image with multiple marking pens.
fixed4 Multiply(fixed4 a, fixed4 b)
{
	return a * b;
}

// 颜色加深 ColorBurn
// 按照Photoshop的说明需要在b==1时直接赋予1色,会造成画面破裂,如果必要的话可以取消注释
// Looks at the color information in each channel and darkens the base color to reflect the blend color by increasing the contrast between the two. Blending with white produces no change.
fixed4 ColorBurnWithoutLimit(fixed4 a, fixed4 b)
{
	return 1 - (1 - b) / a;
}
fixed4 ColorBurn(fixed4 a, fixed4 b)
{
	return /*b == 1 ? b :*/ ColorBurnWithoutLimit(a, b);
}

// 线性加深 LinearBurn
// Looks at the color information in each channel and darkens the base color to reflect the blend color by decreasing the brightness. Blending with white produces no change.
fixed4 LinearBurn(fixed4 a, fixed4 b)
{
	return a + b - 1;
}

// 深色 DarkerColor
// Compares the total of all channel values for the blend and base color and displays the lower value color. Darker Color does not produce a third color, which can result from the Darken blend, because it chooses the lowest channel values from both the base and the blend color to create the result color.
fixed4 DarkerColor(fixed4 a, fixed4 b)
{
	fixed4 ab01 = step(a.r + a.g + a.b, b.r + b.g + b.b);
	return a * ab01 + b * (1 - ab01);
}


// ==================== 2 ====================

// 变亮 Lighten
// Looks at the color information in each channel and selects the base or blend color—whichever is lighter—as the result color. Pixels darker than the blend color are replaced, and pixels lighter than the blend color do not change.
fixed4 Lighten(fixed4 a, fixed4 b)
{
	return max(a, b);
}

// 滤色 Screen
// Looks at each channel’s color information and multiplies the inverse of the blend and base colors. The result color is always a lighter color. Screening with black leaves the color unchanged. Screening with white produces white. The effect is similar to projecting multiple photographic slides on top of each other.
fixed4 Screen(fixed4 a, fixed4 b)
{
	return  1 - (1 - a) * (1 - b);
}

// 颜色减淡 ColorDodge
// Looks at the color information in each channel and brightens the base color to reflect the blend color by decreasing contrast between the two. Blending with black produces no change.
fixed4 ColorDodge(fixed4 a, fixed4 b)
{
	return  a != 1 ? b / (1 - a) : a;
}

// 线性减淡（添加） LinearDodge (Add)
// Looks at the color information in each channel and brightens the base color to reflect the blend color by increasing the brightness. Blending with black produces no change.
fixed4 LinearDodge(fixed4 a, fixed4 b)
{
	return a + b;
}

// 浅色 LighterColor
// Compares the total of all channel values for the blend and base color and displays the higher value color.Lighter Color does not produce a third color, which can result from the Lighten blend, because it chooses the highest channel values from both the base and blend color to create the result color.
fixed4 LighterColor(fixed4 a, fixed4 b)
{
	//return DarkerColor(b, a); 
	fixed4 ab01 = step(a.r + a.g + a.b + a.a, b.r + b.g + b.b + b.a);
	return b * ab01 + a * (1 - ab01);
}


// ==================== 3 ====================

// 叠加 Overlay
// Multiplies or screens the colors, depending on the base color.Patterns or colors overlay the existing pixels while preserving the highlights and shadows of the base color.The base color is not replaced, but mixed with the blend color to reflect the lightness or darkness of the original color.
fixed4 Overlay(fixed4 a, fixed4 b)
{
	return b < 0.5 ? 2 * a * b : 1 - 2 * (1 - a) * (1 - b);
}

// 柔光 SoftLight
// Darkens or lightens the colors, depending on the blend color.The effect is similar to shining a diffused spotlight on the image.If the blend color(light source) is lighter than 50 % gray, the image is lightened as if it were dodged.If the blend color is darker than 50 % gray, the image is darkened as if it were burned in.Painting with pure black or white produces a distinctly darker or lighter area, but does not result in pure black or white.
fixed4 SoftLight(fixed4 a, fixed4 b)
{
	return a < 0.5 ? b * a * 2 + b * b * (1 - a * 2) : b * (1 - a) * 2 + sqrt(b) * (2 * a - 1);
}

// 强光 HardLight
// Multiplies or screens the colors, depending on the blend color.The effect is similar to shining a harsh spotlight on the image.If the blend color(light source) is lighter than 50 % gray, the image is lightened, as if it were screened.This is useful for adding highlights to an image.If the blend color is darker than 50 % gray, the image is darkened, as if it were multiplied.This is useful for adding shadows to an image.Painting with pure black or white results in pure black or white.
fixed4 HardLight(fixed4 a, fixed4 b)
{
	return Overlay(b, a);
}

// 亮光 VividLight
// Burns or dodges the colors by increasing or decreasing the contrast, depending on the blend color.If the blend color(light source) is lighter than 50 % gray, the image is lightened by decreasing the contrast.If the blend color is darker than 50 % gray, the image is darkened by increasing the contrast.
fixed4 VividLight(fixed4 a, fixed4 b)
{
	return a < 0.5 ? ColorBurnWithoutLimit(2 * a, b) : ColorDodge(2 * (a - 0.5), b);
}

// 线性光 LinearLight
// Burns or dodges the colors by decreasing or increasing the brightness, depending on the blend color.If the blend color(light source) is lighter than 50 % gray, the image is lightened by increasing the brightness.If the blend color is darker than 50 % gray, the image is darkened by decreasing the brightness.
fixed4 LinearLight(fixed4 a, fixed4 b)
{
	return a < 0.5 ? LinearBurn(2 * a, b) : LinearDodge(2 * (a - 0.5), b);
}

// 点光 PinLight
// Replaces the colors, depending on the blend color.If the blend color(light source) is lighter than 50 % gray, pixels darker than the blend color are replaced, and pixels lighter than the blend color do not change.If the blend color is darker than 50 % gray, pixels lighter than the blend color are replaced, and pixels darker than the blend color do not change.This is useful for adding special effects to an image.
fixed4 PinLight(fixed4 a, fixed4 b)
{
	return a < 0.5 ? Darken(2 * a, b) : Lighten(2 * (a - 0.5), b);
}

// 实色混合 HardMix
// Adds the red, green and blue channel values of the blend color to the RGB values of the base color.If the resulting sum for a channel is 255 or greater, it receives a value of 255; if less than 255, a value of 0. Therefore, all blended pixels have red, green, and blue channel values of either 0 or 255. This changes all pixels to primary additive colors(red, green, or blue), white, or black.
fixed4 HardMix(fixed4 a, fixed4 b)
{
	return VividLight(a, b) < 0.5 ? 0 : 1;
}


// ==================== 4 ====================

// 差值 Difference
// Looks at the color information in each channel and subtracts either the blend color from the base color or the base color from the blend color, depending on which has the greater brightness value.Blending with white inverts the base color values; blending with black produces no change.
fixed4 Difference(fixed4 a, fixed4 b)
{
	return abs(a - b);
}

// 排除 Exclusion
// Creates an effect similar to but lower in contrast than the Difference mode.Blending with white inverts the base color values.Blending with black produces no change.
fixed4 Exclusion(fixed4 a, fixed4 b)
{
	return a + b - a * b * 2;
}

// 减去 Subtract
// Looks at the color information in each channel and subtracts the blend color from the base color.In 8 - and 16 - bit images, any resulting negative values are clipped to zero.
fixed4 Subtract(fixed4 a, fixed4 b)
{
	return b - a;
}

// 划分 Divide
// Looks at the color information in each channel and divides the blend color from the base color.
fixed4 Divide(fixed4 a, fixed4 b)
{
	return b / a;
}


// ==================== 5 ====================

float MaxRGB(fixed4 color)
{
	float maxRG = max(color.r, color.g);
	return max(color.b, maxRG);
}

float MinRGB(fixed4 color)
{
	float minRG = min(color.r, color.g);
	return min(color.b, minRG);
}

// Y′601
float CalcLuma(fixed4 color)
{
	return 0.298839 * color.r + 0.586811 * color.g + 0.114350 * color.b;
}

float CalcLuma2(fixed4 color)
{
	return pow(pow(color.r, 2.2) * 0.2973 + pow(color.g, 2.2) * 0.6274 + pow(color.b, 2.2) * 0.0753, 1 / 2.2);
}

// http://www.beneaththewaves.net/Photography/Secrets_of_Photoshops_Colour_Blend_Mode_Revealed_Sort_Of.html
fixed4 ClipColor(fixed4 color, float luma)
{
	float maxRGB = MaxRGB(color);
	float minRGB = MinRGB(color);
	if (minRGB < 0)
	{
		return luma + (color - luma) * luma / (luma - minRGB);
	}
	if (maxRGB > 1)
	{
		return luma + (color - luma) * (1 - luma) / (maxRGB - luma);
	}
	return color;
}

// https://en.wikipedia.org/wiki/HSL_and_HSV
// Luma, chroma and hue to RGB
// H ∈ [0°, 360°], chroma C ∈ [0, 1], and luma Y′601 ∈ [0, 1]
fixed4 HCL2RGB(float hue, float chroma, float luma, float alpha)
{
	float _hue = hue / 60.0;
	float x = chroma * (1 - abs((_hue % 2) - 1));
	fixed4 _color = fixed4(0, 0, 0, 0);
	int hueInt = (int)(_hue);
	switch (hueInt)
	{
	case 0:
		_color = fixed4(chroma, x, 0, 0);
		break;
	case 1:
		_color = fixed4(x, chroma, 0, 0);
		break;
	case 2:
		_color = fixed4(0, chroma, x, 0);
		break;
	case 3:
		_color = fixed4(0, x, chroma, 0);
		break;
	case 4:
		_color = fixed4(x, 0, chroma, 0);
		break;
	case 5:
	case 6:
		_color = fixed4(chroma, 0, x, 0);
		break;
	}
	if (hue < 0)_color = fixed4(0, 0, 0, 1);
	float m = luma - CalcLuma(_color);
	return ClipColor(_color + fixed4(m, m, m, 0), luma);
}

fixed4 RGB2HCL(fixed4 color)
{
	float maxRGB = MaxRGB(color);
	float minRGB = MinRGB(color);

	float chroma = maxRGB - minRGB;
	float _hue = 0;

	if (chroma != 0)
	{
		if (maxRGB == color.r)
		{
			if (color.g >= color.b)
			{
				_hue = ((color.g - color.b) / chroma);
			}
			else
			{
				_hue = ((color.g - color.b) / chroma) + 6;
			}
		}
		else
		{
			if (maxRGB == color.g)
			{
				_hue = ((color.b - color.r) / chroma) + 2;
			}
			else
			{
				_hue = ((color.r - color.g) / chroma) + 4;
			}
		}
	}
	else
	{
		_hue = -1;
	}

	float hue = _hue * 60;
	float luma = CalcLuma(color);

	return fixed4(hue, chroma, luma, 1);
}

// 色相 Hue
// Creates a result color with the luminance and saturation of the base color and the hue of the blend color.
fixed4 Hue(fixed4 a, fixed4 b)
{
	fixed4 hclA = RGB2HCL(a);
	fixed4 hclB = RGB2HCL(b);
	return HCL2RGB(hclA.x, hclB.y, hclB.z, 1);
}

// 饱和度 Saturation
// Creates a result color with the luminance and hue of the base color and the saturation of the blend color.Painting with this mode in an area with no(0) saturation(gray) causes no change.
fixed4 Saturation(fixed4 a, fixed4 b)
{
	fixed4 hclA = RGB2HCL(a);
	fixed4 hclB = RGB2HCL(b);
	return HCL2RGB(hclB.x, hclA.y, hclB.z, 1);
}

// 颜色 Color
// Creates a result color with the luminance of the base color and the hue and saturation of the blend color.This preserves the gray levels in the image and is useful for coloring monochrome images and for tinting color images.
fixed4 Color(fixed4 a, fixed4 b)
{
	fixed4 hclA = RGB2HCL(a);
	fixed4 hclB = RGB2HCL(b);
	return HCL2RGB(hclA.x, hclA.y, hclB.z, 1);
}

// 明度 Luminosity
// Creates a result color with the hue and saturation of the base color and the luminance of the blend color.This mode creates the inverse effect of Color mode.
fixed4 Luminosity(fixed4 a, fixed4 b)
{
	fixed4 hclA = RGB2HCL(a);
	fixed4 hclB = RGB2HCL(b);
	return HCL2RGB(hclB.x, hclB.y, hclA.z, 1);
}
