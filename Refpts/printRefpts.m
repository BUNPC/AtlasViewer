function [pos, labels] = printRefpts(refpts, curves, mode)

% Function:
%
%    [pos, labels] = printRefpts(refpts, curves, mode)
%
% Descirption:
%    
%    Mostly a debugging tool for clearly and cleanly printing eeg_system
%    positions in refpts object. Since each position is a cell it is hard 
%    to display all the positions for easy viewing. This tool allows the 
%    position to be printed on the command line in matrix-like output 
%    as if eeg_system.curves were a single matrix. 
%   
% Examples:
% 
%    Print position and labels of all curves:
%       printRefpts(refpts)
%
%    Return position and labels of all curves using quiet mode :
%       [pos, labels] = printRefpts(refpts, [], 'quiet')
%
%    Print position and labels of basic landmark curves Nz, Iz, LPA, RPA, Cz:
%       pos = printRefpts(refpts, {'Nz','Iz','LPA','RPA','Cz'})
%
%    Return position and labels of curve NzCziIz using quiet mode :
%       [pos, labels] = printRefpts(refpts, {'NzCziIz'}, 'quiet')
%
%    Print position and labels of all points in curves PPO7PPOz, PPO8PPOz, PO7POz:
%       pos = printRefpts(refpts, {'PPO7PPOz','PPO8PPOz','PO7POz'})
%

pos = [];
labels = {};

if ~exist('curves','var') | isempty(curves)
    curves = fieldnames(refpts.eeg_system.curves);
elseif ~iscell(curves)
    curves = {curves};
end

if ~exist('mode','var')
    mode = 'normal';
end

% Find max number
maxlog=1;
for ii=1:length(curves)
    
    % check to see if curves{ii} exists as a field in refpts.eeg_system
    if ~eval( sprintf('isfield(refpts.eeg_system.curves, ''%s'');', curves{ii}) );  
        continue;
    end
    
    eval(sprintf('curve = refpts.eeg_system.curves.%s;', curves{ii}));
    for jj=1:length(curve.pos)
        
        if length(curve.pos{jj})==0
            continue;
        end
        if max(ceil(log10(curve.pos{jj})) > maxlog)
            maxlog = max(ceil(log10(curve.pos{jj})));
        end
    end
end

fprintf('\n');

% Print positions using maxlog to line them up for easy viewing 
kk=1;
for ii=1:length(curves)
    % check to see if curves{ii} exists as a field in refpts.eeg_system
    if ~eval( sprintf('isfield(refpts.eeg_system.curves, ''%s'');', curves{ii}) );  
        continue;
    end
    
    eval(sprintf('curve = refpts.eeg_system.curves.%s;', curves{ii}));
    for jj=1:length(curve.pos)
        
        if length(curve.pos{jj})==0
            continue;
        end
        
        pos(kk,:) = curve.pos{jj};
        labels{kk} = curve.labels{jj};

        if strcmp(mode,'normal')
            nspaces(1) = 5-length(labels{kk});
            nspaces(2:4) = maxlog-floor(log10(curve.pos{jj}));
            fprintf('%s%s: %s%0.4f %s%0.4f %s%0.4f\n', labels{kk}, char(zeros(1,nspaces(1)) + double(' ')), ...
                                                       char(zeros(1,nspaces(2)) + double(' ')), pos(kk,1), ...
                                                       char(zeros(1,nspaces(3)) + double(' ')), pos(kk,2), ...
                                                       char(zeros(1,nspaces(4)) + double(' ')), pos(kk,3));
        end
        
        kk=kk+1;
    end
end

fprintf('\n');
