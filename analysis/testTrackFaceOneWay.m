switch 1
    case 1
        datfile = '..\data\figure 2+3\facing_door.mat';
        resultDir = '..\results\Figure 2+3';
        lbl = 'Door';
        clr = 'bx';
        excludeForOffset = [4 45 46];
    case 2
        datfile = '..\data\figure 2+3\facing_computer.mat';
        resultDir = '..\results\Figure 2+3';
        lbl = 'Computer';
        clr = 'r+';
        excludeForOffset = [44 45];
end


if ~isdir(fullfile(cd,'..','results'))
    mkdir(fullfile(cd,'..','results'));
end
if ~isdir(fullfile(cd,resultDir))
    mkdir(fullfile(cd,resultDir));
end

load(datfile)

a=squeeze(mean(data,2));
% check where measured values do not change. just choose some arbitrary
% samples, should be fine. If values exactly constant: track loss
qHaveData = ~all(data(:,1,:)==data(:,34,:) & data(:,15,:)==data(:,45,:),3);

% get offsets so that mean offset from grid is zero. That is after all
% arbitrary
[gridx,gridz] = meshgrid(-4:4,2:-1:-2);
qUse = qHaveData & ~ismember(1:size(a,1),excludeForOffset).';
% find nearest gridpoint
d = hypot(repmat(a(qUse,1),1,numel(gridx))-repmat(gridx(:)',sum(qUse),1),repmat(a(qUse,3),1,numel(gridz))-repmat(gridz(:)',sum(qUse),1));
[~,whichp]=min(d,[],2);
offsets = [gridx(whichp)-a(qUse,1) gridz(whichp)-a(qUse,3)];
theOff  = mean(offsets);


clf
plot(a(qHaveData,1)+theOff(1),a(qHaveData,3)+theOff(2),clr)
xlabel('X (m)');
ylabel('Z (m)');
axis([-4.5 4.5 -3 3])
axis equal
grid on
print([resultDir '\xz_' lbl '.png'],'-dpng','-r300')
% print([resultDir '\xz_' lbl '.eps'],'-depsc2')


% heatmaps of height
cm = [0 0 0; DNcolormap2./255];
clim = [1 2];
missing = 0;
% put numbers in grid
Ycolumn = 2;
gridDat = nan(size(gridx));
for d=1:size(a,1)
    if ~qHaveData(d)
        continue;
    end
    qGrid = round(a(d,1)+theOff(1))==gridx & round(a(d,3)+theOff(2))==gridz;
    gridDat(qGrid) = a(d,Ycolumn);
end

qHasMissing = any(isnan(gridDat(:)));
if qHasMissing
    step = diff(clim)/(size(cm,1)-1); % last value is for missing data, don't count it here so missing will be neatly mapped to last value in color map
    gridDat(isnan(gridDat)) = clim(1)-step;
end

clf
imagesc(gridx(1,[1 end]),gridz([1 end],1).',gridDat)
axis xy
axis equal
% axis off
ax=gca;
ax.CLim = clim;
ax.XTick = sort(gridx(1,1:end));
ax.YTick = sort(gridz(1:end,1));
xlabel('X (m)');
ylabel('Z (m)');
% determine coloring of plot
if qHasMissing
    colormap(cm);
else
    colormap(cm(2:end,:));
end
cb=colorbar;
% cb.Ticks = [];
% cb.Box = 'off';
% cb.Color = [0.94 0.94 0.94]; % same color as background, otherwise there is a colored line on the side
print([resultDir '\Y_' lbl '.png'],'-dpng','-r720')
% print([resultDir '\Y_' lbl '.eps'],'-depsc')
