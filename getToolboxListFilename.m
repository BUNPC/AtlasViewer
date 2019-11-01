function filenameFinal = getToolboxListFilename(appName)

filenameFinal = '';

switch(appName)
    
    case 'Homer2_UI'
        
        if verLessThan('matlab','8.5')
            for ii=2009:2014
                if mod(ii,2)==0
                    c = 'b';
                else
                    c = 'a';
                end
                matlabRelease = sprintf('%d%s', ii, c);
                filename = sprintf('./toolboxesRequired_%s_%s.txt', appName, matlabRelease);
                if exist(filename, 'file')==2
                    filenameFinal = filename;
                    break;
                end
            end
            if isempty(filenameFinal)
                filename = sprintf('./toolboxesRequired_%s.txt', appName);
                if exist(filename, 'file')==2
                    filenameFinal = filename;
                end                
            end                
        elseif verGreaterThanOrEqual('matlab', '8.5')
            for ii=2015:2017
                if mod(ii,2)==0
                    c = 'b';
                else
                    c = 'a';
                end
                matlabRelease = sprintf('%d%s', ii, c);
                filename = sprintf('./toolboxesRequired_%s_%s.txt', appName, matlabRelease);
                if exist(filename, 'file')==2
                    filenameFinal = filename;
                    break;
                end
            end
        end
        
    case 'AtlasViewerGUI'
        
        if isempty(filenameFinal)
            filename = sprintf('./toolboxesRequired_%s.txt', appName);
            if exist(filename, 'file')==2
                filenameFinal = filename;
            end
        end
        
end

filenameFinal = filename;

