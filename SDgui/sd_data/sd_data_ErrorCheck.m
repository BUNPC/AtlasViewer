function [err, msgs] = sd_data_ErrorCheck()

err = 0;
msgs = {};

% SrcPos
msg = grommetErrorCheck();
if ~isempty(msg)
    err = err+1;
    msgs{err} = msg;
end


% ----------------------------------------------------------
function msg = grommetErrorCheck()
global SD

msg = '';
if isfield(SD,'SrcGrommetType')
    if ~all(strcmpi(SD.SrcGrommetType, 'none')==0)
        msg = accumulateMsgs(msg, 'Not all source grommet types have been set');
    end
end
if isfield(SD,'DetGrommetType')
    if ~all(strcmpi(SD.DetGrommetType, 'none')==0)
        msg = accumulateMsgs(msg, 'Not all detector grommet types have been set');
    end
end
if isfield(SD,'DummyGrommetType')
    if ~all(strcmpi(SD.DummyGrommetType, 'none')==0)
        msg = accumulateMsgs(msg, 'Not all dummy grommet types have been set');
    end
end


% -------------------------------------------------------
function msg = accumulateMsgs(msg0, msg)

if isempty(msg0)
    msg = sprintf('  ERROR: %s\n', msg);
else
    msg = sprintf('%s  ERROR: %s\n', msg0, msg);
end

