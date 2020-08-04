function fwmodel = buildMC(fwmodel)

% Before bugging the user to locate the exe file, try auto-building it
if exist(fwmodel.mc_rootpath,'dir')==7
    currdir = pwd;
    cd(fwmodel.mc_rootpath);
   
    if ismac() || islinux()
        cmd = sprintf('make opt');
        system(cmd);
    elseif ispc()
        
    end
    
    cd(currdir);
    
    % See if the build attempt succeded and we have it now
    [mc_exepath, mc_exename, mc_appname, ext] = ...
        searchDirForMCApp(fwmodel.mc_exepath, fwmodel.platform);
    fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, ext);                    
    if ~isempty(fwmodel.mc_exename)
        return;
    end
end

