function r = gitDelete(repo, pname)
r = -1;
if ~exist('repo','var')
    repo = filesepStandard(pwd);
end
if ~exist('cacheonly','var')
    cacheonly = 0;
end

currdir = pwd;
cd(repo)

if ~ispathvalid(pname)
    return
end

ii = 1;
cached = '';
if ispathvalid([repo, '.git/modules/', pname])
    cached = '--cached';
end

if isfile_private(pname)
    cmds{ii} = sprintf('git rm %s ./%s', cached, pname); ii = ii+1;
else
    cmds{ii} = sprintf('git rm -r %s ./%s', cached, pname); ii = ii+1;
end
if ~isempty(cached)
    cmds = deleteShellCmd(repo, cmds); ii = ii+1;
end

[~, msgs] = exeShellCmds(cmds);

for ii = 1:length(cmds)
    fprintf('  %s\n', cmds{ii});
    fprintf('  %s\n', msgs{ii});
end

cd(currdir);



% ---------------------------------------------------------------------
function cmds = deleteShellCmd(pname, cmds)
if ispc()    
    if isfile_private(pname)
        cmds{end+1} = sprintf('del %s /f /q', pname);
    else
        cmds{end+1} = sprintf('rmdir %s /s /q', pname);
    end
elseif ismac() || isunix()
    cmds{end+1} = sprintf('rm -rf %s', pname);
end
