extern vec3 iResolution;
extern Image iChannel0;
extern Image iChannel1;
uniform float iTime;  // Ensure this is defined and used as a uniform

#define MARCH_STEPS 16
#define PI 3.14159

// Quadric and Capsule functions
number Quadric(vec3 p, vec4 r) { return (dot(p * r.xyz, p) - r.w) / length(2.0 * r.xyz * p); }
number CapsuleY(vec3 p, vec3 r) { return length(vec3(p.x, p.y - clamp(p.y, r.x, r.y), p.z)) - r.z; }

// Rotation function
vec2 rotate(vec2 v, number angle) {
    return cos(angle) * v + sin(angle) * vec2(v.y, -v.x);
}

// Distance Estimation Function
number DE(vec3 p, vec2 c, vec4 o) {
    p.xz -= c + o.xy;
    number a = atan(o.z, o.w);
    p.xz = rotate(p.xz, PI - a);
    o.zw = normalize(o.zw);
    number langle = sin(dot(o.zw, o.xy) * 4.0 * PI) * 0.5;
    p *= 5.0;
    number d1 = length(p) - 1.0;
    p.z -= 1.0 + langle * 0.2;
    d1 = min(d1, length(p - vec3(langle * 0.2, 0.55, 0.88)) - 0.1);
    
    number d2 = length(p) - 1.0;
    p.z += 1.75 + langle * 0.1;
    p.y -= 0.9 + langle * 0.1;
    d2 = min(d2, Quadric(p, vec4(1.0, 1.0, 0.5, 0.25)));

    p.x = abs(p.x) - 0.5;
    number d3 = length(p - vec3(0.0, 0.3, 0.3)) - 0.05;
    p.z -= 1.25;
    p.y += 1.5;
    p.z = abs(p.z) - 0.9;
    p.zy = rotate(p.zy, langle);
    d3 = min(d3, CapsuleY(p, vec3(-1.0, 0.0, 0.15)));

    number k = 8.0;
    number d = -log(exp(-k * d1) + exp(-k * d2) + exp(-k * d3)) / k;
    return d / 5.0;
}

// Texture lookup replacement
vec4 T(vec2 coords) {
    return Texel(iChannel0, coords / iResolution.xy);
}

// Love2D effect function
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
    vec2 uv = (pixel_coords - iResolution.xy * 0.5) / iResolution.x;
    vec4 st = T(vec2(103.5));
    number h = sin(iTime + sin(iTime * 0.7));
    vec3 ro = vec3(st.x, 4.0 + h, st.y);
    vec3 rd = vec3(uv.x, -1.0, uv.y);
    rd.yz = rotate(rd.yz, 1.1 - h * 0.1);
    rd.xz = rotate(rd.xz, st.z + sin(iTime * 0.9) * 0.1);
    rd = normalize(rd);

    number t = (-0.36 - ro.y) / rd.y;
    number maxt = (0.4 - ro.y) / rd.y;
    number d, od = 1.0, md = 1.0;
    
    for (int i = 0; i < MARCH_STEPS; i++) {
        vec3 p = ro + rd * t;
        vec2 c = floor(p.xz);
        vec4 o = T(c);
        d = length(p) - 1.0;
        if (o.x > -2.5) d = min(d, DE(p, c, o));
        t += d;
        md = min(md, d);
        if (d < 0.002 || t > maxt) break;
        od = d;
    }

    vec3 col = Texel(iChannel1, ro.xz * 0.001).rgb * 0.5 + vec3(0.0, 0.2, 0.0);
    col *= vec3(0.4) * clamp(md * 56.0, 0.0, 1.0);
    
    return vec4(col, 1.0);
}
