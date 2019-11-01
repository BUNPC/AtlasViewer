function saveObjects(filename, varargin)

if isempty(varargin)
    return;
end

vrnum = AtlasViewerGUI_version();

hwait = waitbar(0,'Please wait for AtlasViewer to save the state ...');

cmdstr = 'save(filename,''-mat'', ''vrnum''';
for ii=1:length(varargin)
    varargin{ii}.handles = [];
    if ~isempty(varargin{ii}.prepObjForSave)
        varargin{ii} = varargin{ii}.prepObjForSave(varargin{ii});
    end
    eval(sprintf('%s = varargin{ii};', varargin{ii}.name));
    cmdstr = sprintf('%s, ''%s''', cmdstr, varargin{ii}.name);
end
cmdstr = sprintf('%s);', cmdstr);
eval(cmdstr);

close(hwait);