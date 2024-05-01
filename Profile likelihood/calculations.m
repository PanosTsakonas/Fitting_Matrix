function[B,Bl,Bu,Km,Kml,Kmu,Bpl,Bpll,Bplu,Kpl,Kpll,Kplu ]=calculations(I1,tim,n1,i1,th,FF)

fitfun=fittype(@(a,b,c,d,w,x) a+c.*exp(-b.*x).*(d.*sin(w.*x)+cos(w.*x)));%Underdamped

x0=[th(end) 20 th(1)-th(end) 0.2 20];
[Fit,GoF]=fit(tim,th,fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
Ymcp= Fit(tim);
coef=coeffvalues(Fit);
conf=confint(Fit);
B=2*I1*coef(2);
Bu=2*I1*conf(2,2);
Bl=2*I1*conf(1,2);
syms K
eqn={abs(coef(5))==sqrt(4*K*I1-B^2)/(2*I1)};
Km=eval(solve(eqn,K));
eqn={abs(conf(1,5))==sqrt(4*K*I1-Bl^2)/(2*I1)};
Kml=eval(solve(eqn,K));
eqn={abs(conf(2,5))==sqrt(4*K*I1-Bu^2)/(2*I1)};
Kmu=eval(solve(eqn,K));
[~,Yl]=ode45(@(t,y)ibk(I1,Bl,Kml,th(end),t,y),tim,[th(1) 0]);
[~,Yu]=ode45(@(t,y)ibk(I1,Bu,Kmu,th(end),t,y),tim,[th(1) 0]);


%Update the raw IBK model with the new parameters

% Define the new values for init_th1, I1, and theq
new_init_th1 = th(1);  % Example new value for init_th1
new_I1 = I1;        % Example new value for I1
new_theq = th(end);      % Example new value for theq

% Read the content of the .def file
fid = fopen('C:\Users\panos\OneDrive - University of Warwick\PhD\MATLAB Code\arFramework3\Examples\IBK_New\Models\IBK_rev.def', 'r');

% Read the .def file line by line
def_lines = {};
section = '';
while ~feof(fid)
    line = fgetl(fid);
    if startsWith(line, 'INPUTS')
        section = 'INPUTS';
    elseif startsWith(line, 'ODES')
        section = 'ODES';
    elseif startsWith(line, 'CONDITIONS')
        section = 'CONDITIONS';
    end
    switch section
        case 'INPUTS'
            if contains(line, 'Inertia')
                line = sprintf('I1   C   "Kg*m^2" Inertia    "%.8f"', new_I1);
             elseif contains(line, 'theq')
                line = sprintf('theq    C   "rad"     angle    "%.4f"', new_theq);
            end
        case 'CONDITIONS'
            if contains(line, 'init_th1')
                line = sprintf('init_th1      "%.4f"', new_init_th1);
            end
    end
    def_lines{end+1} = line;
end

% Write the modified content back to the .def file
fid = fopen('C:\Users\panos\OneDrive - University of Warwick\PhD\MATLAB Code\arFramework3\Examples\IBK_New\Models\IBK_rev.def', 'w');
if fid == -1
    error('Could not open the file for writing.');
end
fprintf(fid, '%s\n', def_lines{:});
fclose(fid);

T=table(tim,th,'VariableNames',{'time','angle'});
dir="C:\Users\panos\OneDrive - University of Warwick\PhD\MATLAB Code\arFramework3\Examples\IBK_New\Data\";
fN='New_data.csv';
% Export the table to a CSV file in the specified directory
writetable(T, fullfile(dir, fN));

%initialize framework, load model and data 
arInit;
%ar.config.checkForNegFluxes = false;



arLoadModel('IBK_rev');
arLoadData('New_data');
%arLoadData('THUMB_MCP');
% compile model and data 
arCompileAll

% Extend upper parameter boundaries (i.e. parameter search space)
%ar.ub(:)=4;

% set optimizer tolerances
arSetOptimTol;
ar.config.optim.MaxFunEvals = 6*10^8;
ar.config.optim.MaxIter = 6*10^8;
%ar.config.showFitting = true;
% set integrator tolerances
ar.config.rtol = 1e-7;
ar.config.atol = 1e-7;

 %arFitLHS(100,100);
 arFit;
%arPlotFits
% arPlot
arPrint
arQplot('xyv',1);
Res=ar.model.data.res;
Err=ar.model.data.yExpStd;
tim=ar.model.data.tExp;
ts=ar.model.data.tFine;
the=ar.model.data.yExp;
ths=ar.model.data.yFineSimu;
rmse=sqrt(sum((Res).^2)/length(Res));
% arPlot;
% Profile-Likelhood for all parameters
 arPLEInit
%   %Set tolerances
 ar.ple.relchi2stepincrease(5) = 0.01;
 ar.ple.minstepsize(:) = 1e-9; % calculate profiles
 ple(1:3,100000)
%   % plot profiles
% plePlotMulti;
% 
% % plot trajectories along profiles
 arPLETrajectories;
Bpl=10^ar.ple.p(1);
Bpll=10^ar.ple.conf_lb_point(1);
Bplu=10^ar.ple.conf_ub_point(1);
Kpl=10^ar.ple.p(2);
Kpll=10^ar.ple.conf_lb_point(2);
Kplu=10^ar.ple.conf_ub_point(2);
[~,Ypl]=ode45(@(t,y)ibk(I1,Bpl,Kpl,th(end),t,y),tim,[th(1) 0]);
[~,Ypll]=ode45(@(t,y)ibk(I1,Bpll,Kpll,th(end),t,y),tim,[th(1) 0]);
[~,Yplu]=ode45(@(t,y)ibk(I1,Bplu,Kplu,th(end),t,y),tim,[th(1) 0]);

figure
h=zeros(1,3);
h(1)=plot(tim,Fit(tim).*180/pi,'DisplayName','Fitted curve');hold on;
h(2)=plot(tim,th.*180/pi,'DisplayName',"Data from index "+n1(i1));
h(3)=plot(tim,Ypl(:,1).*180/pi,'DisplayName','Profile Likelihood');
legend(h(1:3));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title(FF+" Fit with RMSE: "+round((GoF.rmse*180/pi),3)+" degrees and R^2: "+round(GoF.rsquare,3));
s={['B_{Fit}= ', num2str(round(B, 4)), ' (', num2str(round(Bl, 4)), ',', num2str(round(Bu, 4)), ') Nms/rad'], ...
     ['K_{Fit}= ', num2str(round(Km, 4)), ' (', num2str(round(Kml, 4)), ',', num2str(round(Kmu, 4)), ') Nm/rad']; ...
     ['B_{PLE}= ', num2str(round(Bpl, 4)), ' (', num2str(round(Bpll, 4)), ',', num2str(round(Bplu, 4)), ') Nms/rad'], ...
     ['K_{PLE}= ', num2str(round(Kpl, 4)), ' (', num2str(round(Kpll, 4)), ',', num2str(round(Kplu, 4)), ') Nm/rad']};
           annotation('textbox', [0.45, 0.55, 0.1, 0.1],'String',s,'FitBoxToText','on')
clear Fit Fit1 Fit2 GoF GoF1 GoF2;

end
