function title = banner()
platform = ['R', version('-release')];
title = sprintf('AtlasViewerGUI  (v%s, %s) - %s', getVernum('AtlasViewerGUI'), platform, filesepStandard(pwd));
