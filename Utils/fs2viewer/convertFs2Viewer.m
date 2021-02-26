function [fs2viewer, status] = convertFs2Viewer(fs2viewer, dirnameSubj)
global importMriAnatomyUI

status = zeros(1,5);

% Generate the following objects:
%
%   headvol
%   headsurf
%   pialvol
%   pialsurf
%

% Show user the actual files found for each layer of the anatomy. The Gui
% also allows user to choose the file corresponding to each layer.
waitForGui(ImportMriAnatomy(fs2viewer, 'userargs'));

% If user hit cancel then we assume they changed their mind about wanting
% to import the subject anatomy
if importMriAnatomyUI.cancel
    status = 1;
    return;
end

fs2viewer = importMriAnatomyUI.fs2viewer;

try
    % Generate single segmented volume: this is what will be
    % used for generating the forward model
    [headvol, fs2viewer, status(1)]  = fs2headvol(fs2viewer);
    [pialsurf, fs2viewer, status(2)] = fs2pialsurf(fs2viewer);
    
    % Generate surfaces: this is what is displayed in the GUI
    if ~headvol.isempty(headvol)
        [headsurf, status(3)] = headvol2headsurf(headvol);
    end
    if pialsurf.isempty(pialsurf)
        [pialsurf, status(2)] = headvol2pialsurf(headvol);
    end
    
    if sum(status)>0
        
        % Change 5/29/2018: allow only head or only brain to be imported if that's all
        % that's available.
        
        if status(1)>0
            q = menu(sprintf('Error generating segmented head volume.'),'Proceed Anyway','Cancel');
            if q==2
                return;
            end
        elseif status(3)>0
            q = menu(sprintf('Error generating head surface.'),'Proceed Anyway','Cancel');
            if q==2
                return;
            end
        elseif status(2)>0 | status(4)>0
            q = menu(sprintf('Error generating brain surface. Do you want to proceed with only the head surface?'),'Proceed Anyway','Cancel');
            if q==2
                return;
            end
        end
        
        % reset status to no error since user decided to proceed anyway
        status = zeros(1,5);
    end
    
    % Since the objects don't exist as files yet, need to set the subject paths
    % in each object
    if ~headvol.isempty(headvol)
        headvol.pathname = dirnameSubj;
    end
    if ~headsurf.isempty(headsurf)
        headsurf.pathname = dirnameSubj;
    end
    if ~pialsurf.isempty(pialsurf)
        pialsurf.pathname = dirnameSubj;
    end
    
    
    % Create the AtlasViewer anatomical files corresponding to the imported mri
    % files
    saveHeadvol(headvol);
    saveHeadsurf(headsurf);
    savePialsurf(pialsurf);

catch ME
    
    if exist([dirnameSubj, 'anatomical'],'dir')==7
        fprintf('delete([dirnameSubj, ''anatomical/*'']);\n');
        delete([dirnameSubj, 'anatomical/*']);
        fprintf('delete([dirnameSubj, ''hseg*'']);\n');
        delete([dirnameSubj, 'hseg*']);
        delete([dirnameSubj, 'head.nii.gz']);
    end
    msg{1} = sprintf('There was an error importing MRI files. Please make sure the files are valid volume files ');
    msg{2} = sprintf('and are coregistered.\n After checking file, restart AtlasViewer to re-try importing.');
    MessageBox([msg{:}]);
    rethrow(ME);
    
end
    
