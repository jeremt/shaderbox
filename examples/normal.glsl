
varying vec3 vNormal;

void main() {
  gl_FragColor = 1.0 - vec4(vNormal, 1.0);
}