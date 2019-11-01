function [fs2viewer, status] = create_hseg(fs2viewer)

% USAGE:
%
% [hsegnii, tiss_type, status] = create_hseg(fs2viewer)
%
% DESCRIPTION: 
%
% 
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012

status = 0;
hseg = initLayer();
tiss_type = {};

dirnameVol = fs2viewer.mripaths.volumes;

% If hseg already exists our job is done.
if ~isempty(fs2viewer.hseg.filename)   
    % No need for segmentation. 
    fs2viewer.hseg = loadMri(fs2viewer.hseg);
    [p,f,e] = fileparts(fs2viewer.hseg.filename);
    if ~strcmp('hseg',f)
        fs2viewer.hseg.filename = [p,'/hseg',e];
    end
else
    fs2viewer = segment_head(fs2viewer);
end

% Create the segmentation volume
saveFs2Viewer(fs2viewer);
