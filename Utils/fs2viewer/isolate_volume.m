function vol = isolate_volume(vol, threshold)

%
% USAGE:
%
%    vol = isolate_volume(vol, threshold)
%
% DESCRIPTION:
%
%    Function takes a MRI volume, labels all 
%    regions and zeros out all but the largest region 
%    (usually the head in an MR scan of the head). The
%    resulting image is a scan of the head with no noise 
%    or any other objects that appear in the original 
%    scan (such as fiducial markers).
%
% INPUTS:
%         
%    vol: MRI volume scan
%
%    threshold: Optional argument. By default the function assumes 
%               noise has been cleared from the volume. If not the 
%               user has the option of passing a threshold value 
%               below which a voxel value will be considered noisy 
%               and set to zero. 
%
% EXAMPLE 1:
%
%     i=find(vol<25);
%     vol(i)=0;
%     vol = isolate_volume(vol);
%
% EXAMPLE 2:
%
%     vol = isolate_volume(vol,25);
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%  

i = vol>0;
th = mean(vol(i));

if ~exist('threshold','var')
    threshold = th;
elseif (th / threshold)*100 > 150
    threshold = th;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add sanity checks: if volume has no noise then try to detect that
% and avoid doing noise reduction, rather than zeroing out the whole
% volume
i = find(vol<threshold);
j = find(vol==0);

% Check if the number of noisy voxels is zero
if isempty(i)
    return;
end

% Check if the number of unique voxels values is in the single digits. 
% If yes we can conclude that the volume is composed of a few regions
% with contant values, as would be the case in a segmented volume.
if length(unique(vol)) < 10
    return;
end

% Check if all the voxeks
if all(vol(i)==0)
    return;
end



% We try 10 times to adjust the threshold to optimal level then give up
for k=1:10

    fprintf('Threshold: %d\n', uint32(threshold));
    
    % There is some noise, reduce it
    i=find(vol<threshold);
    vol(i)=0;
    
    h = waitbar_msg_print(sprintf('Reducing noise using threshold of %d. Please wait...', uint32(threshold)));
    volmask  = vol2constvol(vol);
    volmask  = bwlabeln(volmask);
    vals = unique(volmask);
    n = size(vals, 1);
    int = round(n/100);
    s = [];
    t = tic;
    c = 1;
    for i=1:n
        
        if mod(i,int)==0
            el = toc(t);
            waitbar_msg_print(sprintf('Noise reduction %d%% completed in %0.3f seconds ...', uint8(100*(i/n)), el), h, i, n);
            if (el/c)>2
                msg = sprintf('Too slow. Restarting with adjusted threshold...\n');
                waitbar_msg_print(msg, h, i, n);
                threshold = threshold + 5;
                pause(4);
                break;
            end
            c=c+1;           
        end
        
        if(vals(i) == 0)
            continue;
        end
        
        j = find(volmask == vals(i));
        s(vals(i)) = length(j);
        
    end
    
    close(h);

    fprintf('\n');
    
    % If we did not complete the head isolation then increase the threshold
    % and try again
    if i==n
        break;
    end
        
end


val = find(s == max(s));
inoise = find(volmask ~= val);
volmask(inoise) = 0;
i = find(volmask == 0);
vol(i) = 0;

% Make sure head isn't touching the volume boundaries
% This causes all kinds of problems in image processing 
[nx,ny,nz]=size(vol);
vol(1:5,:,:)=0;
vol(nx-5:nx,:,:)=0;
vol(:,1:5,:)=0;
vol(:,ny-5:ny,:)=0;
vol(:,:,1:5)=0;
vol(:,:,nz-5:nz)=0;

