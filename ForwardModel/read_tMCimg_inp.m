function config = read_tMCimg_inp(mc_sess)

% USAGE: 
%
%     config = read_tMCimg_inp(mc_sess)
%
% DESCRIPTION:
%
%     Reads in tMCimg configuration data from the first .inp input file
%     into the structure config. The structure fields are
%
%         phot_num   
%         seed
%         srcpos
%         srcdirection
%         temporal_gates
%         mri_seg_file
%         Dx
%         Dy
%         Dz
%         Sx_min
%         Sx_max
%         Sy_min
%         Sy_max
%         Sz_min
%         Sz_max
%         tiss_num
%         tiss_prop
%         num_det
%         det_rad
%         detpos
%
%     The input file name that it looks for is <mc_sess>.s1.inp, where mc_sess 
%     is the input argument. 
%
% EXAMPLE 1: 
%
%     >> dir slab_phi_0.*.inp
% 
%     slab_phi_0.d1.inp  slab_phi_0.d3.inp  slab_phi_0.d5.inp  slab_phi_0.d7.inp  slab_phi_0.d9.inp  slab_phi_0.s2.inp  slab_phi_0.s4.inp  
%     slab_phi_0.d2.inp  slab_phi_0.d4.inp  slab_phi_0.d6.inp  slab_phi_0.d8.inp  slab_phi_0.s1.inp  slab_phi_0.s3.inp  
%
%     >> config = read_tMCimg_inp('slab_phi_0');
%     >> config
% 
%     config = 
% 
%               phot_num: 10000000
%                   seed: -39111473
%                 srcpos: [40 60 10]
%           srcdirection: [0.2300 -0.1900 0.9500]
%         temporal_gates: [0 5.0000e-09 5.0000e-09]
%           mri_seg_file: 'slab_seg.bin'
%                     Dx: 100
%                     Dy: 100
%                     Dz: 100
%                 Sx_min: 1
%                 Sx_max: 100
%                 Sy_min: 1
%                 Sy_max: 100
%                 Sz_min: 1
%                 Sz_max: 100
%               tiss_num: 1
%              tiss_prop: [0.6600 1.0000e-03 0.0190 1]
%                num_det: 12
%                det_rad: 1
%                 detpos: [12x3 double]
%        
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   06/24/2009


    % Define and allocate structure for the output
    config = struct('phot_num',0, 'seed',0, 'srcpos',[], 'srcdirection',[], ...
                    'temporal_gates',[], 'mri_seg_file','', 'Dx',0, 'Dy',0, 'Dz',0, ...
                    'Sx_min',0, 'Sx_max',0, 'Sy_min',0, 'Sy_max',0, 'Sz_min',0, 'Sz_max',0, ... 
                    'tiss_num',0, 'tiss_prop',[], 'det_rad',0, 'num_det',0, 'detpos', []);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read in parameters from the inp file for laser 1 
    % (that's always garanteed to be there). 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(mc_sess, 'rb');
    if(fid == -1)
        mc_sess_inp_file = strcat(mc_sess, '.inp');
        fid = fopen(mc_sess_inp_file, 'rb');
        if(fid == -1)
            mc_sess_inp_file = strcat(mc_sess, '.s1.inp');
            fid = fopen(mc_sess_inp_file, 'rb');
            if(fid == -1)
                config=[];
                return;
            end
        end
    end


    config.phot_num = str2num(fgetl(fid));
    config.seed = str2num(fgetl(fid));
    config.srcpos(1, :) = str2num(fgetl(fid));
    config.srcdirection = str2num(fgetl(fid));
    config.temporal_gates = str2num(fgetl(fid));
    config.mri_seg_file = fgetl(fid);

    % Get anatomical dimensions
    Dim = str2num(fgetl(fid));
    config.Dx = Dim(2);
    config.Sx_min = Dim(3);
    config.Sx_max = Dim(4);

    Dim = str2num(fgetl(fid));
    config.Dy = Dim(2);
    config.Sy_min = Dim(3);
    config.Sy_max = Dim(4);

    Dim = str2num(fgetl(fid));
    config.Dz = Dim(2);
    config.Sz_min = Dim(3);
    config.Sz_max = Dim(4);

    % Get tissue properties
    config.tiss_num = str2num(fgetl(fid));
    for i=1:config.tiss_num
        config.tiss_prop(i,:) = str2num(fgetl(fid));
    end
    
    % Get rest of the optode positions
    det_info = str2num(fgetl(fid));
    config.num_det = det_info(1);
    if(config.num_det ~= 0)
        config.det_rad = det_info(2);
        for i=1:config.num_det
            config.detpos(i, :) = str2num(fgetl(fid));
        end
    end
    fclose(fid);


