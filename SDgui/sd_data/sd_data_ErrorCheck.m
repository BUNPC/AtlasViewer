function [msgErrors, msgWarnings] = sd_data_ErrorCheck(handles)

msgErrors = {};
msgWarnings = {};

% Lambda
if isempty(sd_data_Get('Lambda'))
    msgErrors = accumulateErrors(msgErrors, 'Wavelengths not set.');
end

% Check grommet
msg = grommetWarningCheck(handles);
if ~isempty(msg)
    msgWarnings = msg;
end




% ----------------------------------------------------------
function msg = grommetWarningCheck(handles)
global SD

msg = '';

if ~get(handles.checkboxNinjaCap, 'value')
    return
end

if isfield(SD,'SrcGrommetType')
    if ~all(strcmpi(SD.SrcGrommetType, 'none')==0)
        msg = accumulateWanings(msg, 'Not all source grommet types have been set.');
    end
end
if isfield(SD,'DetGrommetType')
    if ~all(strcmpi(SD.DetGrommetType, 'none')==0)
        msg = accumulateWanings(msg, 'Not all detector grommet types have been set.');
    end
end



% -------------------------------------------------------
function msg = accumulateErrors(msg0, msg)

if isempty(msg0)
    msg = sprintf('  ERROR: %s\n', msg);
else
    msg = sprintf('%s  ERROR: %s\n', msg0, msg);
end


% -------------------------------------------------------
function msg = accumulateWanings(msg0, msg)

if isempty(msg0)
    msg = sprintf('WARNING: %s\n', msg);
else
    msg = sprintf('%sWARNING: %s\n', msg0, msg);
end


