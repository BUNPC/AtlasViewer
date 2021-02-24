function SetLastCheckForUpdates(dt)
if ~exist('dt','var') && ispathvalid([getAppDir_av, 'LastCheckForUpdates.dat'])
    return;
end
if ~exist('dt','var')
    dt = datetime;
end
fd = fopen([getAppDir_av, 'LastCheckForUpdates.dat'],'wt');
fprintf(fd, '%s\n', dt);
fclose(fd);

