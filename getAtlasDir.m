function dirname = getAtlasDir(arg)

if ~exist('arg','var')
    arg={};
end

dirname = '';
    
% First check argument for existence of atlas dir
if length(arg) > 2
    dirname = arg{2};
end

% No argument supplied or argument supplied but directory 
% doesn't exist. In this case try finding defaults 
if isempty(dirname) | ~exist(dirname,'file')

    % Set the components of the default atlas dir pathname
    % <dirnameApp>/<dirnameRootAtlases>/<defaultAtlases{ii}>
    % for both executable and matlab IDE
    dirnameApp = getAppDir_av();
    if isdeployed()
        dirnameRootAtlases = '';
    else
        dirnameRootAtlases = 'Data/';
    end
    defaultAtlases =  {'Colin','Colin_old'};
    
    
    % Search for atlas in default locations
    for ii=1:length(defaultAtlases)
        dirname = [dirnameApp, dirnameRootAtlases, defaultAtlases{ii}];
        if isAtlasDir(dirname)
            break;
        else
            dirname = '';
        end
    end
    
    % If we didn't find atlas in default locations,
    % ask user to provide an atlas folder.
    if isempty(dirname)
        fprintf('Ask user for atlas dirname.\n');
        dirname = selectAtlasDir(dirname);
    end
    
% Argument supplied, dir exists but is not an atlas dir. It's an invitation
% for the user to pick the atlas from a list of atlases. Supposedly dirname contains
% a database of atlases.
elseif exist(dirname,'file') & ~isAtlasDir(dirname)

    for ii=1:length(defaultAtlases)
        if isAtlasDir([dirname, '/', defaultAtlases])
            dirname = [dirname, '/', defaultAtlases];
        else
            dirname = '';
        end
    end
    if isempty(dirname)
        dirname = selectAtlasDir(dirname);
    end
        
end


% Check if we still have no atlas dir and warn user if that's the case
if isempty(dirname) | dirname==0
    menu('Warning: Couldn''t find default atlas directory.','OK');
    dirname = '';
    return;
end

fprintf('Found atlas: %s\n', dirname);

% Add trailing file separator to dirname if there is none
dirname(dirname=='\') = '/';
if dirname(end) ~= '/' 
    dirname(end+1) = '/';
end

