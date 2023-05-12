function b = isMCRunning(fwmodel, dirname)
b = true;
pause(.5);

% Wait for shell script to create a .fw_all_start file which 
% is an indication the script is running.
tries = 0;
while tries < 10
    if exist([dirname, '/fw/.fw_all_start'], 'file')
        break;
    end
    tries = tries+1;
    pause(.2);
end

% If .fw_all_start file is missing then probably script is not running.
if ~exist([dirname, '/fw/.fw_all_start'], 'file')
    MenuBox('Looks like fw_all shell script has stopped running.', 'OK');
    b = false;
    return;
else
    nOutputIndicator = [];
    while isempty(nOutputIndicator)
        try
            nOutputIndicator = load([dirname, '/fw/.fw_all_start']);
            pause(.1);
        catch
            nOutputIndicator = [];
            pause(.5);
        end
    end
end

% Check if there are fewer output files then MC command executed
switch(fwmodel.mc_appname)
    case 'tMCimg'
        nOutput = length(dir([dirname, '/fw/*.2pt']));
    case 'mcx'
        nOutput = length(dir([dirname, '/fw/*.mc2']));
    otherwise
        b = false;
        return;
end
if nOutputIndicator > nOutput
    b = false;
    return;
end


% If the script is done but no output then clearly things failed
if exist([dirname, '/fw/.fw_all_stop'], 'file')
    % if fw_all shell script finished running, check that 
    % output files from the MC app exist. If not we know 
    % MC app isn't running correctly or didn't run at all. 
    switch(fwmodel.mc_appname)
        case 'tMCimg'
            if isempty(dir([dirname, '/fw/*.2pt']))
                b = false;
            end
        case 'mcx'
            if isempty(dir([dirname, '/fw/*.mc2']))
                b = false;                
            end
        otherwise
            b = false;
    end
end

