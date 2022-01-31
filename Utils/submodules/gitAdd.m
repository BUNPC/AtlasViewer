function r = gitAdd(repo, pname)
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

cmds{ii} = sprintf('git add %s', pname); ii = ii+1;

[~, msgs] = exeShellCmds(cmds);

for ii = 1:length(cmds)
    fprintf('  %s\n', cmds{ii});
    fprintf('  %s\n', msgs{ii});
end

cd(currdir);

