function [mapMesh2Vox, fwmodel] = projVoltoMesh_brain(fwmodel, dirnameOut)

% Project cortical indexed voxels onto pial meshes.
%
% Written by Matteo Caffini
% Modified by Jay Dubb 
%
% usage:
% call function projVoltoMesh in subject directory or registered atlas
% directory.

%  load the segmented Vol

hf = [];

if isempty(fwmodel.projVoltoMesh_brain)
    
    %%%%%%%%%%%%%%%%%%%%
    % load head volume
    %%%%%%%%%%%%%%%%%%%%
    nx = size(fwmodel.headvol.img,1);
    ny = size(fwmodel.headvol.img,2);
    nz = size(fwmodel.headvol.img,3);
    
    [nodeX, nNode, fwmode.mesh] = showReducedMesh(fwmodel.mesh_orig, fwmodel.mesh);
    
    if ishandles(hf)
        delete(hf);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % map Vol to LR Mesh
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Check if there's a segmentation file telling us 
    % what the tissue number of gray matter is in the 
    % seg file. 
    for gm_seg_num=1:length(fwmodel.headvol.tiss_prop)
        if(strcmp(lower(fwmodel.headvol.tiss_prop(gm_seg_num).name), 'gm') | ...
           strcmp(lower(fwmodel.headvol.tiss_prop(gm_seg_num).name), 'gray matter'))
            break;
        end
    end
    i_headvol = uint32(find(fwmodel.headvol.img==gm_seg_num));
    nmiss=0;
    nxy = nx*ny;
    nC = length(i_headvol);
    Amap = single(zeros(nC,1));
    mapMesh2Vox = single(ones(nNode,1000));
    NVoxPerNode = zeros(nNode,1);
    
    % We don't want to slow things down with too frequent updates
    update_interval=ceil(nC/100);  
    hwait = waitbar(0,'Looping over cortical voxels');
    h = 15; % with 15 we miss < 1% of total number of cortex voxels
    for ii=1:nC
        if mod(ii,update_interval)==1
            waitbar(ii/nC,hwait,sprintf('%d of %d',ii,nC));
        end
        [x,y,z] = ind2sub(size(fwmodel.headvol.img),i_headvol(ii));
        x = double(x);
        y = double(y);
        z = double(z);
        
        i_nX = find(nodeX(:,1)>x-h & nodeX(:,1)<x+h & nodeX(:,2)>y-h & nodeX(:,2)<y+h & ...
                    nodeX(:,3)>z-h & nodeX(:,3)<z+h);
        if ~isempty(i_nX)
            % rsep: get the distances from [x y z] to all the points in nodeX(i_nX,:).
            rsep = sum( (nodeX(i_nX,:) - ones(length(i_nX),1)*[x y z]).^2, 2 ).^0.5;
            [foo,imin] = min(rsep);
            Amap(ii) = i_nX(imin);
            NVoxPerNode(Amap(ii)) = NVoxPerNode(Amap(ii))+1; % might be useful?
            mapMesh2Vox(Amap(ii),NVoxPerNode(Amap(ii))) = i_headvol(ii);
        else
            nmiss = nmiss+1; % temporary var, delete when everything works
        end
    end;
    close(hwait);
    ciao = find(mapMesh2Vox(:)==0);
    mapMesh2Vox(ciao) = 1;

    save([dirnameOut, 'projVoltoMesh_brain.mat'], 'mapMesh2Vox');
    fwmodel.projVoltoMesh_brain = [dirnameOut, 'projVoltoMesh_brain.mat'];
    
else
    
    load(fwmodel.projVoltoMesh_brain);
   
end



