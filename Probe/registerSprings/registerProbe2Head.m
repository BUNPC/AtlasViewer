function probe = registerProbe2Head(probe, headvol, refpts)
global atlasViewer
[b, msg] = probeHasSpringRegistration(probe);
if b == 2
    dataTree = atlasViewer.dataTree;
    if ~isempty(dataTree)
        probe_data = dataTree.currElem.GetProbe();
        if ~isempty(probe_data.landmarkPos3D) && ~isempty(probe_data.landmarkPos3D)
            refpts_labels = {'T7','T8','Oz','Fpz','Cz','C3','C4','Pz','Fz','LPA','RPA','NAISON'};
            
            for u = 1:length(refpts_labels)
                label = refpts_labels{u};
                idx1 = ismember(probe_data.landmarkLabels, label);
                idx2 = ismember(atlasViewer.refpts.labels, label);
                if sum(idx1)>0 && sum(idx2)>0
                    probe_refps_pos(u,:) = probe_data.landmarkPos3D(idx1,:);
                    AV_refpts_pos(u,:) = atlasViewer.refpts.pos(idx2,:);
                end
            end
            probe_refps_pos = [probe_refps_pos ones(size(probe_refps_pos,1),1)];
            T = probe_refps_pos\AV_refpts_pos;
            optpos = [probe_data.sourcePos3D; probe_data.detectorPos3D];
            optpos = [optpos ones(size(optpos,1),1)];
            optpos_reg = optpos*T;
            probe.optpos_reg  = optpos_reg;
            probe.orientation = headvol.orientation;
            probe = pullProbeToHeadsurf(probe, headvol);
        end
    end
else
    [optconn, anchor_pts] = spring2posprobe(probe, refpts, headvol);
    if ~isempty(probe.optpos_reg)
        posprobe_data = gen_positionprobe_dat(probe.optpos_reg, optconn, anchor_pts);
    else
        posprobe_data = gen_positionprobe_dat(probe.optpos, optconn, anchor_pts);
    end
    if isempty(posprobe_data)
        return;
    end
    optpos_reg = positionprobe(posprobe_data, ...
                               [1 2 3], ...
                               1, ...
                               [0 0 0], ...
                               headvol.img, ...
                               headvol.center, ...
                               400);
    % Shed dummy points                      
    probe.optpos_reg  = optpos_reg;
    probe.orientation = headvol.orientation;
end