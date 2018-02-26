%sun = satellite(1,[0,0,0],[0,0,0],1.98855*1e30,695700000);
%earth = satellite(2,[149598023000,0,0],[0,29780,0],5.97237*1e24,6371000);

satelittes = {sun,earth};

satelittes.simulate();