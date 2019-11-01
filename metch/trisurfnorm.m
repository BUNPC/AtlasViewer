function ev=trisurfnorm(node,elem)
%  ev=trisurfnorm(node,elem)
%  calculate the surface norms for each element
%  (surface can be either triangular or cubic)
%
%  author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%  date: 12/12/2008
%
% parameters: 
%      node: node coordinate of the surface mesh (nn x 3)
%      elem: element list of the surface mesh (3 columns for 
%            triangular mesh, 4 columns for cubic surface mesh)
% outputs:
%      ev: norm vector for each surface element
%
% Please find more information at http://iso2mesh.sf.net/cgi-bin/index.cgi?metch
%
% this function is part of "metch" toobox, see COPYING for license

v12=node(elem(:,1),:)-node(elem(:,2),:);
v13=node(elem(:,1),:)-node(elem(:,3),:);

ev=cross(v12,v13);
evnorm=repmat(sqrt(sum(ev.*ev,2)),1,3);
ev=ev./evnorm;
