qCheckMissingData = true;

switch 22
    case 1
        dat1m = load('..\data\figure 8\1 minute, same pose as cover_uncover_HMD3.mat'); dat1m = dat1m.data;
        data  = load('..\data\figure 8\cover_uncover_HMD3.mat'); data = data.data;
        resultDir    = '..\results\Figure 8';
        xlims = [-0.08 0.08];
        xlims2 = [-1 1];
    case 2
        dat1m = load('..\data\figure 9\1 minute, same pose as cover_uncover_HMD3.mat'); dat1m = dat1m.data;
        data  = load('..\data\figure 9\cover_uncover_HMD1_3.mat'); data = data.data;
        resultDir= '..\results\Figure 9';
        xlims = [-0.08 0.08];
        xlims2 = [-2.5 1];
        
        % remove recording at every other point
        data([1:2:end],:,:) = [];
    case 3
        dat1m = load('..\data\figure 10\1 minute, same pose as cover_uncover_HMD3.mat'); dat1m = dat1m.data;
        data  = load('..\data\figure 10\cover_uncover_HMD3_flying.mat'); data = data.data;
        resultDir= '..\results\Figure 10';
        xlims = [-0.3 0.3];
        xlims2 = [-3.5 3.5];
    case 11
        dat1m = load('..\data\figure 11c\1 minute, same pose as cover_uncover_HMD3.mat'); dat1m = dat1m.data;
        data  = load('..\data\figure 11c\cover_uncover_HMD3_flying.mat'); data = data.data;
        resultDir= '..\results\Figure 11';
        xlims = [-0.3 0.3];
        xlims2 = [-3.5 3.5];
        
    case 21
        dat1m = load('..\data\figure 12c+13c\20170111102356_1min.mat'); dat1m = dat1m.data;
        dat1m = reshape(cat(1,dat1m{:}),size(dat1m));
        dat1m = reshape({dat1m.vive},size(dat1m));
        dat1m = cellfun(@(x) permute(x,[3 2 1]),dat1m,'uni',false);
        dat1m = reshape(cat(1,dat1m{:}),size(dat1m,1),size(dat1m,2),[]);
        
        data = load('..\data\figure 12c+13c\20170111105759_20trials.mat'); data = data.data;
        data = reshape(cat(1,data{:}),size(data));
        t    = reshape(cat(1,data.timeStamp),size(data));
        data = reshape({data.vive},size(data));
        data = cellfun(@(x) permute(x,[3 2 1]),data,'uni',false);
        data = reshape(cat(1,data{:}),size(data,1),size(data,2),[]);
        
        resultDir= '..\results\Figure 12';
        xlims = [-0.3 0.3];
        xlims2 = [-3.5 3.5];
    case 22
        dat1m = load('..\data\figure 12c+13c\20170111102356_1min.mat'); dat1m = dat1m.data;
        dat1m = reshape(cat(1,dat1m{:}),size(dat1m));
        dat1m = reshape({dat1m.optical_heading},size(dat1m));
        dat1m = cellfun(@(x) permute(x,[3 2 1]),dat1m,'uni',false);
        dat1m = reshape(cat(1,dat1m{:}),size(dat1m,1),size(dat1m,2),[]);
        
        yaw = dat1m(:,:,4);
        qTurn = yaw > 90;
        yaw(qTurn) = yaw(qTurn) - 180;
        qTurn = yaw < -90;
        yaw(qTurn) = yaw(qTurn) + 180;
        dat1m(:,:,4) = yaw;
        
        data = load('..\data\figure 12c+13c\20170111105759_20trials.mat'); data = data.data;
        data = reshape(cat(1,data{:}),size(data));
        data = reshape({data.optical_heading},size(data));
        data = cellfun(@(x) permute(x,[3 2 1]),data,'uni',false);
        data = reshape(cat(1,data{:}),size(data,1),size(data,2),[]);
        
        yaw = data(:,:,4);
        qTurn = yaw > 90;
        yaw(qTurn) = yaw(qTurn) - 180;
        qTurn = yaw < -90;
        yaw(qTurn) = yaw(qTurn) + 180;
        data(:,:,4) = yaw;
        % PPT coordinate frame was 90 degrees rotated, fixup
        temp = data(:,:,3);
        data(:,:,3) = -data(:,:,1);
        data(:,:,1) = temp;
        
        temp = dat1m(:,:,3);
        dat1m(:,:,3) = -dat1m(:,:,1);
        dat1m(:,:,1) = temp;
        
        qCheckMissingData = false;
        
        resultDir= '..\results\Figure 13';
        xlims = [-0.3 0.3];
        xlims2 = [-3.5 3.5];
end

if ~isdir(fullfile(cd,'..','results'))
    mkdir(fullfile(cd,'..','results'));
end
if ~isdir(fullfile(cd,resultDir))
    mkdir(fullfile(cd,resultDir));
end
    

a=squeeze(mean(data,2));
% check where measured values do not change. just choose some arbitrary
% samples, should be fine. If values exactly constant: track loss
if qCheckMissingData
    qHaveData = ~all(data(:,1,:)==data(:,34,:),3);
    assert(all(qHaveData))
end


% get mean and range of orientations during 1 minute recording
% remove mean from recording, as we're looking at range and variation
mean1m = squeeze(mean(dat1m,2));
min1m = squeeze(min(dat1m,[],2)) - mean1m;
max1m = squeeze(max(dat1m,[],2)) - mean1m;

% remove mean from recording, as we're looking at range and variation
b = bsxfun(@minus,a,mean(a,1));

idxs = [1 4 2 5 3 6];
figure('Position',[1 41 1536 500])
ntr = size(b,1);
for p=1:length(idxs)
    subplot(3,2,p), hold on
    i = idxs(p);
    if i<4
        patch('XData',[.5 ntr+.5 ntr+.5 .5],'YData',[min1m([i i]).' max1m([i i]).']*100,'FaceColor',.8*ones(3,1),'EdgeColor','none')
        plot(1:ntr,b(:,i)*100,'kx-')
    else
        patch('XData',[.5 ntr+.5 ntr+.5 .5],'YData',[min1m([i i]).' max1m([i i]).'],'FaceColor',.8*ones(3,1),'EdgeColor','none')
        plot(1:ntr,b(:,i),'kx-')
    end
    xlim([.5 ntr+.5])
    if i<4
        ylim(xlims*100)
        if i==1
            ylabel('X (cm)')
        elseif i==2
            ylabel('Y (cm)')
        else
            ylabel('Z (cm)')
            xlabel('trial')
        end
    else
        ylim(xlims2)
        if i==4
            ylabel('yaw (°)')
        elseif i==5
            ylabel('pitch (°)')
        else
            ylabel('roll (°)')
            xlabel('trial')
        end
    end
end
print([resultDir '\offsets.png'],'-dpng','-r300')
% print([resultsDir '\offsets.eps'],'-depsc')
