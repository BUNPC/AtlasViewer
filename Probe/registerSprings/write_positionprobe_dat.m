%
% USAGE:
%
%    write_positionprobe_dat(data, filename)     
%
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%  

function write_positionprobe_dat(data, filename)

    global atlasViewer;
if ~isempty(atlasViewer) & isfield(atlasViewer, 'dirnameSubj')
    dirname = atlasViewer.dirnameSubj;
else
    dirname = '';
end

    % Write new positionprobe data file
    if(~exist('filename'))
        fid = fopen([dirname './positionprobe.dat'], 'w');
    else
        fid = fopen(filename, 'w');
    end
    for i=1:size(data, 1)
        
        fprintf(fid, '%d\t%0.1f\t%0.1f\t%0.1f\t%d\t%d\t%d\t%d\t%1.2f\t%d\t%1.2f\t%d\t%1.2f\n', ...
                data(i, 1), ...
                data(i, 2), data(i, 3), data(i, 4), ...
                data(i, 5), data(i, 6), data(i, 7), ...
                data(i, 8), data(i, 9), ...
                data(i,10), data(i,11), ...
                data(i,12), data(i,13));
            
    end
    fclose(fid);
