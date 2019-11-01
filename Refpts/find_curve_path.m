function [curve_seg len max_gap] = find_curve_path(p1,p2,p3,curve)

% USAGE:
%
%    [curve_seg, len, max_gap] = find_curve_path(p1,p2,p3,curve)
%
% DESCRIPTION:
%
%    Finds all points from a set of points in curve, which lie on 
%    the curve segment (a segment of surve) p1, p2, p3. The output
%    curve_seg will have the property that the array order of each 
%    point will corresponds to that point's geometric place in 
%    the curve.
%
% EXAMPLE:
%    
%    [A B C D] = plane_equation(Nz, Iz, Cz);
%    fv = isosurface(vol,.9);
%    surf = fv.vertices;
%    curve = plane_surf_intersect([A B C D], surf, .3);
%    [curve_seg len gap] = find_curve_path(Nz, Iz, Cz, curve);
%    
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   2/9/2010


[q1 ip1]=nearest_point(curve, p1);
[q2 ip2]=nearest_point(curve, p2);
[q3 ip3]=nearest_point(curve, p3);
i=1;
ipc=ip1; 
pc=curve(ipc,:);
curve_seg(1,:)=curve(ip1,:);
while(~isempty(curve))
    [pn ipn]=nearest_point(curve, pc);
    d1=dist3(pc,q3);
    d2=dist3(pn,q3);

    if(all(pn==q3) | (ipn==ip3) | (d2==0))
        ipc=ipn; pc=pn;     
        break; 
    end

    if(d1>d2)
        i=i+1;
        curve_seg(i,:)=curve(ipn,:);
        ipc=ipn; pc=pn;            
    else
        curve(ipn,:)=[];
        if(ipn<ip1) ip1=ip1-1; end
        if(ipn<ip2) ip2=ip2-1; end
        if(ipn<ip3) ip3=ip3-1; end
        if(ipn<ipc) ipc=ipc-1; end
    end
end

while(~isempty(curve))
    [pn ipn]=nearest_point(curve, pc);
    d1=dist3(pc,q2);
    d2=dist3(pn,q2);

    if(all(pn==q2) | (ipn==ip2) | (d2==0))
        break; 
    end

    if(d1>d2)
        i=i+1;
        curve_seg(i,:)=curve(ipn,:);
        ipc=ipn; pc=pn;            
    else
        curve(ipn,:)=[];
        if(ipn<ip1) ip1=ip1-1; end
        if(ipn<ip2) ip2=ip2-1; end
        if(ipn<ip3) ip3=ip3-1; end
        if(ipn<ipc) ipc=ipc-1; end
    end
end

[len max_gap] = curvelen(curve_seg);    

