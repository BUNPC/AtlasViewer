function [files, dirnameGroup] = FindFiles(varargin)

% Syntax:
%
%    [files, dirnameGroup] = FindFiles()
%    [files, dirnameGroup] = FindFiles(dirnameGroup)
%    [files, dirnameGroup] = FindFiles(dirnameGroup, fmt)
% 
% Descrition:
%
%    Find all files of format fmt, in the current folder. 
% 
% Examples: 
%
%    files = FindFiles('c:\users\public\group1');
%    files = FindFiles('c:\users\public\group1','.snirf');


global maingui
global supportedFormats

supportedFormats = {
    '.snirf',0;
    '.nirs',0;
    };

%%%% Parse arguments

% First get all the argument there are to get using the 7 possible syntax
% calls 
if nargin==1
    dirnameGroup = varargin{1};
elseif nargin==2
    dirnameGroup = varargin{1};
    fmt = varargin{2};
end

if ~exist('dirnameGroup','var') || isempty(dirnameGroup)
    dirnameGroup = pwd;
end

if ~exist('fmt','var') || isempty(fmt)
    if ~isempty(maingui) && isstruct(maingui) && isfield(maingui,'format')
        fmt = maingui.format;
    else
        fmt = supportedFormats{1};
    end
end

% Check files data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = DataFilesClass();
while files.isempty()
    switch fmt
        case {'snirf','.snirf'}
            files = DataFilesClass(dirnameGroup, 'snirf');
            if files.isempty()
                files = [];
                return;
            end
        case {'nirs','.nirs'}
            files = DataFilesClass(dirnameGroup, 'nirs');
        otherwise
            q = menu(sprintf('Homer3 only supports file formats: {%s}. Please choose one.', cell2str(supportedFormats(:,1))), ...
                    'OK','CANCEL');
            if q==2
                files = DataFilesClass(dirnameGroup);
                return;
            else
                selection = checkboxinputdlg(supportedFormats(:,1), 'Select Supported File Format');
                if isempty(selection)
                    files = DataFilesClass(dirnameGroup);
                    return;
                end
                fmt = supportedFormats{selection,1};
                continue;
            end
    end
    if files.isempty()
        files = [];
        return;
    end
end


