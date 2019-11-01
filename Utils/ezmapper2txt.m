%
% function ezmapper2txt
%  
% Usage:
% 
%     ezmapper2txt(ezs, filenm)
%
% Description:
%
%    ezs structure fields:
%
%         AffineAmat: 
%         AffineBvec: 
%            AtlasID: 
%             DetPos: 
%       ExperimentID: 
%     ExperimentName: 
%       LandmarkFrom: 
%         LandmarkTo: 
%             OpSate: 
%           Operator: 
%         PointCloud: 
%           SaveTime: 
%             SrcPos:    
% 
%  Landmark order in LandmarkFrom is Nz,LPA,RPA,Cz,Iz
%
%

function ezmapper2txt(ezs,filenm)

if ~isstruct(ezs)
    ezs = parseezs(ezs);
end
[SrcPos, DetPos, PointCloud, Landmarks] = remapoptodes(ezs);


if ~exist('filenm','var')
    filenm = 'digpts.txt';
else
    delete(filenm);
end

landmarkorder = {...
'nz'; ...
'rpa'; ... 
'lpa'; ...
'cz'; ...
'iz';  ...
};

fid = fopen(filenm,'w');
for ii=1:size(Landmarks,1)
    fprintf(fid,'%s: %0.1f %0.1f %0.1f\n',landmarkorder{ii},Landmarks(ii,:));
end
for ii=1:size(SrcPos,1)
    fprintf(fid,'s%d: %0.1f %0.1f %0.1f\n',ii,SrcPos(ii,:));
end
for ii=1:size(DetPos,1)
    fprintf(fid,'d%d: %0.1f %0.1f %0.1f\n',ii,DetPos(ii,:));
end
for ii=1:size(PointCloud,1)
    fprintf(fid,'@: %0.1f %0.1f %0.1f\n',PointCloud(ii,:));
end
fclose(fid);

% Save affine tranformation to colin atlas
k = strfind(filenm,'.');
filenmmat = [filenm(1:k-1) '2colin.txt'];
T_2colin = [ezs.AffineAmat ezs.AffineBvec'; 0 0 0 1];
save(['./' filenmmat],'-ascii','T_2colin');

