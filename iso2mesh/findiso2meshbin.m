function dirname = findiso2meshbin()


% Search matlab paths for bin dir
dirname = ffpath('iso2mesh/bin');

if isempty(dirname)
    dirnameApp = getAppDir();
    if exist(dirnameApp,'dir')
        dirname = dirnameApp;
    end
else
    dirname = [dirname, '/iso2mesh/bin/'];
end
