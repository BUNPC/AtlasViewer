% -------------------------------------------------------------------
function [fname, pname] = getCurrPathname(arg)
fname = '';
pname = '';
if isempty(arg)
    [fname, pname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pwd);
    if(fname == 0)
        pname = filesepStandard(pwd);
        fname = [];        
    end
    pname = filesepStandard(pname);
    return
elseif ~ischar(arg{1})
    pname = pwd;
    return;
end

filename = arg{1};
[pname, fname, ext] = fileparts(filename);
pname = filesepStandard(pname);
if ~isempty(fname) && isempty(ext)
    ext = '.SD';
end
directory = dir(pname);

file = [];
if ~isempty(fname)
    file = dir([pname, fname, ext]);
end

if isempty(directory)
    pname = filesepStandard(pwd);
end
if isempty(file)
    [fname, pname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pname);
    if(fname == 0)
        pname = filesepStandard(pwd);
        fname = [];
        return
    end
    ext = '';
end
pname = filesepStandard(pname);
fname = [fname, ext];

