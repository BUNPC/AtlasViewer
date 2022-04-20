function dirname = getAtlasDir(arg)
global logger

logger = InitLogger(logger);

if ~exist('arg','var')
    arg={};
end

dirname = '';
    
% First check argument for existence of atlas dir
if length(arg) > 2
    dirname = arg{2};
end



% Set the components of the default atlas dir pathname
% <dirnameApp>/<dirnameRootAtlases>/<defaultAtlases{ii}>
% for both executable and matlab IDE
dirnameApp = getAppDir();
defaultAtlases =  {'Colin','Colin_old'};

logger.Write('getAtlasDir:   dirnameApp - %s\n', dirnameApp);

% No argument supplied or argument supplied but directory 
% doesn't exist. In this case try finding defaults 
if isempty(dirname) || ~exist(dirname,'file')
           
    % Search for atlas in default locations
    for ii = 1:length(defaultAtlases)
        dirname = [dirnameApp, 'Data/', defaultAtlases{ii}];
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
elseif exist(dirname,'file') && ~isAtlasDir(dirname)

    for ii = 1:length(defaultAtlases)
        if isAtlasDir([dirname, '/', defaultAtlases])
            dirname = [dirname, '/', defaultAtlases]; %#ok<AGROW>
        else
            dirname = '';
        end
    end
    if isempty(dirname)
        dirname = selectAtlasDir(dirname);
    end
    
end


% Check if we still have no atlas dir and warn user if that's the case
if isempty(dirname)
    menu('Warning: Couldn''t find default atlas directory.','OK');
    return;
end

dirname = filesepStandard(dirname);
logger.Write('Found atlas: %s\n', dirname);



