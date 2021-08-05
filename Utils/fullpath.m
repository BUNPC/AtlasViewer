function pnamefull = fullpath(pname, style)

pnamefull = '';

if ~exist('pname','var')
    return;
end
if ~exist(pname,'file')
    return;
end
if ~exist('style','var')
    style = 'linux';
end

% If path is file, extract pathname
p = ''; 
f = '';
e = '';
if length(pname)>1 && pname(1)=='.' && pname(2)~='/' && pname(2)~='\'
    p = ''; f = pname; e = '';
else
    [p,f,e] = fileparts(pname);
end
pname = p;

% If path to file wasn't specified at all, that is, if only the filename was
% provided without an absolute or relative path, the add './' prefix to file name.
if isempty(pname)
    p = fileparts(['./', pname]);
    pname = p;
end


% get full pathname 
currdir = pwd;

try
    cd(pname);
catch
    try 
        cd(p)
    catch        
        return;
    end
end

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end
pnamefull = [pwd,sep,f,e];
if ~exist(pnamefull, 'file')
    pnamefull = '';
    cd(currdir);
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);



