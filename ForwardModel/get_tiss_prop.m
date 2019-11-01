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

% Default tissue property values
SCATTERING_SKIN_DEF_VAL  = 0.6600;
SCATTERING_SKULL_DEF_VAL = 0.8600;
SCATTERING_DM_DEF_VAL    = 0.6600;
SCATTERING_CSF_DEF_VAL   = 0.0100;
SCATTERING_GM_DEF_VAL    = 1.1000;
SCATTERING_WM_DEF_VAL    = 1.1000;
SCATTERING_OTHER_DEF_VAL = 0.8600;

ABSORPTION_SKIN_DEF_VAL  = 0.0191; 
ABSORPTION_SKULL_DEF_VAL = 0.0136; 
ABSORPTION_DM_DEF_VAL    = 0.0191;
ABSORPTION_CSF_DEF_VAL   = 0.0026; 
ABSORPTION_GM_DEF_VAL    = 0.0186; 
ABSORPTION_WM_DEF_VAL    = 0.0186; 
ABSORPTION_OTHER_DEF_VAL = 0.0191;

ANISOTROPY_SKIN_DEF_VAL  = 0.0010;
ANISOTROPY_SKULL_DEF_VAL = 0.0010;
ANISOTROPY_DM_DEF_VAL    = 0.0010;
ANISOTROPY_CSF_DEF_VAL   = 0.0010;
ANISOTROPY_GM_DEF_VAL    = 0.0010;
ANISOTROPY_WM_DEF_VAL    = 0.0010;
ANISOTROPY_OTHER_DEF_VAL = 0.0010;

REFRACTION_SKIN_DEF_VAL  = 1.0000;
REFRACTION_SKULL_DEF_VAL = 1.0000;
REFRACTION_DM_DEF_VAL    = 1.0000;
REFRACTION_CSF_DEF_VAL   = 1.0000;
REFRACTION_GM_DEF_VAL    = 1.0000;
REFRACTION_WM_DEF_VAL    = 1.0000;
REFRACTION_OTHER_DEF_VAL = 1.0000;

%%% Extract args

% Arg 1 
names = {};
if length(varargin)>=1
    if ischar(varargin{1}) && exist(varargin{1},'file')
        
        filename = varargin{1};
        fid = fopen(filename,'rt');
        while 1
            str = fgetl(fid);
            if str == -1 
                break;
            end
            names{end+1}=str;
        end
        
    else
        
        names0 = varargin{1};
        
        % Exract and separate all tissue names into cells
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
propval = [];
m=length(propnames);
n=length(names);
for i=1:m
    switch lower(propnames{i})
    case 'anisotropy'
        for j=1:n
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval(j,i) = ANISOTROPY_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval(j,i) = ANISOTROPY_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval(j,i) = ANISOTROPY_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval(j,i) = ANISOTROPY_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval(j,i) = ANISOTROPY_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval(j,i) = ANISOTROPY_WM_DEF_VAL;
            case 'other'
                propval(j,i) = ANISOTROPY_OTHER_DEF_VAL;
            otherwise
                propval(j,i) = ANISOTROPY_OTHER_DEF_VAL;
            end
        end
    case 'scattering'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval(j,i) = SCATTERING_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval(j,i) = SCATTERING_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval(j,i) = SCATTERING_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval(j,i) = SCATTERING_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval(j,i) = SCATTERING_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval(j,i) = SCATTERING_WM_DEF_VAL;
            case 'other'
                propval(j,i) = SCATTERING_OTHER_DEF_VAL;
            otherwise
                propval(j,i) = SCATTERING_OTHER_DEF_VAL;
            end
        end
    case 'absorption'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval(j,i) = ABSORPTION_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval(j,i) = ABSORPTION_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval(j,i) = ABSORPTION_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval(j,i) = ABSORPTION_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval(j,i) = ABSORPTION_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval(j,i) = ABSORPTION_WM_DEF_VAL;
            case 'other'
                propval(j,i) = ABSORPTION_OTHER_DEF_VAL;
            otherwise
                propval(j,i) = ABSORPTION_OTHER_DEF_VAL;
            end
        end
    case 'refraction'
        for j=1:n            
            switch lower(names{j})
            case {'skin', 'scalp'}
                propval(j,i) = REFRACTION_SKIN_DEF_VAL;
            case {'skull', 'bone'}
                propval(j,i) = REFRACTION_SKULL_DEF_VAL;
            case {'dura', 'dura mater', 'dm'}
                propval(j,i) = REFRACTION_DM_DEF_VAL;
            case {'csf', 'cerebral spinal fluid'}
                propval(j,i) = REFRACTION_CSF_DEF_VAL;
            case {'gm', 'gray matter', 'brain'}
                propval(j,i) = REFRACTION_GM_DEF_VAL;
            case {'wm', 'white matter'}
                propval(j,i) = REFRACTION_WM_DEF_VAL;
            case 'other'
                propval(j,i) = REFRACTION_OTHER_DEF_VAL;
            otherwise
                propval(j,i) = REFRACTION_OTHER_DEF_VAL;
            end
        end
    end
end


%%% Assign results to output struct
for j=1:length(names)
    tiss_prop(j).name = names{j};
    for i=1:length(propnames)
        eval(sprintf('tiss_prop(j).%s = propval(j,i);',propnames{i}));
    end
end
