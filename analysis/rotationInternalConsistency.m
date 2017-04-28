close all
clear all

% load in data
load('..\data\figure 4+5+6+7\facing_door_then_computer.mat');
resultDir    = '..\results\Figure 5';
% two corner positions are missing too as track would have been lost there
faceDoor     = 1:34;
faceComputer = 35:68;
Ytruth      = 1.65;
plotYMult   = 2;

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

% note that i swap the X and Y axes in all the below to match convention of
% matlab's rotm2eul
XYZ = a(:,[2 1 3]);


% get rigid rotation to go from physical space to Vive's space
XYZb = [Ytruth*ones(size(XYZ,1),1) round(XYZ(:,2)) round(XYZ(:,3))];
[R,t] = rigid_transform_3D(XYZb,XYZ);


% compute pitch and roll when looking over the titled plane at a certain
% yaw angle
% NB: vizard Euler angles are yaw, pitch, roll, so we're good
out = zeros(size(a,1),3);
for p=1:size(a,1)
    % get yaw rotation matrix
    g = a(p,4)/180*pi;
    [ct,st] = deal(cos(-g),sin(-g));
    m = [ct -st 0; ...
        st  ct 0; ...
        0   0 1];
    
    % multiply together to get new orientation
    Rm = R*m;
    
    % read out pitch and roll
    out(p,1:3) = rotm2eul(Rm,'ZYX');
end
out = out*180/pi;



% plot results

% note that i swap the X and Y axes in all the below to match convention of
% matlab's rotm2eul
XYZ = a(:,[3 1 2]);


% get rigid rotation to go from physical space to Vive's space
XYZb = [round(XYZ(:,1)) round(XYZ(:,2)) Ytruth*ones(size(XYZ,1),1)];
[R,t,qReflectionDetected] = rigid_transform_3D(XYZb,XYZ);


% plot the fit
figure('Position',[1 41 1536 755.2000]),
ax=subplot(4,4,[1:2 5:6 9:10 13:14]); hold on
v_1 = R(:,[1 2]);     % two unit vectors spanning the plane
n_1 = R(:,3);       % normal of the plane
p_1 = mean(XYZ);    % center of the plane

% plot data
ap=plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3)*plotYMult,'b.','MarkerSize',10);

% plot the center of the plane
% plot3(p_1(1),p_1(2),p_1(3)*plotYMult,'ro','markersize',5,'markerfacecolor','red');

% plot the normal vector
% quiver3(p_1(1),p_1(2),p_1(3)*plotYMult,n_1(1)/3,n_1(2)/3,n_1(3)/3*plotYMult,'r','linewidth',2)

[S1,S2] = meshgrid(unique(XYZb(:,1)),unique(XYZb(:,2)));
% generate the point coordinates
X = p_1(1)+[S1(:) S2(:)]*v_1(1,:)';
Y = p_1(2)+[S1(:) S2(:)]*v_1(2,:)';
Z = p_1(3)+[S1(:) S2(:)]*v_1(3,:)';
% plot the plane
surf(reshape(X,size(S1)),reshape(Y,size(S1)),reshape(Z,size(S1))*plotYMult,'facecolor','r','facealpha',0.5);
% plot the measurement plane
surf(S1,S2,Ytruth*ones(size(S1))*plotYMult,'facecolor','g','facealpha',0.5);

xlabel('z');
ylabel('x');
zlabel('y');
ax.XDir = 'reverse';
axis equal
view(90-39.5,9)
lims = axis;
axis([lims(1:4) Ytruth*plotYMult lims(6)]);
t = ax.ZTick;
ax.ZTickLabel = t/plotYMult;

ax=subplot(4,4,[7 11]); hold on
off = mean(a(:,5:6));
plot([-5 5],[-5 5],'k--')
if qReflectionDetected
    rfac = -1;
else
    rfac = 1;
end
plot(out(:,2),rfac*(a(:,5)-off(1)),'.')
q1 = out(:,2)<0;
plot(mean(out( q1,2)),rfac*(mean(a( q1,5))-off(1)),'kx','MarkerSize',10,'LineWidth',2)
plot(mean(out(~q1,2)),rfac*(mean(a(~q1,5))-off(1)),'kx','MarkerSize',10,'LineWidth',2)
xlabel('expected')
ylabel('observed')
ax.XTick = -5:2.5:5;
ax.YTick = -5:2.5:5;
ax.Units = 'pixels';
sz = ax.Position;
ax.Position = sz([1:3 3]);
title('pitch')
ax=subplot(4,4,[8 12]); hold on
plot([-5 5],[-5 5],'k--')
plot(out(:,3),a(:,6)-off(2),'.')
q2 = out(:,3)<0;
assert(all(q1==q2)||all(xor(q1,q2)))
plot(mean(out( q2,3)),mean(a( q2,6))-off(2),'kx','MarkerSize',10,'LineWidth',2)
plot(mean(out(~q2,3)),mean(a(~q2,6))-off(2),'kx','MarkerSize',10,'LineWidth',2)
xlabel('expected')
ylabel('observed')
ax.XTick = -5:2.5:5;
ax.YTick = -5:2.5:5;
ax.Units = 'pixels';
sz = ax.Position;
ax.Position = sz([1:3 3]);
title('roll')

print([resultDir '\rotConsistency.png'],'-dpng','-r300')
% print([resDir '\rotConsistency.eps'],'-depsc','-painters')
