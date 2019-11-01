function [src,det,pc,landmarks]=remapoptodes(ezs)
% remapoptodes maps the src/det tracker coordinates to the atlas 
% coordinates
%
% Qianqian Fang (fangq at nmr.mgh.harvard.edu)
%
% example:
%   ezs=parseEZS('20100901_003.ezs');
%   [src,det]=remapoptodes(ezs);
%

src=[];
det=[];
pc=[];
landmarks=[];
if ~isempty(ezs.SrcPos)
    src=(ezs.AffineAmat*ezs.SrcPos' + repmat(ezs.AffineBvec',[1,size(ezs.SrcPos,1)]))';
end
if ~isempty(ezs.DetPos)
    det=(ezs.AffineAmat*ezs.DetPos' + repmat(ezs.AffineBvec',[1,size(ezs.DetPos,1)]))';
end
if ~isempty(ezs.LandmarkFrom)
    landmarks=(ezs.AffineAmat*ezs.LandmarkFrom' + repmat(ezs.AffineBvec',[1,size(ezs.LandmarkFrom,1)]))';
end
if(~isempty(ezs.PointCloud))
    pc=(ezs.AffineAmat*ezs.PointCloud(:,2:4)' + repmat(ezs.AffineBvec',[1,size(ezs.PointCloud,1)]))';
end
