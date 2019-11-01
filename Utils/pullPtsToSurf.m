function pts = pullPtsToSurf(pts, surf0, mode, depth, showprogress)

if ~exist('mode','var')
    mode='normal';
end
if ~exist('depth','var')
    depth=0;
end
if ~exist('showprogress','var')
    showprogress=true;
end

if showprogress
    hwait = waitbar(0,'Please wait...');
end

vol = [];
if isfield(surf0,'img') && ndims(surf0.img)==3
    if ~strcmpi(mode,'nearest')
        vol = surf0.img;
    end
    surf = isosurface(surf0.img,.9);
    surf.vertices = [surf.vertices(:,2) surf.vertices(:,1) surf.vertices(:,3)];
    v = surf.vertices;
elseif isfield(surf0,'vertices') && ndims(surf0.vertices)==2
    v = surf0.vertices;
elseif isfield(surf0,'mesh') && isfield(surf0.mesh,'vertices') && ndims(surf0.mesh.vertices)==2
    v = surf0.mesh.vertices;
elseif ndims(surf0)==3
    if ~strcmpi(mode,'nearest')
        vol = surf0;
    end
    surf = isosurface(surf0,.9);
    surf.vertices = [surf.vertices(:,2) surf.vertices(:,1) surf.vertices(:,3)];
    v = surf.vertices;
elseif ndims(surf0)==2
    v = surf0;
end
c = findcenter(v);

% Use normal to the surface to project points to surface 
if strcmpi(mode,'normal')

    nv = nodesurfnorm(v,f);
    [d2surf,cn] = dist2surf(v,nv,pts);
    pts = proj2mesh(v,f,pts,nv,cn);

% Use center of surface to project points to surface 
elseif strcmpi(mode,'center')

    step = 0.01;
    h = 10;

    % In volume
    if ~isempty(vol)

        dims = size(vol);
        nx=dims(1);
        ny=dims(2);
        nz=dims(3);
        for ii=1:size(pts,1)
            if showprogress 
                waitbar(ii/size(pts,1),hwait);
            end
        
            q = pts(ii,:);
            
            % Let c be voxel of attraction inside volume surface.
            % Let q be voxel which is being projected to volume surface
            % 
            % Brief description of algorithm: Move voxel q toward or 
            % away from attraction voxel c depending on whether it is 
            % inside or outside enclosed volume surface. To figure out 
            % whether q is inside or outside volume surface, if the value of 
            % voxel q equals zero then q is outside surface, a nonzero 
            % value means it's inside.
            while 1
                
                if round(q(1))>nx || round(q(1))<1 || round(q(2))>ny || round(q(2))<1 || round(q(3))>nz || round(q(3))<1
                    break;
                end             
        
                % Decide if q is inside or outside surface
                if vol(round(q(1)),round(q(2)),round(q(3)))==0
                    
                    % q is outside surface - move q in direction toward c.
                    q = points_on_line(q,c,step);
                    if vol(round(q(1)),round(q(2)),round(q(3)))>0 
                        q = points_on_line(q,c,depth,'absolute');
                        % q = round(q);
                        break;
                    end
                    
                else
                    
                    % q is inside surface - move q in direction away from c.
                    q = points_on_line(q,c,-step);
                    
                end
                
            end
            pts(ii,:) = q;
        end

    % On surface mesh
    else

        for ii=1:size(pts,1)
            if showprogress 
                waitbar(ii/size(pts,1),hwait);
            end        
            q = pts(ii,:);
        
            % Find nearest point to q on the surface
            lst=[];
            while isempty(lst)
                lst = find( abs(v(:,1)-q(1))<h & abs(v(:,2)-q(2))<h & abs(v(:,3)-q(3))<h );
                h=h+5;
            end
            rsep = sum( (v(lst,:) - ones(length(lst),1)*q).^2, 2 ).^0.5;
            [foo,imin] = min(rsep);
            s = v(lst(imin),:);
            
            % Let p be point of attraction inside surface.
            % Let q be point which is being projected to surface
	        % Let s be nearest point on surface to q.
            % 
            % Brief description of algorithm: Move point q toward or 
            % away from attraction point p depending on whether it is 
            % inside or outside enclosed surface. To figure out whether
            % q is inside or outside surface, use point s to check 
            % whether q is closer to s or p (see comments below in 
            % while loop). 
            while 1
                
                q0 = q;
                prev_dist = dist3(q0,s);
                
                % Decide if q is inside or outside surface
                if dist3(c,q)>dist3(c,s) && dist3(c,q)>dist3(q,s)
                    
                    % q is outside surface - move q in direction toward p.
                    q = points_on_line(q,c,step);
                    
                elseif dist3(c,q)<dist3(c,s)
                    
                    % q is inside surface - move q in direction away from p.
                    q = points_on_line(q,c,-step);
                    
                end
                
                % If distance has increased then we got as close as we could - so we
                % get out of loop.
                if dist3(q,s) >= prev_dist
                    q = q0;
                    break;
                end
                
            end
            pts(ii,:) = q;
        end

    end
    
elseif strcmpi(mode,'nearest')
    
    h = 10;
    if ~isempty(vol)

        return;
        
    % On surface mesh
    else

        for ii=1:size(pts,1)
            if showprogress 
                waitbar(ii/size(pts,1),hwait);
            end        
            q = pts(ii,:);
        
            % Find nearest point to q on the surface
            lst=[];
            while isempty(lst)
                lst = find( abs(v(:,1)-q(1))<h & abs(v(:,2)-q(2))<h & abs(v(:,3)-q(3))<h );
                h=h+5;
            end
            rsep = sum( (v(lst,:) - ones(length(lst),1)*q).^2, 2 ).^0.5;
            [~,imin] = min(rsep);
            s = v(lst(imin),:);
            q = s;
            pts(ii,:) = q;
        end

    end
        
end

% Make sure the final pts are on head surface
pts = nearest_point(v,pts);

if showprogress
    close(hwait);
end

