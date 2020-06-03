function [nz, iz, rpa, lpa, cz, czo, o] = findRefptsAxes(refpts)

nz  = [];
iz  = [];
rpa = [];
lpa = [];
cz  = [];
czo = [];
o   = [];

if isstruct(refpts)
    k = find(strcmpi(refpts.labels,'nz'));
    if ~isempty(k)
        p(1,:) = refpts.pos(k,:);
    end
    k = find(strcmpi(refpts.labels,'iz'));
    if ~isempty(k)
        p(2,:) = refpts.pos(k,:);
    end
    k = find(strcmpi(refpts.labels,'rpa'));
    if ~isempty(k)
        p(3,:) = refpts.pos(k,:);
    end
    k = find(strcmpi(refpts.labels,'lpa'));
    if ~isempty(k)
        p(4,:) = refpts.pos(k,:);
    end
    k = find(strcmpi(refpts.labels,'cz'));
    if ~isempty(k)
        p(5,:) = refpts.pos(k,:);
    end
else
    p = refpts;
end

if size(p,1)>=5
    nz  = p(1,:);
    iz  = p(2,:);
    rpa = p(3,:);
    lpa = p(4,:);
    cz  = p(5,:);
    czo = [];
    if size(p,1)==6
        czo = p(6,:);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine origin of the head: Get line between LPA and RPA
    % and line between Nz and Iz.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m1 = [(rpa(1)+lpa(1))/2, (rpa(2)+lpa(2))/2, (rpa(3)+lpa(3))/2];
    m2 = [(nz(1)+iz(1))/2,   (nz(2)+iz(2))/2,   (nz(3)+iz(3))/2];
    o = mean([m1; m2]);
    if isempty(czo)
        czo = AVUtils.points_on_line(o,cz,-1,'relative');
    end
    m3 = [(cz(1)+czo(1))/2,  (cz(2)+czo(2))/2,  (cz(3)+czo(3))/2];
    
    % Translate head axes to common head origin
    T1 = [1 0 0 o(1)-m1(1); 0 1 0 o(2)-m1(2); 0 0 1 o(3)-m1(3); 0 0 0 1];
    T2 = [1 0 0 o(1)-m2(1); 0 1 0 o(2)-m2(2); 0 0 1 o(3)-m2(3); 0 0 0 1];
    T3 = [1 0 0 o(1)-m3(1); 0 1 0 o(2)-m3(2); 0 0 1 o(3)-m3(3); 0 0 0 1];
    
    rpa = xform_apply(rpa, T1);
    lpa = xform_apply(lpa, T1);
    nz  = xform_apply(nz , T2);
    iz  = xform_apply(iz , T2);
    cz  = xform_apply(cz , T3);
    czo = xform_apply(czo, T3);
end

