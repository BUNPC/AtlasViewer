function ml = getMeasListFromAxes(optpos_src, optpos_det, h_edges)

ml = zeros(length(h_edges),2);
for ii = 1:length(h_edges)
    x = get(h_edges(ii),'xdata');
    y = get(h_edges(ii),'ydata');
    z = get(h_edges(ii),'zdata');
    
    p1 = [x(1) y(1) z(1)];
    p2 = [x(2) y(2) z(2)];
    
    j = find(optpos_src(:,1)==p1(1) & optpos_src(:,2)==p1(2) & optpos_src(:,3)==p1(3));
    if isempty(j)
        [~,j] = nearest_point(optpos_src,p1);
    end
    j = sort(j);
    
    k = find(optpos_det(:,1)==p2(1) & optpos_det(:,2)==p2(2) & optpos_det(:,3)==p2(3));
    if isempty(k)
        [~,k] = nearest_point(optpos_det,p2);
    end
    k = sort(k);

    % Fix for matlab error when updating position of optode and 
    % it happens to coinside with a second optode position.
    % Jul, 5, 2016    
    for p = 1:length(j)
        for q = 1:length(k)
            % Make sure measurement pair is unique
            % If measurement pair already exists in ml then 
            % move to the next src/det possibility for the two 
            % positions associated with this edge. 
            if isempty(find(ml(:,1)==j(p) & ml(:,2)==k(q)))
                ml(ii,1) = j(p);
                ml(ii,2) = k(q);
                break;
            end
        end
    end
end
