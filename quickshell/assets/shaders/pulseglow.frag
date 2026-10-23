// assets/shaders/pulseglow.frag
//
// Custom fragment shader: animated pulsing glow ring.
// Written for Qt Quick's ShaderEffect (RHI / Qt6), targeting the
// "rhi" shader pipeline (GLSL 4.40 core via qsb, or GLSL ES 3.0
// equivalent — see notes below).
//
// USAGE
// -----
// Qt6's ShaderEffect expects pre-compiled .qsb shaders produced by
// the `qsb` tool (ships with qt6-declarative-dev / qt6-shadertools).
// Compile this source with:
//
//   qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 \
//       -o pulseglow.frag.qsb pulseglow.frag
//
// Then reference it from QML:
//
//   ShaderEffect {
//       property real time: 0
//       property color glowColor: Colors.colAccent
//       fragmentShader: "qrc:/shaders/pulseglow.frag.qsb"
//   }
//
// If `qsb` is not available, components/GlowRect.qml (MultiEffect-based)
// provides a dependency-free static glow as a fallback — this shader is
// an optional enhancement for users who want an animated pulse.
//
// UNIFORMS (declared via QML `property` on the ShaderEffect)
// -------------------------------------------------------------
//   float time        — seconds, drives the pulse animation
//   vec4  glowColor    — RGBA tint (from Colors.colAccent)
//   float intensity    — 0..1 overall strength
//   float pulseSpeed   — pulses per second

#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    float time;
    float intensity;
    float pulseSpeed;
    vec4  glowColor;
};

void main() {
    // Distance from the center, normalized 0..1 (0 = center, 1 = edge)
    vec2 centered = qt_TexCoord0 - vec2(0.5);
    float dist = length(centered) * 2.0;

    // Pulsing ring: sine wave drives a soft ring radius over time
    float pulse = 0.5 + 0.5 * sin(time * pulseSpeed * 6.28318);
    float ringRadius = mix(0.4, 0.9, pulse);

    // Soft ring falloff around ringRadius
    float ring = 1.0 - smoothstep(0.0, 0.35, abs(dist - ringRadius));

    // Fade out toward the very edge so the glow doesn't hard-clip
    float edgeFade = 1.0 - smoothstep(0.85, 1.0, dist);

    float alpha = ring * edgeFade * intensity * qt_Opacity;

    fragColor = vec4(glowColor.rgb, glowColor.a * alpha);
}
