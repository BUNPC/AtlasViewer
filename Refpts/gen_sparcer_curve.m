function [curve_seg_new, len, max_gap] = gen_sparcer_curve(curve_seg, distmin, surf)

ii=1;
curve_seg_new(1,:) = curve_seg(1,:);
N = size(curve_seg,1);
while ii<N
    
    % Find next point that is sufficiently far away 
    % and discard the points in between. 
    jj=1;
    ptc = curve_seg(ii,:);     % current point
    ptn = curve_seg(ii+jj,:);   % next point
    jj=jj+1;
    while dist3(ptc,ptn)<distmin && ii+jj<size(curve_seg,1)
        ptn = curve_seg(ii+jj,:);   % next point
        jj=jj+1;
    end

    % Add points along the straight line segment connecting current 
    % and next points to eliminate gaps.
    d = dist3(ptc,ptn);
    kk=1;
    graddist = distmin/2;
    while graddist*kk < d
        curve_seg_new(end+1,:) = points_on_line(ptc, ptn, graddist*kk/d);
        kk=kk+distmin;
    end
    
    % Add next point to new curve since it's sufficiently far away.
    curve_seg_new(end+1,:) = ptn;
        
    ii=ii+jj-1;
    
end

if exist('surf','var')
    curve_seg_new = pullPtsToSurf(curve_seg_new, surf, 'center', 0, false);
end

[len max_gap] = curvelen(curve_seg_new);

