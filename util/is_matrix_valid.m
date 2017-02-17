function[is_valid] = is_matrix_valid(gpu, mat, mat_name, i)

is_valid = true;

if ~get_val(gpu, any(mat))
    fprintf('i : %d\n',i);
    fprintf('%s is zero matrix\n', mat_name);
    is_valid = false;
elseif get_val(gpu, isnan(mat))
    fprintf('i : %d\n',i);
    fprintf('%s is nan.\n', mat_name);
    is_valid = false;
end
