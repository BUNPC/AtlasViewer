function [src,det,pc]=plotezsession(filename,atlaspath)
% [src,det,pc]=plotezsession(filename,atlaspath)
%
% example:
%    plotezsession('Test3_1.ezs','/path/to/ezmapper/atlas/colin');
%

[no,fc]=readoff([atlaspath filesep 'head.off']);

ezs=parseezs(filename);
[src,det,pc]=remapoptodes(ezs);
src=src(:,[1 3 2]);
det=det(:,[1 3 2]);

figure;
hold on;
hc=plotmesh(no,fc,'linestyle','none','facealpha',0.2);
plotmesh(src,'r.')
plotmesh(det,'.')
if(~isempty(pc))
    pc=pc(:,[1 3 2]);
    plotmesh(pc,'g.');
    legend('head','src','det','head contour');
else
    legend('head','src','det');
end
