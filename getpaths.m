function [paths, wspaths, paths_excl_str] = getpaths(options)

DEBUG = 0;

paths = {...
    '/'; ...
    '/Install'; ...
    '/Axesv'; ...
    '/Data'; ...
    '/Data/Colin'; ...
    '/Digpts'; ...
    '/ForwardModel'; ...
    '/Group'; ...
    '/Group'; ...
    '/Guiobj'; ...
    '/HbConc'; ...
    '/Headsurf'; ...
    '/Headvol'; ...
    '/ImgRecon'; ...
    '/Labelssurf'; ...
    '/Pialsurf'; ...
    '/Pialvol'; ...
    '/Probe'; ...
    '/Probe/registerDigpts'; ...
    '/Probe/registerSprings'; ...
    '/Refpts'; ...
    '/Tools'; ...
    '/Utils'; ...
    '/Utils/fs2viewer'; ...
    '/ezmapper'; ...
    '/freesurfer'; ...
    '/iso2mesh'; ...
    '/iso2mesh/bin'; ...
    '/metch'; ...
    '/NIRS_Probe_Designer_V1'; ...
    '/NIRS_Probe_Designer_V1/functions'; ...
    '/SDgui'; ...
    '/SDgui/lambda'; ...
    '/SDgui/optode_tbls'; ...
    '/SDgui/optode_tbls2'; ...
    '/SDgui/probe_geometry_axes'; ...
    '/SDgui/probe_geometry_axes2'; ...
    '/SDgui/sample_data'; ...
    '/SDgui/sd_data'; ...
    '/SDgui/sd_file'; ...
    '/SDgui/utils'; ...
    '/tMCimg'; ...
    '/tMCimg/bin/Darwin'; ...
    '/tMCimg/bin/Linux'; ...
    '/tMCimg/bin/Win'; ...
    };


wspaths = {};
paths_excl_str = {};

if options.conflcheck
        
    % Get all workspace paths that have similar functions sets with current applications
    appmainfunc = {'Homer2_UI.m','Homer3.m','brainScape.m'};
    
    kk=1;
    wsidx = [];
    for ii=1:length(appmainfunc)
        
        while 1
            
            [paths_excl, foo] = getactivewspace(appmainfunc{ii});
            if isempty(paths_excl)
                break;
            end
            
            wspaths{kk,1} = foo;
            if pathscompare(wspaths{kk}, pwd)
                wsidx = kk;
            end
            
            paths_excl_str{kk} = '';
            for jj=1:length(paths_excl)
                if DEBUG
                    fprintf('Removing path %s\n', paths_excl{jj});
                end
                if isempty(paths_excl_str{kk})
                    paths_excl_str{kk} = paths_excl{jj};
                else
                    paths_excl_str{kk} = [paths_excl_str{kk}, delimiter, paths_excl{jj}];
                end
            end
            rmpath(paths_excl_str{kk});
            kk=kk+1;
            
        end
        
    end

    
    % Change the order of precedence of all the conflicting workspaces to
    % the current one as primary workspace
    if ~isempty(wsidx)
        strtmp = wspaths{1};
        celltmp = paths_excl_str{1};
        
        wspaths{1} = wspaths{wsidx};
        paths_excl_str{1} = paths_excl_str{wsidx};
        
        wspaths{wsidx} = strtmp;
        paths_excl_str{wsidx} = celltmp;        
    end
    
end

