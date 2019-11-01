function [pos, curve_len] = calcRefptsAlongCurve(curve_pts, curve_len, labels, stepsize, curvename, direction)

pos = {};

if ~exist('direction', 'var') | (direction~='f' & direction~='b')
    direction = 'f';
end

k=find(curvename=='-');
startlabel = curvename(1:k(1)-1);
endlabel = curvename(k(end)+1:end);

if curve_len==0
    curve_len = curvelen(curve_pts);
end

fprintf('%s curve length: %1.1f\n', curvename, curve_len);
for ii=1:length(labels)
    if strcmpi(labels{ii}, endlabel)
        break;
    end
    [pos{ii,1}, len] = curve_walk(curve_pts, (ii*stepsize)*curve_len/100);
    fprintf('%s = (%1.1f, %1.1f, %1.1f) is %1.2f away from %s\n', ...
            labels{ii}, pos{ii}(1), pos{ii}(2), pos{ii}(3), len, startlabel);
end



