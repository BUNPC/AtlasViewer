function checkForAtlasViewerUpdates()
    cfg = ConfigFileClass(); 
    if (strcmp(cfg.GetValue('Check For Updates'),'off'))
        return;
    end
    
    url = 'http://bu.edu/neurophotonics/research/fnirs/atlasviewer';
    promptFlag = 0;
    try
        % Open a hidden web browser 
        [~,h] = web(url);
        p = getParentRecursive(h);
        p.setVisible(0);
        s = urlread(url,'timeout',2);
    catch
        % App is offline or server could not be reached
        close(h);
        return
    end
    updateTxt = ''; % Get information about potential update from s
    vrnum = getVernum();  % Compare to current version and set promptFlag
    % if (vrnum < updateTxt) & (cfg.GetValue('LatestUpdateRefused') < updateTxt)
    %   promptFlag = 1;
    % end
    if (promptFlag)
        choice = questdlg(['An update for AtlasViewer is available: ',...
            updateTxt,...
            ' Would you like to download it?'],...
            'Update Available',...
            'Yes','Remind me later','Don''t show this again',...
            'Remind me later');
        switch choice
            case 'Yes'
                % Open browser to update page
                web(url);    
            case 'Don''t ask again'
                % Make sure user doesn't get asked about this particular
                % update again.
                %
                % cfg.SetValue('LatestUpdateRefused',updateTxt); 
        end
    end
    close(h);
end