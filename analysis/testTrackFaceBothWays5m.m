close all
clim = [];
qCheckMissingData = true;
xoff = 0;
qFixPPT = false;
    
switch 3
    case 1
        load('..\data\figure 11ab\facing_computer_then_door.mat');
        resultDir    = '..\results\Figure 11';
        faceDoor     = 29:65;
        faceComputer = 1:28;
        clim         = [1.5 1.9];
        xoff         = -.5;
    case 2
        load('..\data\figure 12ab+13ab\20161223190526.mat');
        resultDir    = '..\results\Figure 12';
        faceDoor     = 24:46;
        faceComputer = 1:23;
        thedata = data;
        data = reshape(cat(1,data{:}),size(data));
        data = reshape({data.vive},size(data));
        data = cellfun(@(x) permute(x,[3 2 1]),data,'uni',false);
        data = reshape(cat(1,data{:}),size(data,1),size(data,2),[]);
        data(35,:,:) = []; % unneeded extra measurement
        clim = [1.52 1.57];
    case 4
        load('..\data\figure 12ab+13ab\20161223190526.mat');
        resultDir    = '..\results\Figure 13';
        faceDoor     = 24:46;
        faceComputer = 1:23;
        thedata = data;
        data = reshape(cat(1,data{:}),size(data));
        data = reshape({data.optical_heading},size(data));
        data = cellfun(@(x) permute(x,[3 2 1]),data,'uni',false);
        data = reshape(cat(1,data{:}),size(data,1),size(data,2),[]);
        data(35,:,:) = []; % unneeded extra measurement
        qCheckMissingData = false;
        qFixPPT = true;
        clim = [1.54 1.57];
end

if ~isdir(fullfile(cd,'..','results'))
    mkdir(fullfile(cd,'..','results'));
end
if ~isdir(fullfile(cd,resultDir))
    mkdir(fullfile(cd,resultDir));
end

if qFixPPT
    % PPT coordinate frame was -90 degrees rotated, fixup
    temp = data(:,:,3);
    data(:,:,3) = -data(:,:,1);
    data(:,:,1) = temp;
    % deal with yaw too
    data(:,:,4) = angle(exp(1i*(data(:,:,4)/180*pi))*exp(1i*-pi/2))*180/pi;
    
    % yaw is messed up sometimes, probably because ppt marker identities
    % changed... fix. faceComputer should be around yaw -90, faceDoor
    % should be around +90 (after above qRot90 block)
    for p=1:size(data,1)
        if ismember(p,faceComputer)
            goal = -90;
        else
            goal = 90;
        end
        
        if abs(goal-mean(data(p,:,4)))>90
            % rotate 180 degrees
            data(p,:,4) = angle(exp(1i*(data(p,:,4)/180*pi))*exp(1i*pi))*180/pi;
        end
    end
    
    % ppt markers were placed offset from foot, correct for that. for
    % facing direction of the whole setup, this was translation along the X
    % axis.
    offMag = 0.26; % center of two PPT markers was this far behind center of foot
    for p=1:size(data,1)
        % as intersense returns practically unchanging yaw when static,
        % just take mean 
        yaw = mean(data(p,:,4));
        off = [cosd(yaw) -sind(yaw); sind(yaw) cosd(yaw)]*[0;-offMag];
        data(p,:,1) = data(p,:,1)+off(1);
        data(p,:,3) = data(p,:,3)-off(2);
    end
end


a=squeeze(mean(data,2));
% check where measured values do not change. just choose some arbitrary
% samples, should be fine. If values exactly constant: track loss
if qCheckMissingData
    qHaveData = ~all(data(:,1,:)==data(:,34,:) & data(:,15,:)==data(:,45,:),3);
    assert(all(qHaveData));
end

% get offsets so that mean offset from grid is zero. That is after all
% arbitrary
[gridx,gridz] = meshgrid(-2:2,2:-1:-2);
% find nearest gridpoint
d = hypot(repmat(a(:,1)+xoff,1,numel(gridx))-repmat(gridx(:)',size(a,1),1),repmat(a(:,3),1,numel(gridz))-repmat(gridz(:)',size(a,1),1));
[~,whichp]=min(d,[],2);
offsets = [gridx(whichp)-a(:,1) gridz(whichp)-a(:,3)];
theOff  = mean(offsets);


% X-Z positions
clf, hold on
for p=1:2
    if p==1
        idx = faceDoor;
        clr = 'bx';
    else
        idx = faceComputer;
        clr = 'r+';
    end
    plot(a(idx,1)+theOff(1),a(idx,3)+theOff(2),clr)
end
xlabel('X (m)');
ylabel('Z (m)');
axis equal
grid on
axis([-2.5 2.5 -3 3])
print([resultDir '\xz.png'],'-dpng','-r300')
% print([resDir '\xz.eps'],'-depsc2')


