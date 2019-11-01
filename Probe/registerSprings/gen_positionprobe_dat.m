function [data, optpos] = gen_positionprobe_dat(optpos, optconn, anchor_pts)

%
% Usage:
%
%     data = gen_positionprobe_dat(optpos, optconn, anchor_pts)
%
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%  

data = [];

%%%% TRANSFORM FLAT OPTODES TO HEAD
if all(anchor_pts(:,1) <= size(optpos,1))
	p1 = optpos(anchor_pts(:,1),:);
	p2 = anchor_pts(:,2:4);
	T = gen_xform_from_pts(p1,p2);
	if isempty(T)
		return;
	end
	optpos = (T*[optpos';ones(1,size(optpos,1))])';
	optpos(:,4) = [];
end

%%%% GENERATE NEIGHBORS DISTANCES 
neighbors = optconn;  

%%%% REPLACE OPTODE ROWS WHICH HAVE ASSOCIATED SURFACE POINTS WITH 
%%%% THE SURFACE COORDINATES (ANCHOR POINTS)
optpos_dxdydz = [optpos ones(size(optpos,1), 3)];
for i=1:size(anchor_pts, 1)
     optpos_dxdydz(anchor_pts(i,1), 1:6) = [anchor_pts(i,2:4) 0 0 0];
end

%%%% CREATE FINAL PROBE DATA 
data = [[1:size(optconn,1)]' optpos_dxdydz neighbors];
    

