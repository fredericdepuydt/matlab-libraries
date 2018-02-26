g0 = 9.81;
mu = 3.5316*10^12;

R = 600000;
R_vac = 670000;

s0 = [R,0,0];
v0 = [0,0,0];
a = [0,0,0];

w_rot = -174.9425/600000;

SimOut = sim('model', ...
    'ReturnWorkspaceOutputs', 'on', ...
    'MaxStep','1', ...
    'Starttime','0', ...
    'Stoptime','10000');

t = SimOut.get('t');
out = SimOut.get('out');
s=out.signals(1).values;
v=out.signals(2).values;
a=out.signals(3).values;
g=out.signals(4).values;
periapsis=out.signals(5).values;
apoapsis=out.signals(6).values;

s=reshape(s(1,:,:),size(s,2),size(s,3))';
v=reshape(v(1,:,:),size(v,2),size(v,3))';
a=reshape(a(1,:,:),size(a,2),size(a,3))';
g=reshape(g(1,:,:),size(g,2),size(g,3))';

sx = s(:,1);
sy = s(:,2);
sz = s(:,3);
vx = v(:,1);
vy = v(:,2);
vz = v(:,3);
ax = a(:,1);
ay = a(:,2);
az = a(:,3);
gx = g(:,1);
gy = g(:,2);
gz = g(:,3);


figure(1);clf;
%% SUBPLOT 1
subplot(3,1,1);
hold on;
plot(t,sx,'r');
plotyy(t,vx,t,ax);
hold off;

%% SUBPLOT 2
subplot(3,1,2);
hold on;
plot(t,sy,'r');
plot(t,vy,'b');
plot(t,ay,'g');
hold off;

%% SUBPLOT 3
subplot(3,1,3);
hold on;
plot(t,magn(s),'r');
hold off;



[sphereX,sphereY,sphereZ]=sphere;

figure(2);clf;
hold on;
surf(sphereX.*R,sphereY.*R,sphereZ.*R);
plot3(sy,sz,sx,'b');
hold off;
axis([-10000 50000 -10000 10000 595000 800000]);


figure(3);clf;
hold on;
surf(sphereX.*R,sphereY.*R,sphereZ.*R);
plot3(sy,sz,sx,'b');
hold off;
axis([-1000000 1000000 -1000000 1000000 -1000000 1000000]);

figure(4);clf;
hold on;
plot(sy,sx,'b');
hold off;
axis([-1000000 1000000 -1000000 1000000]);

return;


