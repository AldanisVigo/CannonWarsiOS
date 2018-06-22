void main(void) {
    vec2 uv = v_tex_coord;
    uv.y += (cos((uv.y + (u_time * 0.0001)) * 0.0001) * 0.000001) + (cos((uv.y + (u_time * 0.08)) * 0.1) * 0.0000000012);
    uv.x += (sin((uv.y + (u_time * 0.0001)) * 0.0001) * 0.000001) + (sin((uv.y + (u_time * 0.00001)) * 15.0) * 0.00000001);
    gl_FragColor = texture2D(u_texture, uv);
}
