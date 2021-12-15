screenSize = get(0, 'MonitorPositions');

bwPatternParams.screenID = 2; % corresponds to second monitor, in my case projector
bwPatternParams.radius = 15;
bwPatternParams.feats_per_line = 6;
bwPatternParams.feat_dist = 12;
bwPatternParams.line_dist = 10;
bwPatternParams.brightness=0;
bwPatternParams.prjW = screenSize(bwPatternParams.screenID, 3);
bwPatternParams.prjH = screenSize(bwPatternParams.screenID, 4);

figHandle = figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', 'pattern');
[num_feats, dl, im] = genStructLightBlocks(bwPatternParams);
bwPatternParams.line_dist = dl;
bwPatternParams.num_feats = num_feats;

cla;
imshow(im);

axeHandle = gca;
set(axeHandle, 'Position', [0 0 1 1])
set(figHandle, 'Position', screenSize(bwPatternParams.screenID,:))
set(figHandle, 'WindowState', 'fullscreen')

% speedup projection
set(gca, 'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual');
    set(figHandle,'doublebuffer','off');

save('bwPatternParams.mat', 'bwPatternParams');
