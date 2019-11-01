% function [pos, posInit] = positionprobe(probeData, permuteAxes, scale, poso, imgData,...
%                                         posAttract, nIter, posi)
% 
% Position a probe onto the surface defined in a bin file.  This is
% useful for positioning a probe onto a head, for example.
% 
% For the probe file,
% each row lists connectivity information for a given optode
% optode#, initial position xo, yo, zo, 
%          variation dx, dy, dz,
%          connectivity(optode#, distance)...
% The first optode must have a fixed position indicated by
% dx = dy = dz = 0, and thus must be positioned at the appropriate
% voxel on the air tissue interface.
% Subsequent optodes may have dx = dy = dz = 1.  Any dx, dy, dz
% could be set to 0 to not allow position adjustments along the
% indicated axis.  This is useful for defining the direction of a
% line of optodes relative to the first optode.
% The sequence of connected optodes must be presented in increasing order.
% Each row must have the same number of elements, so pad with zeros
% if necessary.
%
% scale
% This is a multiplier used to change the distance between
% connected optodes.  A value of 1 uses the same distance as
% defined in the probe file.  A value of 1.5 increases the distance
% by 50%.
%
% permuteAxes
% If the axes defined in the probe file are consistent with that in
% the imgData then use [1 2 3].  Otherwise, specify the mapping.
% For instance, if the probe x should go along the imgData y and
% vice versa, then use [2 1 3].  The 1, 2, and 3 refer to the x, y,
% and z axes defined in the probe file. 
%
% poso
% This defines the position offset of the probe in the imgData, in
% the imgData coordinates (i.e. after the axis permutation).
%
% For the bin file,
% the air must be tissue type 0.  This is the same bin file as used
% for our Monte Carlo code and Finite Difference code.
%
% posAttract
% When the optode is not in a air-tissue interface voxel, then it
% is moved along the line joining it with the attractor at position
% posAtrtact until it finds the air-tissue interface.
%
% nIter
% This defines the number of iterations to perform in the
% positioning algorithm.
%
% posi
% This can serve as the initial position of the probe with
% connectivity defined by the probe file.
%
% Author: David Boas (dboas@nmr.mgh.harvard.edu)
%
% Modified by Jay Dubb Nov. 2008
%
% Modified by Jay Dubb Apr. 2009
%     Added workaround for bug where a few optodes come out 
%     misregistered if the first entry in positionprobe.dat is 
%     not anchored.
%

function [pos, posInit] = positionprobe(probeData, ...
                                        permuteAxes, ...
                                        scale, ...
                                        poso, ...
                                        imgData, ...
                                        posAttract, ...
                                        nIter, ...
                                        posi)



% load the probe file
if ischar(probeData)
    pf = load( probeData );
else
    pf = probeData;
end
    
FIRST_ANCHOR=1;
if FIRST_ANCHOR
    % Temporary workaround for a bug where a few optodes come out misregistered if
    % the first entry in positionprobe.dat is not anchored. This code makes sure
    % that the first entry in the pf list is anchored by swapping places with the
    % first anchored entry.
    % Jay Dubb, 03/17/09
    [pf k] = map_posprobedata(pf);
end

% Initialize outputs
pos = pf(:,2:4);
posInit = pos;

nOptodes = size(pf,1);
dpos = pf(:,5:7);   
conO = pf(:,8:2:end-1);
conD = pf(:,9:2:end) * scale;
conKS = ones(size(conD));

% The bigger the conKS, the stiffer the spring
lst = find(conD<0);
conKS(lst) = 1e-4*abs(conD(lst));%*ones(1,size(conKS,2));
conD = abs(conD);

% Check for errors and conditions which might cause early exit
[status pos posInit] = errcheck(pos,dpos,conO,conD);
if status > 0
    return;
end

% permute axes
if exist( 'permuteAxes' )
    pos = pos(:,permuteAxes);
    dpos = dpos(:,permuteAxes);
%     conO = conO(:,permuteAxes);
%     conD = conD(:,permuteAxes);
end

% add offset position to all optodes
pos = pos + ones(size(pos,1),1)*poso;

% use initial position if provided
if exist('posi')
    if size(posi)==size(pos)
        pos = posi;
    else
        error('posi must have the same dimensions as that described in the probe file!' );
    end
end
    
% load the image volume file
if ischar(imgData)
    if ~isempty(findstr(imgData,'.bin'))
        im = load_bin(imgData);        
    elseif ~isempty(findstr(imgData,'.vox'))
        im = load_vox(imgData);
	else
        im = load_bin(imgData);        
    end
else
    im = imgData;
end
nVox = size(im);

%
% Pull the optodes down to the tissue
%
pos = optodes2bnd( pos, dpos, nOptodes, nVox, posAttract, im);


%
% Loop over number of iterations
%
for idxIter = 1:nIter

    %
    % Create the Jacobian
    %
    uflagVec = zeros(3,nOptodes);
    idxNrows = 0;
    ADE = 0;
    MDE = 0;
    for idxOpt = 2:nOptodes
        
        uflagVec(:,idxOpt) = dpos(idxOpt,:)';
        
        listOpt = find(conO(idxOpt,:)~=idxOpt & conO(idxOpt,:)~=0);
        
        Jtmp = zeros(length(listOpt),nOptodes*3);
        
        % distance between idxOpt and connected Opts
        rsepvec = ones(length(listOpt),1)*pos(idxOpt,:)-pos(conO(idxOpt,listOpt),:);
        rsep = sum(rsepvec.^2,2).^0.5;
        rd = rsep-conD(idxOpt,listOpt)';
        ADE = ADE + sum(abs(rd),1);
        MDE = max(MDE,max(abs(rd)));
        
        % spring constants
        ks = conKS(idxOpt,listOpt)';
        
        % Calculate the Jacobian from above pieces
        Jtmp(:,(idxOpt-1)*3+1) = ks.*(rsepvec(:,1).*rd(:))./rsep;
        Jtmp(:,(idxOpt-1)*3+2) = ks.*(rsepvec(:,2).*rd(:))./rsep;
        Jtmp(:,(idxOpt-1)*3+3) = ks.*(rsepvec(:,3).*rd(:))./rsep;
        
        for idx=1:length(listOpt)
            Jtmp(idx,(conO(idxOpt,listOpt(idx))-1)*3+1) = ...
                -ks(idx).*(rsepvec(idx,1)*rd(idx))/rsep(idx);
            Jtmp(idx,(conO(idxOpt,listOpt(idx))-1)*3+2) = ...
                -ks(idx).*(rsepvec(idx,2)*rd(idx))/rsep(idx);
            Jtmp(idx,(conO(idxOpt,listOpt(idx))-1)*3+3) = ...
                -ks(idx).*(rsepvec(idx,3)*rd(idx))/rsep(idx);
        end
        
        J(idxNrows+1:idxNrows+length(listOpt),:) = Jtmp;
        idxNrows = idxNrows + length(listOpt);
    end
    
    %
    % Calculate position update
    %
    delta_r = -sum(J,1);
    delta_r = delta_r .* uflagVec(:)';
    delta_r = 1 * delta_r / max(abs(delta_r));
    pos = pos + reshape(delta_r,[3 nOptodes])';
    
    %
    % Pull the optodes down to the tissue
    %
    pos = optodes2bnd( pos, dpos, nOptodes, nVox, posAttract, im);
    
    
    ADE = ADE / nOptodes;
    
    disp( sprintf( 'Iteration #%d: Avg/Max Displacement Error = %3.1f, %3.1f',...
        idxIter, ADE, MDE ));
    
end    % end iterations

if FIRST_ANCHOR
    % Temporary workaround for a bug where a few optodes come out misregistered if
    % the first entry in positionprobe.dat is not anchored. This code unmaps the mapping
    % made by map_posprobe.m to swap the first entry with the first anchored entry.
    % Jay Dubb, 03/17/09
    pos = unmap_probe(pos, k);
end



%
%
% Opodes2Bnd
%
%
function  pos = optodes2bnd( pos, dpos, nOptodes, nVox, posAttract, im)

for idxOpt = 1:nOptodes
    if (all(~dpos(idxOpt)) == true)
        continue;
    end
    
    ii = floor(pos(idxOpt,1));
    jj = floor(pos(idxOpt,2));
    kk = floor(pos(idxOpt,3));
    
    if ii<1 | ii>nVox(1) | jj<1 | jj>nVox(2) | kk<1 | kk>nVox(3)
        dposAttract = [posAttract(1)-pos(idxOpt,1)...
            posAttract(2)-pos(idxOpt,2)...
            posAttract(3)-pos(idxOpt,3)];
        dposAttract = dposAttract / sum(dposAttract.^2).^0.5;
        while   ii<1 | ii>nVox(1) | jj<1 | jj>nVox(2) | kk<1 | kk>nVox(3)
            pos(idxOpt,:) = pos(idxOpt,:) + dposAttract.*dpos(idxOpt,:);
            ii = floor(pos(idxOpt,1));
            jj = floor(pos(idxOpt,2));
            kk = floor(pos(idxOpt,3));
        end
    end
        
    if im(ii,jj,kk)==0
        dposAttract = [posAttract(1)-pos(idxOpt,1)...
            posAttract(2)-pos(idxOpt,2)...
            posAttract(3)-pos(idxOpt,3)];
        dposAttract = dposAttract / sum(dposAttract.^2).^0.5;
        while im(ii,jj,kk)==0
            pos(idxOpt,:) = pos(idxOpt,:) + dposAttract .* dpos(idxOpt,:);
            ii = floor(pos(idxOpt,1));
            jj = floor(pos(idxOpt,2));
            kk = floor(pos(idxOpt,3));
        end
    else
        dposAttract = -[posAttract(1)-pos(idxOpt,1)...
            posAttract(2)-pos(idxOpt,2)...
            posAttract(3)-pos(idxOpt,3)];
        dposAttract = dposAttract / sum(dposAttract.^2).^0.5;
        
        while im(ii,jj,kk)~=0
            pos(idxOpt,:) = pos(idxOpt,:) + dposAttract .* dpos(idxOpt,:);
            ii = floor(pos(idxOpt,1));
            jj = floor(pos(idxOpt,2));
            kk = floor(pos(idxOpt,3));
        end
        pos(idxOpt,:) = pos(idxOpt,:) - dposAttract .* dpos(idxOpt,:);
    end
end



%-----------------------------------------------------------------------
function [posprobe_map k] = map_posprobedata(posprobe)
    
i = find((posprobe(:, 5) == 0) & (posprobe(:, 6) == 0) & (posprobe(:, 7) == 0));
if(~isempty(i))
    k = i(1);
else
    k = 0;
end


posprobe_map = posprobe;
if(k > 1)
    
    % Find all the indices of k in the connectivity matrix
    i=1; ik=[];
    for jj=1:size(posprobe,1)
        for kk=8:2:size(posprobe,2)
            if(posprobe(jj,kk) == k)
                ik(i,:) = [jj kk];
                i=i+1;
            end
        end
    end
    
    % Find all the indices of 1 in the connectivity matrix
    i=1; i1=[];
    for jj=1:size(posprobe,1)
        for kk=8:2:size(posprobe,2)
            if(posprobe(jj,kk) == 1)
                i1(i,:) = [jj kk];
                i=i+1;
            end
        end
    end
    
    % Swap the 1's and the k's
    for i=1:size(i1, 1)
        posprobe(i1(i,1), i1(i,2)) = k;
    end
    for i=1:size(ik, 1)
        posprobe(ik(i,1), ik(i,2)) = 1;
    end
    
    
    posprobe_map = posprobe;
    
    % Lastly swap the 1st and kth rows
    posprobe_map(1,:) = [1 posprobe(k,2:end)];
    posprobe_map(k,:) = [k posprobe(1,2:end)];
end



%-----------------------------------------------------------------------
function probe = unmap_probe(probe_map, k)
    
probe = probe_map;
if(k ~= 1)
    probe(1,:) = probe_map(k,:);
    probe(k,:) = probe_map(1,:);
end




%-----------------------------------------------------------------------
function [status pos posInit] = errcheck(pos,dpos,conO,conD)

status = 0;
posInit = pos;

% If all positions are fixed to begin with then we're done
if all(~dpos(:,1)) && all(~dpos(:,2)) && all(~dpos(:,3))
    disp(sprintf('Warning: All optodes seem to be already registered.\nNo registration performed'));
    status = 1;    
end

if duplicate_anchors(pos,dpos,conO,conD)
    pos = [];
    posInit = [];
    disp(sprintf('Error: Two optodes which are neighbors are anchored to same optode.\nNo registration performed'));
    status = 2;
end
