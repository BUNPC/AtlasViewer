function neighbors = optconn_auto_gen(optpos)

%
% Usage:
%
%     neighbors = optconn_auto_gen(optode_positions)
%
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   10/09/2009
%  

    %%%% GENERATE NEIGHBORS DISTANCES 
    d = distmatrix(optpos);
    neighbors = [];
    for j=1:size(d, 2)
    
        n = [];
        
        % Find the minimum of non-zero distances for jth optode
        
        for k=1:3
            i_dist_col = find(d(:,j)~=0);
            i_dist_row = find(d(j,:)~=0);
            if(isempty(i_dist_col) | isempty(i_dist_row))
                n = [n 0 0];
            else
                m1 = min(d(i_dist_col,j));
                m2 = min(d(j,i_dist_row));
                if(m1 <= m2)
                    i1 = find(d(:,j) == m1);
                    n = [n i1(1) round(m1)];
                    d(i1(1),j) = 0;
                    i=i1; m=m1;
                elseif(m1 > m2)
                    i2 = find(d(j,:) == m2);
                    n = [n i2(1) round(m2)];
                    d(j,i2(1)) = 0;
                    i=i2; m=m2;
                end
            end
        end
        neighbors(j,:) = n;
    end    
