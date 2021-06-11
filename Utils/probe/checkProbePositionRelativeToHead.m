function [hl, hp] = checkProbePositionRelativeToHead(headsurf, probe, hf)
%
% Syntax:
%   [hl, hp] = checkProbePositionRelativeToHead(headsurf, probe, hf)
%
% Description:
%   After AtlasViewer launches, use this function on the matlab command
%   line to check probe registration relative to head. Function displays 
%   the nearest points on the head to each optode, to show how AtlasViewer
%   decided if the probe is registered or pre-registered.
%
%   Pre-registered means that while the probe is not necessarily touching 
%   the head surface, it is oriented correctly and in position, ready to be
%   pulled a short distance to the head for full registration
%
% Example:
%   hf = AtlasViewerGUI;
%   global atlasViewer
%   [hl, hp] = checkProbePositionRelativeToHead(atlasViewer.headsurf, atlasViewer.probe, hf);
%   delete([hl, hp]);
%

p1 = headsurf.mesh.vertices;
p2 = probe.optpos;
[p3, ip3] = nearest_point(p1, p2);

hc = get(hf, 'children');
k = 0;
for jj = 1:length(hc)
    if strcmp(get(hc(jj),'type'), 'axes')
        k = jj;
        break
    end
end
if k==0
    return
end

axes(hc(k))
hold(hc(k), 'on');

if leftRightFlipped(probe)
    axesOrder = [2,1,3];
else
    axesOrder = [1,2,3];
end

for ii = 1:size(p3,1)
    hl(1,ii) = line(hc(k), [p2(ii, axesOrder(1)), p3(ii, axesOrder(1))], [p2(ii, axesOrder(2)), p3(ii, axesOrder(2))], [p2(ii, axesOrder(3)), p3(ii, axesOrder(3))], ...
        'color',[.00,.00,.00], 'linewidth',2); %#ok<*AGROW>
    hp(1,ii) = plot3(hc(k), p1(ip3(ii), axesOrder(1)), p1(ip3(ii), axesOrder(2)), p1(ip3(ii), axesOrder(3)), '.', 'markersize',20, 'color','g') ;
end


