%This function calculates the fitted parameters for the underdamped case of
%the IBK model
clc;
close all;
D=["Thumb","Index","Middle","Ring","Little"];


%Set the sampling frequency of the motion capture system

fs=.......................;

%Nyquist frequency
fn=fs/2;

%Add the repository of the Template_Hand_Mass_and_Moments_of_Inertia.xlsx
I=importfile("C:\Users\.....................\Template_Hand_Mass_and_Moments_of_Inertia".xlsx","");


in=input("Specify the digit you are working on: ");
%1 for thumb, 2 for index etc.
Imcp=I.data(27+in,4);
Ipip=I.data(27+in,5);
Idip=I.data(27+in,6);
Ia=I.data(27+in,7);
L=(I.data(in,2)+I.data(in,4)+I.data(in,6))*10^-3;
m1=(I.data(in,8)+I.data(in,9)+I.data(in,10));
%Specify the number of frames you want for flexion. 
n=60;

%Specify the number of frames you want for abduction
nab=65;

%Specify the number of frames you want for the dip joint
if in==1
    n3_1=n;
else
n3_1=55;
end



[b1,a1]=butter(4,15/fn,'low');
[bb,aa]=butter(4,12/fn,'low');
if in~=1
th1=filtfilt(b1,a1,mcp);
end
th2=filtfilt(b1,a1,pip);
th3=filtfilt(bb,aa,dip);
tha=filtfilt(bb,aa,abd);

%Convert the angles from degrees to radians
if in~=1
th1=th1.*pi/180;
end
th2=th2.*pi/180;
th3=th3.*pi/180;
tha=tha.*pi/180;



%Time is the same for flexion trials starting from 0 and ends after n frames
t=zeros(1,n);
for i=2:n
    t(i)=t(i-1)+1/fs;
end


t3=zeros(1,n3_1);
for i=2:n3_1
    t3(i)=t3(i-1)+1/fs;
end

%Time for abduction trials
ta=zeros(1,nab);
for i=2:nab
    ta(i)=ta(i-1)+1/fs;
end
%Identify the peaks of the signals
if in~=1
[p1,n1]=findpeaks(th1,'MINPEAKPROMINENCE',15*pi/180);
n1=n1(1:end-1);
else
    n1=1;
end
[p2,n2]=findpeaks(th2,'MINPEAKPROMINENCE',15*pi/180);
n2=n2(1:end-1);
[p3,n3]=findpeaks(th3,'MINPEAKPROMINENCE',11*pi/180);
n3=n3(1:end-1);
if in==3
[pa,na]=findpeaks(tha,'MINPEAKPROMINENCE',1*pi/180);
%[pa,na]=findpeaks(tha,'MINPEAKWIDTH',26);
else

[pa,na]=findpeaks(-tha,'MINPEAKWIDTH',30);
end
na=na(1:end-1);
 

%Specify the fitting equations
fitfun1=fittype(@(a,b,c,x) a+c.*exp(-b.*x)); %Overdamped
fitfun2=fittype(@(a,b,c,x) a+c.*exp(-b.*x).*(1+b.*x)); %Critically damped
fitfun=fittype(@(a,b,c,d,w,x) a+c.*exp(-b.*x).*(d.*sin(w.*x)+cos(w.*x)));%Underdamped

%Set the tables for the parameters
Bmcp=zeros(1,length(n1));
Bpip=zeros(1,length(n2));
Bdip=zeros(1,length(n3));
Ba=zeros(1,length(na));
Kmcp=Bmcp;
Kpip=Bpip;
Kdip=Bdip;
Ka=Ba;
theqmcp=Kmcp;
theqpip=Kpip;
theqdip=Kdip;
theqa=Ka;
th0mcp=Kmcp;
th0pip=Kpip;
th0dip=Kdip;
th0a=Ka;
Ymcp=zeros(n,length(n1));
Ypip=zeros(n,length(n2));
Ydip=zeros(n3_1,length(n3));
Ya=zeros(nab,length(na));

try
%If you are working on the thumb
if in==1
 
 %Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

%MCP Joint
for i=1:length(n2)
    
% Update waitbar and message
waitbar(i/length(n2),f,sprintf('Middle thumb segment data fitting at %d%s',floor((i/length(n2))*100),'%'));
% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
      
%Starting point for underdamped case
x0=[th2(n2(i)+n-1) 20 th2(n2(i))-th2(n2(i)+n-1) 0.2 10];
[Fit,GoF]=fit(transpose(t),th2(n2(i):n2(i)+n-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
Ymcp(:,i)= Fit(t);
coef=coeffvalues(Fit);
Bmcp(i)=2*Ipip*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Ipip-Bmcp(i)^2)/(2*Ipip)};
Kmcp(i)=eval(solve(eqn,K));
theqmcp(i)=coef(1);
th0mcp(i)=coef(3)+theqmcp(i);
figure(i)
plot(t,Fit(t).*180/pi,t,th2(n2(i):n2(i)+n-1).*180/pi);
legend("Fitted curve","Data from index "+n2(i));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("MCP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end


delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);
if isempty(i)==1
    i=1;
end
%IP Joint
for j=1:length(n3)
% Update waitbar and message
waitbar(j/length(n3),f,sprintf('Distal thumb segment data fitting at %d%s',floor((j/length(n3))*100),'%'));
    
% Check for clicked Cancel button
if getappdata(f,'canceling')
 break
end

%Starting point for underdamped case
x0=[th3(n3(j)+n3_1-1) 30 th3(n3(j))-th3(n3(j)+n3_1-1) 0.2 20];
x01=[th3(n3(j)+n3_1-1) 30 th3(n3(j))-th3(n3(j)+n3_1-1)];
[Fit,GoF]=fit(transpose(t3),th3(n3(j):n3(j)+n3_1-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(t3),th3(n3(j):n3(j)+n3_1-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(t3),th3(n3(j):n3(j)+n3_1-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);
if GoF_rmse==GoF.rmse
   % disp("Underdamped case");
Ypip(:,j)=Fit(t3);
coef=coeffvalues(Fit);
Bpip(j)=2*Idip*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Idip-Bpip(j)^2)/(2*Idip)};
Kpip(j)=eval(solve(eqn,K));
theqpip(j)=coef(1);
th0pip(j)=coef(3)+theqpip(j);
figure(j+i-1)
plot(t3,Fit(t3).*180/pi,t3,th3(n3(j):n3(j)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("IP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
elseif GoF_rmse==GoF1.rmse
    %disp("Overdamped Case");
    Ypip(:,j)=Fit1(t3);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-th3(n3(j))));
Kpip(j)=rf*b*Idip;
Bpip(j)=abs(rf+b)*Idip;
theqpip(j)=coef(1);
th0pip(j)=th2(n3(j));
figure(j+i-1)
plot(t3,Fit1(t3).*180/pi,t3,th3(n3(j):n3(j)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("IP joint fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
    %disp("Critically damped case");
    Ypip(:,j)=Fit2(t3);
    coef=coeffvalues(Fit2);
    Bpip(j)=2*Idip*coef(2);
    syms K
    eqn={Bpip(j)^2-4*K*Idip==0};
    Kpip(j)=eval(solve(eqn,K));
    theqpip(j)=coef(1);
th0pip(j)=th3(n3(j));
figure(j+i-1)
plot(t3,Fit2(t3).*180/pi,t3,th3(n3(j):n3(j)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("IP joint fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end
delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);
if isempty(i)==1
    i=1;
end
if isempty(j)==1
    j=1;
end

%Thumb Abduction
for k=1:length(na)
% Update waitbar and message
waitbar(k/length(na),f,sprintf('Thumb abduction data fitting at %d%s',floor((k/length(na))*100),'%'));

% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
%Starting point for underdamped case
x0=[tha(na(k)+nab-1) 20 tha(na(k))-tha(na(k)+nab-1) 0.2 10];
x01=[tha(na(k)+nab-1) 20 tha(na(k))-tha(na(k)+nab-1)];
[Fit,GoF]=fit(transpose(ta),tha(na(k):na(k)+nab-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(ta),tha(na(k):na(k)+nab-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(ta),tha(na(k):na(k)+nab-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);

if GoF_rmse==GoF.rmse
    coe=coeffvalues(Fit);

    if coe(2)<0
        GoF=min([GoF1.rmse GoF2.rmse]);
      if GoF==GoF1.rmse
   % disp("Overdamped Case");
    Ya(:,k)=Fit1(ta);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-tha(na(k))));
Ka(k)=rf*b*Ia;
Ba(k)=abs(rf+b)*Ia;
theqa(k)=coef(1);
th0a(k)=tha(na(k));
figure(j+i+k-2)
plot(ta,Fit1(ta).*180/pi,ta,tha(na(k):na(k)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Thumb abduction fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
    %disp("Critically damped case");
    Ya(:,k)=Fit2(ta);
    coef=coeffvalues(Fit2);
    Ba(k)=2*Ia*coef(2);
    syms K
    eqn={Ba(k)^2-4*K*Ia==0};
    Ka(k)=eval(solve(eqn,K));
    theqa(k)=coef(1);
th0a(k)=tha(na(k));
figure(j+i+k-2)
plot(ta,Fit2(ta).*180/pi,ta,tha(na(k):na(k)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Thumb abduction fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
      end
    else
%disp("Underdamped Case");
Ya(:,k)=Fit(ta);
coef=coeffvalues(Fit);
Ba(k)=2*Ia*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*(K)*Ia-Ba(k)^2)/(2*Ia)};
Ka(k)=eval(solve(eqn,K));
theqa(k)=coef(1);
th0a(k)=coef(3)+theqa(k);
figure(j+i+k-2)
plot(ta,Fit(ta).*180/pi,ta,tha(na(k):na(k)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Thumb abduction fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
    end
elseif GoF_rmse==GoF1.rmse
   
   % disp("Overdamped Case");
    Ya(:,k)=Fit1(ta);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-tha(na(k))));
Ka(k)=rf*b*Ia;
Ba(k)=abs(rf+b)*Ia;
theqa(k)=coef(1);
th0a(k)=tha(na(k));
figure(j+i+k-2)
plot(ta,Fit1(ta).*180/pi,ta,tha(na(k):na(k)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Thumb abduction fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
    else
    %disp("Critically damped case");
    Ya(:,k)=Fit2(ta);
    coef=coeffvalues(Fit2);
    Ba(k)=2*Ia*coef(2);
    syms K
    eqn={Ba(k)^2-4*K*Ia==0};
    Ka(k)=eval(solve(eqn,K));
    theqa(k)=coef(1);
th0a(k)=tha(na(k));
figure(j+i+k-2)
plot(ta,Fit2(ta).*180/pi,ta,tha(na(k):na(k)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Thumb abduction fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end

clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end

delete(f);

disp("Mean MCP K: "+mean(Kmcp)+" +/- "+std(Kmcp));
disp("Mean MCP B: "+mean(Bmcp)+" +/- "+std(Bmcp));
disp("Mean IP K: "+mean(Kpip)+" +/- "+std(Kpip));
disp("Mean IP B: "+mean(Bpip)+" +/- "+std(Bpip));
disp("Mean Abduction K: "+mean(Ka)+" +/- "+std(Ka));
disp("Mean Abduction B: "+mean(Ba)+" +/- "+std(Ba));

%Calculating the damping ratios of the thumb
zmcp=Bmcp./(2*Ipip.*sqrt(Kmcp./Ipip));
zip=(Bpip)./(2*Idip.*sqrt(Kpip./Idip));
za=(Ba)./(2*Ia.*sqrt(Ka./Ia));
disp("For participant "+Par+" the parameters for the thumb digit are:");
disp("Damping ratio of MCP joint: "+mean(zmcp)+" +/- "+std(zmcp));
disp("Damping ratio of IP joint: "+mean(zip)+" +/- "+std(zip));
disp("Damping ratio of abduction: "+mean(za)+" +/- "+std(za));

else 
%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

%MCP Joint
for i=1:length(n1)
    
% Update waitbar and message
waitbar(i/length(n1),f,sprintf('Proximal segment data fitting at %d%s',floor((i/length(n1))*100),'%'));
% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
      
%Starting point for underdamped case
x0=[th1(n1(i)+n-1) 20 th1(n1(i))-th1(n1(i)+n-1) 0.2 10];
[Fit,GoF]=fit(transpose(t),th1(n1(i):n1(i)+n-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
Ymcp(:,i)= Fit(t);
coef=coeffvalues(Fit);
Bmcp(i)=2*Imcp*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Imcp-Bmcp(i)^2)/(2*Imcp)};
Kmcp(i)=eval(solve(eqn,K));
theqmcp(i)=coef(1);
th0mcp(i)=coef(3)+theqmcp(i);
figure(i)
plot(t,Fit(t).*180/pi,t,th1(n1(i):n1(i)+n-1).*180/pi);
legend("Fitted curve","Data from index "+n1(i));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("MCP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end


delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

if isempty(i)==1
    i=1;
end

%PIP Joint
for j=1:length(n2)
% Update waitbar and message
waitbar(j/length(n2),f,sprintf('Middle segment data fitting at %d%s',floor((j/length(n2))*100),'%'));
    
% Check for clicked Cancel button
if getappdata(f,'canceling')
 break
end

%Starting point for underdamped case
x0=[th2(n2(j)+n-1) 30 th2(n2(j))-th2(n2(j)+n-1) 0.2 20];
x01=[th2(n2(j)+n-1) 30 th2(n2(j))-th2(n2(j)+n-1)];
[Fit,GoF]=fit(transpose(t),th2(n2(j):n2(j)+n-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(t),th2(n2(j):n2(j)+n-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(t),th2(n2(j):n2(j)+n-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);
if GoF_rmse==GoF.rmse
   % disp("Underdamped case");
Ypip(:,j)=Fit(t);
coef=coeffvalues(Fit);
Bpip(j)=2*Ipip*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Ipip-Bpip(j)^2)/(2*Ipip)};
Kpip(j)=eval(solve(eqn,K));
theqpip(j)=coef(1);
th0pip(j)=coef(3)+theqpip(j);
figure(j+i-1)
plot(t,Fit(t).*180/pi,t,th2(n2(j):n2(j)+n-1).*180/pi);
legend("Fitted curve","Data from index "+n2(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("PIP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
elseif GoF_rmse==GoF1.rmse
    %disp("Overdamped Case");
    Ypip(:,j)=Fit1(t);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-th2(n2(j))));
Kpip(j)=rf*b*Ipip;
Bpip(j)=abs(rf+b)*Ipip;
theqpip(j)=coef(1);
th0pip(j)=th2(n2(j));
figure(j+i-1)
plot(t,Fit1(t).*180/pi,t,th2(n2(j):n2(j)+n-1).*180/pi);
legend("Fitted curve","Data from index "+n2(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("PIP joint fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
    %disp("Critically damped case");
    Ypip(:,j)=Fit2(t);
    coef=coeffvalues(Fit2);
    Bpip(j)=2*Ipip*coef(2);
    syms K
    eqn={Bpip(j)^2-4*K*Ipip==0};
    Kpip(j)=eval(solve(eqn,K));
    theqpip(j)=coef(1);
th0pip(j)=th2(n2(j));
figure(j+i-1)
plot(t,Fit2(t).*180/pi,t,th2(n2(j):n2(j)+n-1).*180/pi);
legend("Fitted curve","Data from index "+n2(j));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("PIP joint fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end
delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

if isempty(i)==1
    i=1;
end

if isempty(j)==1
    j=1;
end

%DIP Joint
for k=1:length(n3)
    
% Update waitbar and message
waitbar(k/length(n3),f,sprintf('Distal segment data fitting at %d%s',floor((k/length(n3))*100),'%'));

% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
    nk=[n3(k) 0];

    wn=20;
    %Starting point for underdamped case
x0=[th3(nk(1)+n3_1-1) 20 th3(nk(1))-th3(nk(1)+n3_1-1) 0.2 30];
x01=[th3(nk(1)+n3_1-1) 20 th3(nk(1))-th3(nk(1)+n3_1-1)];
[Fit,GoF]=fit(transpose(t3),th3(nk(1):nk(1)+n3_1-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(t3),th3(nk(1):nk(1)+n3_1-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(t3),th3(nk(1):nk(1)+n3_1-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);




GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);

if GoF_rmse==GoF.rmse
%disp("Underdamped Case");
Ydip(:,k)=Fit(t3);
coef=coeffvalues(Fit);
Bdip(k)=2*Idip*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Idip-Bdip(k)^2)/(2*Idip)};
Kdip(k)=eval(solve(eqn,K));
theqdip(k)=coef(1);
th0dip(k)=coef(3)+theqdip(k);
figure(j+i+k-2)

plot(t3,Fit(t3).*180/pi,t3,th3(nk(1):nk(1)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+nk(1));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
elseif GoF_rmse==GoF1.rmse
   % disp("Overdamped Case");
    Ydip(:,k)=Fit1(t3);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-th3(nk(1))));
Kdip(k)=rf*b*Idip;
Bdip(k)=abs(rf+b)*Idip;
theqdip(k)=coef(1);
th0pip(k)=th3(nk(1));
figure(j+i+k-2)
plot(t3,Fit(t3).*180/pi,t3,th3(nk(1):nk(1)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+nk(1));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
    %disp("Critically damped case");
    Ydip(:,k)=Fit2(t3);
    coef=coeffvalues(Fit2);
    Bdip(k)=2*Idip*coef(2);
    syms K
    eqn={Bdip(k)^2-4*K*Idip==0};
    Kdip(k)=eval(solve(eqn,K));
    theqdip(k)=coef(1);
th0dip(k)=th3(n3(k));
figure(j+i+k-2)

plot(t3,Fit(t3).*180/pi,t3,th3(nk(1):nk(1)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+nk(1));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end
clear Fit Fit1 Fit2 GoF GoF1 GoF2 bm am;
end

delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

if isempty(i)==1
    i=1;
end
if isempty(j)==1
    j=1;
end
if isempty(k)==1
    k=1;
end

%Abduction Movement
for m=1:length(na)
% Update waitbar and message
waitbar(m/length(na),f,sprintf('Abduction movement data fitting at %d%s',floor((m/length(na))*100),'%'));

% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end

x0=[tha(na(m)+nab-1) 15 tha(na(m))-tha(na(m)+nab-1) 0.2 25];
x01=[tha(na(m)+nab-1) 10 tha(na(m))-tha(na(m)+nab-1)];
[Fit,GoF]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);

GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);

if GoF_rmse==GoF.rmse
    coe=coeffvalues(Fit);
   
    if coe(2)<0
        GoF=min([GoF1.rmse, GoF2.rmse]);
        if GoF==GoF1.rmse
    %disp("Lowest RMSE overdamped case");
        Ya(:,m)=Fit1(ta);
        coef=coeffvalues(Fit1);
        b=coef(2);
        c=coef(3);
        rf=b*c/(c+(coef(1)-tha(na(m))));
Ka(m)=rf*b*Ia;
Ba(m)=abs(rf+b)*Ia;
theqa(m)=coef(1);
th0a(m)=tha(na(m));
figure(j+i+k+m-3)
plot(ta,Fit1(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
        %disp("Lowest RMSE critically damped case");
        Ya(:,m)=Fit2(ta);
        coef=coeffvalues(Fit2);
        b=coef(2);
        Ba(m)=2*Ia*b;
        syms K
        eqn={Ba(m)^2-4*K*Ia==0};
        Ka(m)=eval(solve(eqn,K));
        theqa(m)=coef(1);
        th0a(m)=tha(na(m));
        figure(j+i+k+m-3)
plot(ta,Fit2(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
        end
    else
         %disp("Lowest RMSE underdamped case");
Ya(:,m)=Fit(ta);
coef=coeffvalues(Fit);
Ba(m)=2*Ia*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*(K)*Ia-Ba(m)^2)/(2*Ia)};
Ka(m)=eval(solve(eqn,K));
theqa(m)=coef(1);
th0a(m)=coef(3)+theqa(m);
figure(j+i+k+m-3)
plot(ta,Fit(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
clear Fit Fit1 Fit2;
    end
elseif GoF_rmse==GoF1.rmse
     %disp("Lowest RMSE overdamped case");
        Ya(:,m)=Fit1(ta);
        coef=coeffvalues(Fit1);
        b=coef(2);
        c=coef(3);
        rf=b*c/(c+(coef(1)-tha(na(m))));
Ka(m)=rf*b*Ia;
Ba(m)=abs(rf+b)*Ia;
theqa(m)=coef(1);
th0a(m)=tha(na(m));
figure(j+i+k+m-3)
plot(ta,Fit1(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
        %disp("Lowest RMSE critically damped case");
        Ya(:,m)=Fit2(ta);
        coef=coeffvalues(Fit2);
        b=coef(2);
        Ba(m)=2*Ia*b;
        syms K
        eqn={Ba(m)^2-4*K*Ia==0};
        Ka(m)=eval(solve(eqn,K));
        theqa(m)=coef(1);
        th0a(m)=tha(na(m));
        figure(j+i+k+m-3)
plot(ta,Fit2(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end
end


delete(f);
disp("For participant "+Par+" the parameters for the "+D(in)+" finger are:");
disp("Mean MCP K: "+mean(Kmcp)+" +/- "+std(Kmcp));
disp("Mean MCP B: "+mean(Bmcp)+" +/- "+std(Bmcp));
disp("Mean PIP K: "+mean(Kpip)+" +/- "+std(Kpip));
disp("Mean PIP B: "+mean(Bpip)+" +/- "+std(Bpip));
disp("Mean DIP K: "+mean(Kdip)+" +/- "+std(Kdip));
disp("Mean DIP B: "+mean(Bdip)+" +/- "+std(Bdip));
disp("Mean Abduction K: "+mean(Ka)+" +/- "+std(Ka));
disp("Mean Abduction B: "+mean(Ba)+" +/- "+std(Ba));

%Calculating the damping ratios

zmcp=Bmcp./(2*Imcp.*sqrt(Kmcp./Imcp));
zpip=(Bpip)./(2*Ipip.*sqrt(Kpip./Ipip));
zdip=(Bdip)./(2*Idip.*sqrt(Kdip./Idip));
za=(Ba)./(2*Ia.*sqrt(Ka./Ia));

disp("Dampring ratio of MCP joint: "+mean(zmcp)+" +/- "+std(zmcp));
disp("Dampring ratio of PIP joint: "+mean(zpip)+" +/- "+std(zpip));
disp("Dampring ratio of DIP joint: "+mean(zdip)+" +/- "+std(zdip));
disp("Dampring ratio of abduction: "+mean(za)+" +/- "+std(za));
end
catch ME
    delete(f);
    rethrow(ME)
end
