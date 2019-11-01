function [fwmodel, err] = genMCoutput(fwmodel, probe, dirnameSubj, mode)

err = true;

if ~isempty(dir([dirnameSubj 'fw/fw.*.2pt']))
    delete([dirnameSubj 'fw/fw.*.2pt']);
end
if ~isempty(dir([dirnameSubj 'fw/fw.*.his']))
    delete([dirnameSubj 'fw/fw.*.his']);
end
if ~isempty(dir([dirnameSubj 'fw/Adot.mat']))
    delete([dirnameSubj 'fw/Adot.mat']);
end
if ~isempty(dir([dirnameSubj 'fw/AdotVol.3pt']))
    delete([dirnameSubj 'fw/AdotVol.3pt']);
end
if ~isempty(dir([dirnameSubj 'fw/AdotVolAvg.3pt']))
    delete([dirnameSubj 'fw/AdotVolAvg.3pt']);
end
if ~isempty(dir([dirnameSubj 'fw/.fw_all_start']))
    delete([dirnameSubj 'fw/.fw_all_start']);
end
if ~isempty(dir([dirnameSubj 'fw/.fw_all_stop']))
    delete([dirnameSubj 'fw/.fw_all_stop']);
end

if ~exist('mode','var')
    mode='interactive';
end

if isempty(fwmodel.mc_exename)
    menu('No MC application found...Exiting MC session. ','OK');
    return;
end

q=0;
status = 0;
while q~=1
    if strcmp(mode,'interactive')
    q = menu('Run MC application to generate output and click Done button when done.',...
             'Ran MC app manually. Now done', ...
             'MC app exists. Try running it.', ...
             'Cancel');
    else
        q = 2;
    end
         
    fwmodel = existMCOutput(fwmodel, probe, dirnameSubj);     
    if q==1 && all(fwmodel.errMCoutput(:)==3) && ~isempty(probe.ml)
        enableDisableMCoutputGraphics(fwmodel, 'on');
        postCompletionMsg(fwmodel, probe);
        break;
        
    elseif q==1 
        if isempty(fwmodel.fluenceProf)
            menu('Could not find MC output files.','OK');
        else            
            q = menu('Could not find MC output files but precalculated fluence profiles are available. Do you want to use them?', 'Yes','No');
            if q==1
                set(fwmodel.handles.menuItemLoadPrecalculatedProfile,'enable','on');
                menu('Select menu option "Load Precalculated Profile" in the "Forward Model" menu to calculate sensitivity', 'OK');
            end
        end
        
    elseif q==2
        % To avoid issues with spaces in path names we cd to the same folder where the batch file 
        % is and run with relative pathname. Example of problem with spaces in pathname: running 
        % batch script in Winodws with start doesn't work properly when you put "" around the 
        % argument. But you need quotes if there are spaces in the pathname. Annoying bug. You can 
        % run with quotes without start but then you won't get a separate window.
        currdir = pwd;
        cd(dirnameSubj);
        delete(['./fw/.fw_all*']);
        if ~isempty(findstr(computer(),'PCWIN'))
            status = system('start .\fw\fw_all.bat');
        elseif ~isempty(findstr(computer(),'MAC'))
            system('chmod 755 ./fw/fw_all.csh');
            status = system('./fw/fw_all.csh&');
        elseif ~isempty(findstr(computer(),'GLNX'))
            system('chmod 755 ./fw/fw_all.csh');
            status = system('./fw/fw_all.csh&');
        else
            status = 1;
        end
        cd(currdir);
        
        % If status is ok then MC application is running. 
        % Monitor it.
        if status==0
            
            count = 0;
            while ~all(fwmodel.errMCoutput(:)==3)
                if mod(count,5)==0
                    disp(sprintf('%d output files completed', length(find(fwmodel.errMCoutput(:)==3))));
                end
                fwmodel = existMCOutput(fwmodel, probe, dirnameSubj);
                if ~isMCRunning(fwmodel, dirnameSubj)
                    menu('Doesn''t look like MC application is executing. Please run it manually','OK');
                    enableDisableMCoutputGraphics(fwmodel, 'off');
                    break;
                end
                count=count+1;
            end
                
            if all(fwmodel.errMCoutput(:)==3)
                err = false;
                enableDisableMCoutputGraphics(fwmodel, 'on');
                if strcmp(mode,'interactive')
                    postCompletionMsg(fwmodel, probe);
                    fwmodel.Adot = [];
                    fwmodel.Adot_scalp = [];
                end
            end

        else            

            menu('Sorry. Couldn''t execute MC application. Please run it manually','OK');
            if ~all(fwmodel.errMCoutput(:)==3)
                enableDisableMCoutputGraphics(fwmodel, 'off');
                q=0;
            end

        end
        break;
    elseif q==3
        enableDisableMCoutputGraphics(fwmodel, 'off');
        break;
    elseif ~all(fwmodel.errMCoutput(:)==3)
        q=0;
    end
end



% -----------------------------------------------------------------
function done = notifyWhenDone(dirnameSubj, mc_appname)

done = 0;
if ~strcmpi(mc_appname, 'tMCimg')
    return;
end
filesinp = dir([dirnameSubj './fw/*.inp']);
nFilesinp = length(filesinp);

h = waitbar(0,'Please wait...');
nFilesout = 0;
for ii=1:nFileinp
    waitbar(nFilesout/nFilesinp, h, sprintf('Completed %d of %d monte carlo output files.', nFilesout, nFilesinp));
    filesout = dir([dirnameSubj './fw/*.2pt']);
    nFilesout = length(filesout);
    if (nFilesinp==nFilesout) && existingFilesoutCompleted(filesout)
        done=1;
    end
    pause(2);
end
close(h);




% ------------------------------------------------------------------
function b = existingFilesoutCompleted(filesout)

b=1;
if isempty(fileout)
    return;
end
nbytes = filesout(1).bytes;
for ii=2:length(fileout)
   if filesout(1).bytes~=nbytes
       b=0;
       break;
   end
end



% -----------------------------------------------------------------
function postCompletionMsg(fwmodel, probe)

menu('Successfully finished generating MC output!', 'OK');
if isempty(probe.ml)
    msg{1} = sprintf('WARNING: May not be able to generate sensitivity profile because measurement list\n');
    msg{2} = sprintf('is missing. This might be because the probe in the .SD or .nirs file for this subject does not\n');
    msg{3} = sprintf('match the digitized probe in your digpts.txt file.\n');
    enableDisableMCoutputGraphics(fwmodel, 'off');
else
    msg{1} = sprintf('Finished generating MC output. Now use the menu item ''Generate/Load Sensitivity Profile''\n');
    msg{2} = sprintf('under the Forward Model menu to generate the sensitivity profile');
    enableDisableMCoutputGraphics(fwmodel, 'on');
end
menu([msg{:}], 'OK');

