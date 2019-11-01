function h = waitbar_msg_print(msg, h, step, total)

if ~exist('h','var')
    h = [];
end
if ~exist('step','var')
    step = 0;
    total = 1;
end

if isempty(h)
    h = waitbar(step/total, msg);
else
    h = waitbar(step/total, h, msg);
end
fprintf('%s\n', msg);

