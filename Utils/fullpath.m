function pnamefull = fullpath(pname)

pnamefull = '';

if ~exist(pname,'file')
    return;
end


% If path is file, extract pathname
p = ''; 
f = '';
e = '';
if exist(pname,'file')==2
    [p,f,e] = fileparts(pname);
    pname = p;
end

% get full pathname 
currdir = pwd;

if exist(pname,'dir')==7
    cd(pname);
else
    return;
end

d = pwd;
if d(end)=='/' || d(end)=='\'
    d(end)='';
end
pnamefull = [d,'/',f,e];
k = find(pnamefull=='\');
pnamefull(k) = '/';
cd(currdir);


