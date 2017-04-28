close all

load('..\data\figure 4+5+6+7\facing_door_then_computer.mat');
resultDir    = '..\results\Figure 4+6+7';
faceDoor     = 1:34;
faceComputer = 35:68;

if ~isdir(fullfile(cd,'..','results'))
    mkdir(fullfile(cd,'..','results'));
end
if ~isdir(fullfile(cd,resultDir))
    mkdir(fullfile(cd,resultDir));
end


a=squeeze(mean(data,2));
% check where measured values do not change. just choose some arbitrary
% samples, should be fine. If values exactly constant: track loss
qHaveData = ~all(data(:,1,:)==data(:,34,:) & data(:,15,:)==data(:,45,:),3);
assert(all(qHaveData));

% get offsets so that mean offset from grid is zero. That is after all
% arbitrary
[gridx,gridz] = meshgrid(-3:3,2:-1:-2);
% find nearest gridpoint
d = hypot(repmat(a(:,1),1,numel(gridx))-repmat(gridx(:)',size(a,1),1),repmat(a(:,3),1,numel(gridz))-repmat(gridz(:)',size(a,1),1));
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
axis([-3.5 3.5 -3 3])
axis equal
grid on
print([resultDir '\xz.png'],'-dpng','-r300')
% print([resDir '\xz.eps'],'-depsc2')


% height
cm = [0 0 0; DNcolormap2./255];
clim = [1.8 2.2];
% put numbers in grid
for p=1:2
    q=2;
    if p==1
        idx = faceDoor;
        lbl = 'door';
    else
        idx = faceComputer;
        lbl = 'computer';
    end
    gridDat = nan(size(gridx));
    for d=1:length(idx)
        qGrid = round(a(idx(d),1)+theOff(1))==gridx & round(a(idx(d),3)+theOff(2))==gridz;
        gridDat(qGrid) = a(idx(d),q);
    end
    
    qHasMissing = any(isnan(gridDat(:)));
    if qHasMissing
        step = diff(clim)/(size(cm,1)-1); % last value is for missing data, don't count it here so missing will be neatly mapped to last value in color map
        gridDat(isnan(gridDat)) = clim(1)-step;
    end
    fprintf('range of height values:\t%.2f cm\n',(nanmax(gridDat(:))-nanmin(gridDat(:)))*100);
    
    clf
    imagesc(gridx(1,[1 end]),gridz([1 end],1).',gridDat)
    axis xy
    axis equal
%     axis off
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
%     cb.Ticks = [];
%     cb.Box = 'off';
%     cb.Color = [0.94 0.94 0.94]; % same color as background, otherwise there is a colored line on the side
    print([resultDir '\Y_' lbl '.png'],'-dpng','-r300')
%     print([resDir '\Y_' lbl '.eps'],'-depsc')
end

% RMS, heatmaps
idxs = [1 4 2 5 3 6];
figure('Position',[1 41 836 500])
clims = zeros(6,2);
clear dat mdat
dat{1} = data(faceDoor,:,:);
mdat{1}= a(faceDoor,:);
dat{2} = data(faceComputer,:,:);
mdat{2}= a(faceComputer,:);
for p=1:length(idxs)
    i = idxs(p);
    subplot(3,2,p), hold on
    
    gridDat = nan(size(gridx,1),size(gridx,2),2);
    for q=1:2
        for d=1:size(dat{1},1)
            qGrid = round(mdat{q}(d,1)+theOff(1))==gridx & round(mdat{q}(d,3)+theOff(2))==gridz;
            [i1,i2] = find(qGrid);
            RMS = sqrt(mean(diff(dat{q}(d,:,i)).^2));
            gridDat(i1,i2,q) = RMS;
        end
    end
    % average RMS over facing directions
    gridDat = nanmean(gridDat,3);
    
    pgridDat = gridDat;
    qHasMissing = any(isnan(gridDat(:)));
    if qHasMissing
        step = diff(clim)/(size(cm,1)-1); % last value is for missing data, don't count it here so missing will be neatly mapped to last value in color map
        pgridDat(isnan(pgridDat)) = clim(1)-step;
    end
    if i<4
        gridDat = gridDat*100;
        pgridDat= pgridDat*100;
    end
    
    imagesc(gridx(1,[1 end]),gridz([1 end],1).',pgridDat)
    % determine coloring of plot
    if qHasMissing
        colormap(cm);
    else
        colormap(cm(2:end,:));
    end
    clims(i,:) = get(gca,'CLim');
    % other make-up
    if i<4
        if i==1
            datLbl = 'X';
            ylabel('X (m)')
        elseif i==2
            datLbl = 'Y';
            ylabel('Y (m)')
        else
            datLbl = 'Z';
            ylabel('Z (m)')
            xlabel('X (m)');
        end
    else
        if i==4
            datLbl = 'yaw';
            ylabel('yaw (°)')
        elseif i==5
            datLbl = 'pitch';
            ylabel('pitch (°)')
        else
            datLbl = 'roll';
            ylabel('roll (°)')
            xlabel('X (m)');
        end
    end
    fprintf('%s\t%.5f\t%.5f\n',datLbl,nanmean(gridDat(:)),nanmedian(gridDat(:)));
    
    axis xy
    axis equal
%     axis off
    ax=gca;
    ax.XTick = sort(gridx(1,1:end));
    ax.YTick = sort(gridz(1:end,1));
    ax=gca;
    ax.CLim = [0 0.02];
    cb=colorbar;
%     cb.Ticks = [];
%     cb.Box = 'off';
%     cb.Color = [0.94 0.94 0.94]; % same color as background, otherwise there is a colored line on the side
end
print([resultDir '\RMS_all.png'],'-dpng','-r300')
% print([resDir '\RMS_all.eps'],'-depsc')

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
        % to check. should closely match BCEAarea1 from above
        BCEAarea2(i1,i2,p) = 2*k*BCEAax1(i1,i2,p).*BCEAax2(i1,i2,p)*pi/.01^2;   % area in cm^2
    end
end
fprintf('BCEA\t%.5f\t%.5f\tmm^2\n',nanmean(BCEAarea1(:))*10,nanmedian(BCEAarea2(:))*10);

t = linspace(0,2*pi);
scaleFac = 320; % same for all plots, so easier to compare if needed
for p=1:2
    clf, hold on
    if p==1
        tlbl= 'door';
    else
        tlbl= 'computer';
    end
    for z=1:size(BCEAori,1)
        for x=1:size(BCEAori,2)
            % draw ellipse
            if isnan(BCEAori(z,x,p))
                continue;
            end
            X = gridx(z,x) + scaleFac*k*BCEAax1(z,x,p).*cos(t).*cos(BCEAori(z,x,p)) - scaleFac*k*BCEAax2(z,x,p).*sin(t).*sin(BCEAori(z,x,p));
            Y = gridz(z,x) + scaleFac*k*BCEAax1(z,x,p).*cos(t).*sin(BCEAori(z,x,p)) + scaleFac*k*BCEAax2(z,x,p).*sin(t).*cos(BCEAori(z,x,p));
            plot(X,Y,'k-');
        end
    end
    
    % indicate 1 mm
    plot([3.3 3.3],[0 0.001*scaleFac],'r-')
    
    % other make-up
    xlabel('X (m)');
    ylabel('Z (m)');
    axis([-3.5 3.5 -3 3])
    axis equal
    print([resultDir '\BCEA ellipses_' tlbl '.png'],'-dpng','-r300')
%     print([resDir '\BCEA ellipses_' tlbl '.eps'],'-depsc')
end
