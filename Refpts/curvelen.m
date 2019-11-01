function [len, gapmax] = curvelen(curve_seg, iStart, iEnd)

len=0;
gapmax=0;

if ~exist('iStart', 'var')
    iStart = 1;
end
if ~exist('iEnd', 'var')
    iEnd = size(curve_seg(iStart:end,:), 1);
end
N = iEnd-iStart+1;

for i=iStart:N-1
    d=dist3(curve_seg(i,:), curve_seg(i+1,:));
    len=len+d;
    if(d>gapmax)
        gapmax=d;
    end
end
