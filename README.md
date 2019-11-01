
NOTE: This documentation is a work in progress. More detailed documentation will be added in the coming months/years.


Introduction:
=============


Installing and Running AtlasViewer:
===================================
First download the AtlasViewer package. Go online to https://github.com/BUNPC/AtlasViewer and click the green "Clone or download" button on right. Then click "Download ZIP" right below the green button. Once you have downloaded the zip file, unzip it.


Installing and running AtlasViewer if you do NOT have Matlab:
------------------------------------------------------------

Windows:

a) Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Windows from the Mathworks website (https://www.mathworks.com/products/compiler/matlab-runtime.html)
b) In File Browser (or Windows Explorer in older Windows versions) navigate to the atlasviewer root folder you have just downloaded and unzipped. 
c) Go into the Install folder and find and unzip the file atlasviewer_install_win.zip. 
d) Go into the newly created atlasviewer_install folder and double click on the file setup.bat. This should start the installation process. When it finishes you should see a AtlasViewer icon on your Desktop


Mac:

a) Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Mac from the Mathworks website (https://www.mathworks.com/products/compiler/matlab-runtime.html)
Important!!! Please NOTE: If using a MAC and downloading atlasviewer_install_<version>_mac_<date>.zip please rename any previous version of atlasviewer_install folder (for example atlasviewer_install_old) that exists in the folder where you are downloading the new zip file.  

b) In Finder navigate to the atlasviewer root folder you have just downloaded and unzipped. 
c) Go into the Install folder and find and unzip the file atlasviewer_install_mac.zip. 
d) Go into the newly created atlasviewer_install folder and double click on the file setup.command. This should start the installation process. When it finishes you should see a AtlasViewer.command icon on your Desktop. 

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

