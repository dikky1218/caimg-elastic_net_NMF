
function [] = export2avi_from_result(W, H, Wb, Hb, width, height, file_name)

V=W*H+Wb*Hb;

export2avi(V, width, height, file_name)
