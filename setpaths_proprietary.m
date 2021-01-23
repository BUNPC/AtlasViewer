function setpaths_proprietary(options)


if options.fluence_simulate
    genMultWlFluenceFiles_CurrWorkspace;
end

r = checkToolboxes('AtlasViewer');

fprintf('\n');
if all(r==1)
    fprintf('All required toolboxes are installed.\n');
elseif ismember(3, r)
    fprintf('Unable to verify if all required toolboxes are installed ...\n');
elseif ismember(4, r)
    fprintf('Unable to verify if all required toolboxes are installed with older Matlab release...\n');
else
    fprintf('Some required toolboxes are missing...\n');
end

pause(2);

fullpathappl = fileparts(which('AtlasViewerGUI.m'));

msg{1} = sprintf('For instructions to perform basic test of AtlasViewerGUI, open the PDF file %s', ...
                 [fullpathappl, '/Test/Testing_procedure.pdf']);
fprintf('\n\n*** %s ***\n\n', [msg{:}]);


