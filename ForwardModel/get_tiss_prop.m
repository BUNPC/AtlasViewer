function tiss_prop = get_tiss_prop(varargin)

% Usage:
%
%     tiss_prop = get_tiss_prop(tissname, propname)
%     tiss_prop = get_tiss_prop(tissname)
%     tiss_prop = get_tiss_prop(filename, propname)
%     tiss_prop = get_tiss_prop(filename)
%
%
% Description:
%     
%     
%
% Example 1:
% 
%     get_tiss_prop('skin:skull:csf', 'absorption')
%
%          1x3 struct array with fields:
%              name
%        absorption
%               val
%
%     get_tiss_prop('skin', 'absorption')
%
%              name: 'skin'
%        absorption: 'absorption'
%               val: 0.0191
%         
%     get_tiss_prop('skull', 'absorption')
%
%              name: 'skull'
%        absorption: 'absorption'
%               val: 0.0136
%
%     get_tiss_prop('csf', 'absorption')
%
%              name: 'csf'
%        absorption: 'absorption'
%               val: 0.0026
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   11/15/2012
%

tiss_prop = struct([]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default tissue properties for wavelength 760nm and 860nm 
% Reference: Sensors. 13 February 2023
% Impact of Anatomical Variability on Sensitivity Pro?le in fNIRS–MRI Integration
% Augusto Bonilauri 1, * , Francesca Sangiuliano Intra 2, Francesca Baglio 3and Giuseppe Baselli 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scattering 
SCATTERING_SKIN_DEF_VAL  = [0.6727, 0.5818];
SCATTERING_SKULL_DEF_VAL = [0.8545, 0.7636];
SCATTERING_DM_DEF_VAL    = [0.6600, 0.2727];
SCATTERING_CSF_DEF_VAL   = [0.2727, 0.2727];
SCATTERING_GM_DEF_VAL    = [0.7600, 0.6165];
SCATTERING_WM_DEF_VAL    = [1.0825, 0.9188];
SCATTERING_OTHER_DEF_VAL = [0.8600, 0.6727];

% Absorption 
ABSORPTION_SKIN_DEF_VAL  = [0.0170, 0.0019]; 
ABSORPTION_SKULL_DEF_VAL = [0.0116, 0.0139]; 
ABSORPTION_DM_DEF_VAL    = [0.0191, 0.6727];
ABSORPTION_CSF_DEF_VAL   = [0.0040, 0.0040]; 
ABSORPTION_GM_DEF_VAL    = [0.0180, 0.0192]; 
ABSORPTION_WM_DEF_VAL    = [0.0167, 0.0208]; 
ABSORPTION_OTHER_DEF_VAL = [0.0180, 0.6727];

% Anisotropy
ANISOTROPY_SKIN_DEF_VAL  = [0.0010, 0.0010];
ANISOTROPY_SKULL_DEF_VAL = [0.0010, 0.0010];
ANISOTROPY_DM_DEF_VAL    = [0.0010, 0.0010];
ANISOTROPY_CSF_DEF_VAL   = [0.0010, 0.0010];
ANISOTROPY_GM_DEF_VAL    = [0.0010, 0.0010];
ANISOTROPY_WM_DEF_VAL    = [0.0010, 0.0010];
ANISOTROPY_OTHER_DEF_VAL = [0.0010, 0.0010];

% Refraction
REFRACTION_SKIN_DEF_VAL  = [1.0000, 1.0000];
REFRACTION_SKULL_DEF_VAL = [1.0000, 1.0000];
REFRACTION_DM_DEF_VAL    = [1.0000, 1.0000];
REFRACTION_CSF_DEF_VAL   = [1.0000, 1.0000];
REFRACTION_GM_DEF_VAL    = [1.0000, 1.0000];
REFRACTION_WM_DEF_VAL    = [1.0000, 1.0000];
REFRACTION_OTHER_DEF_VAL = [1.0000, 1.0000];

%%% Extract args

% Arg 1 
names = {};
if length(varargin)>=1
    if ispathvalid(varargin{1}, 'file:checkextension')
        
        maxiter = 20;
        iter = 0;
        filename = varargin{1};
        fid = fopen(filename,'rt');
        while iter<maxiter
            iter = iter+1;
            str = fgetl(fid);
            if str == -1 
                break;
            end
            names{end+1} = str; %#ok<*AGROW>
        end
        fclose(fid);
        
    else
        
        names0 = varargin{1};
        
        % Extract and separate all tissue names into cells
        if ~iscell(names0)
            iname = [1 strfind(names0, ':')+1 size(names0,2)+2];
            for i=1:length(iname)-1
                j = iname(i);
                k = iname(i+1);
                names{i} = names0(j:k-2);
            end
        else
            names = names0;
        end
        
    end
    propnames{1} = 'scattering';
    propnames{2} = 'anisotropy';
    propnames{3} = 'absorption';
    propnames{4} = 'refraction';
end

% Arg 2
if length(varargin)==2
    propnames0 = varargin{2};

    % Exract and separate all property names into cells
    if ~iscell(propnames0)
        propnames = {};
        ipropname = [1 strfind(propnames0, ':')+1 size(propnames0,2)+2];
        for i=1:length(ipropname)-1
            j = ipropname(i);
            k = ipropname(i+1);
            propnames{i} = propnames0(j:k-2);
        end
    else
        propnames = propnames0;
    end
end


%%% Parse tissue names and tissue property names and find their values
propval = {};
m=length(propnames);
n=length(names);
for i=1:m
    switch lower(propnames{i})
    case 'anisotropy'
        for j=1:n
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval{j,i} = ANISOTROPY_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval{j,i} = ANISOTROPY_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval{j,i} = ANISOTROPY_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval{j,i} = ANISOTROPY_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval{j,i} = ANISOTROPY_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval{j,i} = ANISOTROPY_WM_DEF_VAL;
            case 'other'
                propval{j,i} = ANISOTROPY_OTHER_DEF_VAL;
            otherwise
                propval{j,i} = ANISOTROPY_OTHER_DEF_VAL;
            end
        end
    case 'scattering'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval{j,i} = SCATTERING_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval{j,i} = SCATTERING_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval{j,i} = SCATTERING_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval{j,i} = SCATTERING_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval{j,i} = SCATTERING_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval{j,i} = SCATTERING_WM_DEF_VAL;
            case 'other'
                propval{j,i} = SCATTERING_OTHER_DEF_VAL;
            otherwise
                propval{j,i} = SCATTERING_OTHER_DEF_VAL;
            end
        end
    case 'absorption'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval{j,i} = ABSORPTION_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval{j,i} = ABSORPTION_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval{j,i} = ABSORPTION_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval{j,i} = ABSORPTION_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval{j,i} = ABSORPTION_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval{j,i} = ABSORPTION_WM_DEF_VAL;
            case 'other'
                propval{j,i} = ABSORPTION_OTHER_DEF_VAL;
            otherwise
                propval{j,i} = ABSORPTION_OTHER_DEF_VAL;
            end
        end
    case 'refraction'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval{j,i} = REFRACTION_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval{j,i} = REFRACTION_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval{j,i} = REFRACTION_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval{j,i} = REFRACTION_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval{j,i} = REFRACTION_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval{j,i} = REFRACTION_WM_DEF_VAL;
            case 'other'
                propval{j,i} = REFRACTION_OTHER_DEF_VAL;
            otherwise
                propval{j,i} = REFRACTION_OTHER_DEF_VAL;
            end
        end
    end
end


%%% Assign results to output struct
for j=1:length(names)
    tiss_prop(j).name = names{j};
    for i=1:length(propnames)
        eval(sprintf('tiss_prop(j).%s = propval{j,i};',propnames{i}));
    end
end
