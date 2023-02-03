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
    MenuBox('No MC application found...Exiting MC session.', 'OK');
    return;
end

q = 0;
while q ~= 1
    if strcmp(mode,'interactive')
        q = MenuBox('Run MC application to generate output and click Done button when done.', ...
                {'Ran MC app manually. Now done', ...
                 'MC app exists. Try running it.', ...
                 'Cancel'});
    else
        q = 2;
    end
         
    fwmodel = existMCOutput(fwmodel, probe, dirnameSubj);     
    if q == 1 && all(fwmodel.errMCoutput(:) == 3) && ~isempty(probe.ml)
        enableDisableMCoutputGraphics(fwmodel, 'on');
        postCompletionMsg(fwmodel, probe);
        break;
        
    elseif q == 1 
        if isempty(fwmodel.fluenceProf)
            q = MenuBox('Could not find MC output files.', 'OK'); 
        else            
            q = MenuBox('Could not find MC output files but precalculated fluence profiles are available. Do you want to use them?', {'Yes','No'});
            if q == 1
                set(fwmodel.handles.menuItemLoadPrecalculatedProfile,'enable','on');
                MenuBox('Select menu option "Load Precalculated Profile" in the "Forward Model" menu to calculate sensitivity', 'OK');
            end
        end
        
    elseif q == 2
        % To avoid issues with spaces in path names we cd to the same folder where the batch file 
        % is and run with relative pathname. Example of problem with spaces in pathname: running 
        % batch script in Winodws with start doesn't work properly when you put "" around the 
        % argument. But you need quotes if there are spaces in the pathname. Annoying bug. You can 
        % run with quotes without start but then you won't get a separate window.
        currdir = pwd;
        cd(dirnameSubj);
        delete('./fw/.fw_all*');
        if ~isempty(findstr(computer(),'PCWIN'))
            status = executeBatchFile(fwmodel, '.\fw\fw_all.bat');
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
        if status == 0
            
            count = 0;
            while ~all(fwmodel.errMCoutput(:)==3)
                if mod(count,5)==0
                    fprintf('%d output files completed\n', length(find(fwmodel.errMCoutput(:)==3)));
                end
                fwmodel = existMCOutput(fwmodel, probe, dirnameSubj);
                if ~isMCRunning(fwmodel, dirnameSubj)
                    MenuBox('Doesn''t look like MC application is executing. Please run it manually', 'OK');
                    enableDisableMCoutputGraphics(fwmodel, 'off');
                    break;
                end
                count = count+1;
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

            MenuBox('Sorry. Couldn''t execute MC application. Please run it manually', 'OK');
            if ~all(fwmodel.errMCoutput(:)==3)
                enableDisableMCoutputGraphics(fwmodel, 'off');
                q = 0;
            end

        end
        break;
    elseif q == 3
        enableDisableMCoutputGraphics(fwmodel, 'off');
        break;
    elseif ~all(fwmodel.errMCoutput(:)==3)
        q = 0;
    end
end



% -----------------------------------------------------------------
function postCompletionMsg(fwmodel, probe)
MenuBox('Successfully finished generating MC output!', 'OK');
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
MenuBox(msg, 'OK');



% ---------------------------------------------------------------
function status = executeBatchFile(fwmodel, filename)
global logger

logger = InitLogger(logger, fwmodel.mc_exename);
status = [];
[p,f] = fileparts(filename);
dotStart = sprintf('%s/.%s_start', p,f);
dotStop = sprintf('%s/.%s_stop', p,f);
fidStart = fopen(dotStart, 'wt');
fidStop = fopen(dotStop, 'wt');
fid = fopen(filename, 'rt');
try
    logger.CurrTime('*** Start Time:  ');
    logger.Write('\n');
    kk = 1;
    while 1
        line = fgetl(fid);
        if line == -1
            break;
        end
        if isempty(findstr(fwmodel.mc_exename, line))
            continue;
        end
        logger.Write('%d. %s\n', kk, line);
        [status(kk), output] = system(line);
        logger.Write(sprintf('%s\n', output));
        if status(kk)==0
            fseek(fidStart, 0,-1);
            fprintf(fidStart, '%d', kk);
        end
        kk = kk+1;
    end
    fclose(fid);
    fclose(fidStart);
    fclose(fidStop);
catch ME
    printStack(ME)
    fclose(fid);
    fclose(fidStart);
    fclose(fidStop);
end
logger.Write('\n');
logger.CurrTime('End Time:  ');
logger.Write('\n');

