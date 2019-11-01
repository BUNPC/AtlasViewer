#!sh

rm -rf ~/Desktop/AtlasViewerGUI*
rm -rf ~/Desktop/Test

perl ~/Downloads/atlasviewer_install/makefinalapp.pl ~/atlasviewer/run_AtlasViewerGUI.sh ~/Desktop/AtlasViewerGUI.$1
ln -s ~/atlasviewer/Test ~/Desktop/Test

chmod 755 ~/Desktop/AtlasViewerGUI.$1
chmod 755 ~/Desktop/Test

exit
