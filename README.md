
NOTE: This documentation is a work in progress. More detailed documentation will be added in the coming months/years.


Introduction:
=============


Installing and Running AtlasViewer:
===================================
First download the AtlasViewer package. Go online to https://github.com/BUNPC/AtlasViewer and click the green "Clone or download" button on right. Then click "Download ZIP" right below the green button. Once you have downloaded the zip file, unzip it. We highly recommend that you "Download ZIP". Only use "Clone" if you now what you are doing with git.


Installing and running AtlasViewer if you do NOT have Matlab:
------------------------------------------------------------

Windows:

1. Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Windows from the Mathworks website (https://www.mathworks.com/products/compiler/matlab-runtime.html)
1. In File Browser (or Windows Explorer in older Windows versions) navigate to the atlasviewer root folder you have just downloaded and unzipped. 
1. Go into the Install folder and find and unzip the file atlasviewer_install_win.zip. 
1. Go into the newly created atlasviewer_install folder and double click on the file setup.bat. This should start the installation process. When it finishes you should see a AtlasViewer icon on your Desktop
1. You can now execute the AtlasViewer by double clicking the AtlasViewer icon on your desktop.


Mac:

1. Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Mac from the Mathworks website (https://www.mathworks.com/products/compiler/matlab-runtime.html)
1. In Finder navigate to the atlasviewer root folder you have just downloaded and unzipped. 
1. Go into the Install folder and find and unzip the file atlasviewer_install_mac.zip. 
1. Go into the newly created atlasviewer_install folder and double click on the file setup.command. This should start the installation process. When it finishes you should see a AtlasViewer.command icon on your Desktop. 
1. You can now execute the AtlasViewer by double clicking the AtlasViewer.command icon on your desktop.

For either Mac or Windows AtlasViewer it will open by default in the sample subject folder that came with the installation. You will be asked to choose a processing options config file. Select the only one available, test_process.cfg. Once selected AtlasViewer should open the test.snirf data file. You are now ready to use AtlasViewer to work with this data. 


Installing and running AtlasViewer if you have Matlab:
------------------------------------------------------

1. Open Matlab and in the command window, change the current folder to the AtlasViewer root folder that you downloaded. In the command window, type

   >> setpaths

This will set all the required matlab search paths for AtlasViewer. Note: this step should be done every time a new Matlab session is started. 

At this point you should be ready to start AtlasViewer from the Matlab command window. 

To run:

a) Type AtlasViewer in the command window
b) Navigate to a subject folder and select to open it. 

