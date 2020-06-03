function Buildme_av_setup(dirname)

dirnameInstall = pwd;
cd(dirname);

av_Buildme('setup');

cd(dirnameInstall);

