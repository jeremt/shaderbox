#ifndef GL_ES
#define lowp
#define mediump
#define highp
#endif

uniform mediump sampler2D texture;
uniform mediump float rate;
varying highp vec2 vUv;

const vec2 resolution = vec2(512, 512);

// colortools

highp float hueDistance(highp float hue0, highp float hue1) {
    highp float delta = abs(hue1 - hue0);
    return min(delta, 1.0 - delta);
}

mediump vec3 rgbToHsl(mediump vec3 color) {    
    mediump float minRGB = min(min(color.r, color.g), color.b); // Min. value of RGB
    mediump float maxRGB = max(max(color.r, color.g), color.b); // Max. value of RGB
    mediump float delta = maxRGB - minRGB;                      // Delta of RGB values
    mediump float sum = maxRGB + minRGB;
    
    // Init to gray, Lmuminance with no chroma 
    mediump vec3 hsl = vec3(0.0, 0.0, sum * (1.0 / 2.0));

    //Chromatic data
    if (delta != 0.0) {        
        // Saturation
        if (hsl.z > 0.5)
            sum = 2.0 - sum; 
        hsl.y = delta / sum;

        // Hue
        mediump vec3 deltaRGB = ((vec3(maxRGB) - color) * vec3(1.0 / 6.0) / vec3(delta) + vec3(1.0 / 2.0));
        // if (color.r == maxRGB )
        hsl.x = deltaRGB.b - deltaRGB.g; // Hue
        if (color.g == maxRGB)
            hsl.x = (1.0 / 3.0) + deltaRGB.r - deltaRGB.b; // Hue
        else if (color.b == maxRGB)
            hsl.x = (2.0 / 3.0) + deltaRGB.g - deltaRGB.r; // Hue
        hsl.x = fract(hsl.x);
    }

    return hsl;
}

mediump float hueToRgb(mediump float f1, mediump float f2, mediump float hue) {
    hue = fract(hue);

    if (hue < (1.0 / 6.0))
        return f1 + (f2 - f1) * 6.0 * hue;
    else if (hue < (1.0 / 2.0))
        return f2;
    else if (hue < (2.0 / 3.0))
        return f1 + (f2 - f1) * (-6.0*hue + (6.0 * 2.0 / 3.0));
    else
        return f1;
}

mediump vec3 hslToRgb(mediump vec3 hsl) {
    mediump vec3 rgb = vec3(hsl.z); // Init to gray (Luminance)

    if (hsl.y != 0.0) {
        mediump float f2 = hsl.z + hsl.y - hsl.y * hsl.z;
        if (hsl.z < 0.5)
            f2 = hsl.z + hsl.z * hsl.y;
            
        mediump float f1 = 2.0 * hsl.z - f2;
        
        rgb.r = hueToRGB(f1, f2, hsl.x + (1.0/3.0));
        rgb.g = hueToRGB(f1, f2, hsl.x);
        rgb.b = hueToRGB(f1, f2, hsl.x - (1.0/3.0));
    }
    
    return rgb;
}

mediump vec4 bw(mediump vec4 color) {
    highp float luminance = dot(color.rgb, vec3(0.2125, 0.7154, 0.0721));
    return vec4(vec3(luminance), color.a);
}

float luminance(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// utils

#define floor(t, coef) (float(int(t * coef)) / coef)

vec3 px(const int x, const int y) {
    vec2 uv = (vUv.xy + vec2(x, y) / resolution);
    return texture2D(texture, uv).xyz;
}

// main

vec3 edge(void) {
    vec3 hc = px(-1,-1) *  1.0 + px( 0,-1) *  2.0
             +px( 1,-1) *  1.0 + px(-1, 1) * -1.0
             +px( 0, 1) * -2.0 + px( 1, 1) * -1.0;

    vec3 vc = px(-1,-1) *  1.0 + px(-1, 0) *  2.0
             +px(-1, 1) *  1.0 + px( 1,-1) * -1.0
             +px( 1, 0) * -2.0 + px( 1, 1) * -1.0;

    float coef = pow(luminance(vc * vc + hc * hc), 0.6);
    if (coef > 0.4)
      return vec3(1) * rate;
    return vec3(0);
}

mediump vec3 cartoon_bw(mediump vec3 x) {
  x = bw(vec4(x, 1.0)).rgb;
  return vec3(float(int(x[0] * 8.0)) / 8.0);
}

mediump vec3 cartoon_rgb(mediump vec3 x) {
  vec3 hsl = rgbToHsl(x);
  hsl[0] = floor(hsl[0], 30.0);
  hsl[1] = floor(hsl[1], 10.0);
  hsl[2] = floor(hsl[2], 10.0);
  return hslToRgb(hsl);
}

void main(void) {
    gl_FragColor = texture2D(texture, vUv);
    highp vec4 color = vec4(cartoon_rgb(gl_FragColor.rgb), gl_FragColor.a);
    color *= vec4(vec3(1) - edge(), 1.0);
    gl_FragColor = color * rate + gl_FragColor * (1.0 - rate);
}
