function [fluenceProf, readonly] = loadFluenceProf(filenm, varargin)

fluenceProf = [];
readonly = false;

% Load fluence profile from file
fields = varargin;
if isempty(fields)
    fprintf('load(''%s'')\n', filenm);
    fluenceProf0 = load(filenm);
else
    strLst=[];
    n=length(fields);
    for ii=1:n
        if ii<n
            strLst = [strLst '''' fields{ii} ''','];
        elseif ii==n
            strLst = [strLst '''' fields{ii} ''''];
        end
    end
    cmd = sprintf('fluenceProf0 = load(''%s'', %s, ''-mat'');', filenm, strLst);    
    if n==1 & strcmp(fields{1}, 'index')
        fprintf('%s\n', cmd);
    end
    eval(cmd);
end

% Support for loading DRM-protected fluence profile
if isfield(fluenceProf0, 'intensities') && drmIsEncoded(fluenceProf0.intensities)
    [path, ~, ~] = fileparts(filenm);
    fluenceProf0.intensities = drmDecode(fluenceProf0.intensities, path);
    readonly = true;
end

% Make sure the loaded profile follows current format
fluenceProf = initFluenceProf();
fields = fieldnames(fluenceProf);
n=length(fields);
for ii=1:n
    if isfield(fluenceProf0, fields{ii})
        eval(sprintf('fluenceProf.%s = fluenceProf0.%s;',fields{ii},fields{ii}));
    end
end


