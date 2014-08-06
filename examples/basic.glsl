
uniform sampler2D texture;
uniform vec3 color;
uniform float rate;

varying vec2 vUv;

void main() {
  gl_FragColor = texture2D(texture, vUv);
  gl_FragColor *= vec4(color, 1.0);
}