% height
cm = [0 0 0; DNcolormap2./255];
clear dat mdat
mdat{1}= a(faceDoor,:);
mdat{2}= a(faceComputer,:);
% put numbers in grid
Ycolumn = 2;
gridDat = nan(size(gridx,1),size(gridx,2),2);
for p=1:2
    for d=1:size(mdat{p},1)
        qGrid = round(mdat{p}(d,1)+theOff(1))==gridx & round(mdat{p}(d,3)+theOff(2))==gridz;
        [i1,i2] = find(qGrid);
        gridDat(i1,i2,p) = mdat{p}(d,Ycolumn);
    end
end
% average height over facing directions
gridDat = nanmean(gridDat,3);
fprintf('range of height values:\t%.2f cm\n',(nanmax(gridDat(:))-nanmin(gridDat(:)))*100);

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
if ~isempty(clim)
    ax.CLim = clim;
end
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
print([resultDir '\Y_.png'],'-dpng','-r720')
% print([resDir '\Y_.eps'],'-depsc')


% RMS
idxs = [1 4 2 5 3 6];
clims = zeros(6,2);
clear dat mdat
dat{1} = data(faceDoor,:,:);
mdat{1}= a(faceDoor,:);
dat{2} = data(faceComputer,:,:);
mdat{2}= a(faceComputer,:);
for p=1:length(idxs)
    i = idxs(p);
    
    gridDat = nan(size(gridx,1),size(gridx,2),2);
    for Ycolumn=1:2
        for d=1:size(dat{Ycolumn},1)
            qGrid = round(mdat{Ycolumn}(d,1)+theOff(1))==gridx & round(mdat{Ycolumn}(d,3)+theOff(2))==gridz;
            [i1,i2] = find(qGrid);
            RMS = sqrt(mean(diff(dat{Ycolumn}(d,:,i)).^2));
            gridDat(i1,i2,Ycolumn) = RMS;
        end
    end
    % average RMS over facing directions
    gridDat = nanmean(gridDat,3);
    
    if i<4
        gridDat = gridDat*100;
    end
    
    switch i
        case 1
            datLbl = 'X';
        case 2
            datLbl = 'Y';
        case 3
            datLbl = 'Z';
        case 4
            datLbl = 'yaw';
        case 5
            datLbl = 'pitch';
        case 6
            datLbl = 'roll';
    end
    fprintf('%s\t%.5f\t%.5f\n',datLbl,nanmean(gridDat(:)),nanmedian(gridDat(:)));
    
end

% BCEA ellipses
BCEAarea1   = nan([size(gridx) 2]);
BCEAarea2   = nan([size(gridx) 2]);
BCEAori     = nan([size(gridx) 2]);
BCEAax1     = nan([size(gridx) 2]);
BCEAax2     = nan([size(gridx) 2]);
for p=1:2
    if p==1
        dat = data(faceDoor,:,:);
        mdat= a(faceDoor,:);
        tlbl= 'faceDoor';
    else
        dat = data(faceComputer,:,:);
        mdat= a(faceComputer,:);
        tlbl= 'faceComputer';
    end
    
    % put numbers in grid
    for d=1:size(dat,1)
        qGrid = round(mdat(d,1)+theOff(1))==gridx & round(mdat(d,3)+theOff(2))==gridz;
        [i1,i2] = find(qGrid);
        
        % calculate BCEA (Crossland and Rubin 2002 Optometry and Vision Science)
        stdx = std(dat(d,:,1));
        stdy = std(dat(d,:,3));
        xx   = corrcoef(dat(d,:,1),dat(d,:,3));
        rho  = xx(1,2);
        P    = 0.68; % cumulative probability of area under the multivariate normal
        k    = log(1/(1-P));
        
        BCEAarea1(i1,i2,p) = 2*k*pi*stdx*stdy*sqrt(1-rho.^2)/.01^2;   % area in cm^2
        
        % calculate orientation of the bivariate normal distribution
        % (see
        % https://en.wikipedia.org/wiki/Multivariate_normal_distribution#Geometric_interpretation)
        % or aspect ratio of axes. Note that an axis is half the diameter
        % of ellipse along that direction. Also note that axes have to be
        % scaled by k (log(1/(1-P))) to match value from direct area
        % calculation above
        [v,e]=eig(cov(dat(d,:,1),dat(d,:,3)));
        [~,i]=max(diag(e));
        BCEAori(i1,i2,p) = atan2(v(2,i),v(1,i));
        BCEAax1(i1,i2,p) = sqrt(e(i,i));
        BCEAax2(i1,i2,p) = sqrt(e(3-i,3-i));
        % to check. should closely match BCEAarea
        BCEAarea2(i1,i2,p) = 2*k*BCEAax1(i1,i2,p).*BCEAax2(i1,i2,p)*pi/.01^2;   % area in cm^2
    end
end
fprintf('BCEA\t%.5f\t%.5f\tmm^2\n',nanmean(BCEAarea1(:))*10,nanmedian(BCEAarea1(:))*10);
