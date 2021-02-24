function dt = GetLastCheckForUpdates()
if ~ispathvalid([getAppDir_av, 'LastCheckForUpdates.dat'])
    dt = datetime - duration(200,0,0);
else
    fd = fopen([getAppDir_av, 'LastCheckForUpdates.dat'],'rt');
    dt = fgetl(fd);
    fclose(fd);
end

