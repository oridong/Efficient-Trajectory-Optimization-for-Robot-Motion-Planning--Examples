function [ lb,ub,bnds ] = bounds( npts,init,target,rob,prob )
% generate control lower bounds and upper bounds
% vel bound +-2, acc bnd +-5, trq bnd j1 +-5, j2 +-5
% jerk bound +- 10, trq change rate +-20
% conlb = [-1e6*ones(6,1);-100*ones(6,1);-200*ones(6,1);-1e6*ones(6,1)];
% conub = [ 1e6*ones(6,1); 100*ones(6,1); 200*ones(6,1); 1e6*ones(6,1)];

% conlb = [[-10;-500;-500;-5;-50;-5];[-10;-500;-500;-5;-50;-5]/1;...
%     ];%[-pi;-pi/4;-pi/3;-pi/10;-pi*0.35;-pi/10]];
% conub = [[ 10; 500; 500; 5; 50; 5];[ 10; 500; 500; 5; 50; 5]/1;...
%     ];%[ pi; pi/2; pi/2; pi/10; pi*0.00; pi/10]];

% conlb = [[-3*3;-280;-280;-3;-40;-1];[-10;-180;-5;-1;-2;-1];...
%     ];
% conub = [[ 3*3; 280; 280; 3; 40; 1];[ 10; 180; 5; 1; 2; 1];...
%     ];

% bounds for velocity, acceleration, jerk, torque, and torque rate
% posinf=[16/18*pi pi/2 8/9/2*pi pi 2/3*pi pi].'; % unrelaxed jnt 3 
posinf=[16/18*pi pi/2 12/9/2*pi pi 2/3*pi pi].'; % relaxed jnt 3 
% posinf=[16/18*pi pi/2 12/9/2*pi pi pi pi].'; % relaxed jnt 3,5 
% possup=[16/18*pi pi/2 23/18*pi pi 5/9*pi pi].';
possup=[17/18*pi pi/2 23/18*pi pi 5/9*pi pi].'; % relaxed jnt 1
% possup=[17/18*pi pi/2 23/18*pi pi pi pi].'; % relaxed jnt 1,5
% more relaxation
posinf=posinf/0.68;
possup=possup/0.68;

% backup
% posinf=[pi/10 pi/2 pi/2 pi/3 pi/2 pi/3].';
% possup=[pi*11/10 pi/2 pi/2 pi/3 pi/3 pi/3].';

% velbnd=2*pi/60*[4000,4000,5000,5000,5000,5000].'./rob.r.G(:)*0.8;% reduced to 80%
velbnd=pi/180*[165 165 175 350 340 520].';
accbnd=2*velbnd;
jerkbnd=2*accbnd;

% velbnd=[0.4418    0.2945    0.2945    0.1473    0.2945    0.1473].';
% accbnd=[0.2203 0.1469 0.1469 0.0734 0.1469 0.0734].';
% jerkbnd=[0.1657    0.1104    0.1104    0.0552    0.1104    0.0552].';

trqbnd=[1396.5,1402.3,382.7,45.2,44.6,32.5].'*0.8;% reduced to 80%
dtrqbnd=15*trqbnd;

limit=1;% of limit of every bound
interpLimit=0.68;% considering interpolation using 20 pnts, addition limit
% interpLimit=0.9;% considering interpolation using 20 pnts, addition limit
% interpLimit=0.7;% considering interpolation using 12 pnts, addition limit
% conlb = -[posinf;velbnd;accbnd;jerkbnd;trqbnd;dtrqbnd]*limit*interpLimit;
% conub =  [possup;velbnd;accbnd;jerkbnd;trqbnd;dtrqbnd]*limit*interpLimit;
conlb = -[posinf;velbnd;trqbnd;dtrqbnd]*limit*interpLimit;
conub =  [possup;velbnd;trqbnd;dtrqbnd]*limit*interpLimit;

bnds = 1000*ones(6,1);% maximum torque and velocity

lb = [kron(ones(npts,1),conlb);...
    init(:);
    zeros(6,1);...
    zeros(6,1);...
    target(:);...
    zeros(6,1);...
    zeros(6,1);...    
    0];
%     zeros(6,1);0];
ub = [kron(ones(npts,1),conub);...
    init(:);
    zeros(6,1);...
    zeros(6,1);...
    target(:);...
    zeros(6,1);...
    zeros(6,1);...    
    100];
%     zeros(6,1);100];

% self collision
lb=[lb;0.0*ones(npts*size(prob.selfmap,2),1)];
ub=[ub;10000*ones(npts*size(prob.selfmap,2),1)];
% wall collision
wlb=[];
wub=[];
for k=1:size(prob.wallmap,2)
    Lind=prob.wallmap(k).ind(1);
    Bind=prob.wallmap(k).ind(2);
    r=prob.br{Lind}(Bind);
    wlb=[wlb;[prob.wall.x(1);prob.wall.y(1);prob.wall.z(1)]+r+0.05];
    wub=[wub;[prob.wall.x(2);prob.wall.y(2);prob.wall.z(2)]-r-0.05];
end
lb=[lb;kron(ones(npts,1),wlb)];
ub=[ub;kron(ones(npts,1),wub)];
% obstacle collision
lb=[lb;0.05*ones(npts*size(prob.obsmap,2),1)];
ub=[ub;10000*ones(npts*size(prob.obsmap,2),1)];

end
