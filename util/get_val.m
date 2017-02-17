function[val] = get_val(gpu, mat)

if gpu
    val = gather(mat);
else
    val = mat;
end
