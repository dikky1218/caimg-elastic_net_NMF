function [] = addlog( path, log, mode )

if(nargin<2)
    mode='add';
end

m=[];
if(strcmp(mode, 'new'))
    m=sprintf('system(\''echo %s > %s\'')', log, path); 
elseif(strcmp(mode, 'add'))
    m=sprintf('system(\''echo %s >> %s\'')', log, path);
end

fprintf('%s\n', m);
eval(m);

end
