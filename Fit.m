%This function calculates the fitted parameters of the MoCap data of the spring like motion of the digit segments based on the analytical solutions of the IBK model

clc;
close all;

%Set the sampling frequency of the motion capture system
fs=150;


I=importfile("%%%% SPECIFY THE DIRECTORY OF THE EXCEL FILE %%%%%%%%.xlsx","");

b=input("Specify the digit you are working on: ");
%1 for thumb, 2 for index etc.

Imcp=I.data(27+b,4);
Ipip=I.data(27+b,5);
Idip=I.data(27+b,6);
Ia=I.data(27+b,7);


%The 20 Hz frequency was taken from " Biodynamic modeling,
%system identiﬁcation, and variability of multi-ﬁnger movements"
[b1,a1]=butter(4,20/fs,'low');
th1=filtfilt(b1,a1,mcp);
th2=filtfilt(b1,a1,pip);
th3=filtfilt(b1,a1,dip);

%The 5 Hz is taken as the minimum cut off frequency from 
%"Filtering Motion Capture Data for Real-Time Applications"

[b,a]=butter(4,5/fs,'low');
tha=filtfilt(b,a,abd);

th1=th1.*pi/180;
th2=th2.*pi/180;
th3=th3.*pi/180;
tha=tha.*pi/180;

%Specify the number of frames you want for flexion of MCP and PIP joints. 
n=50;

%Specify the number of frames you want for abduction
nab=110;

%Time is the same for flexion trials starting from 0 and ends after n frames
t=zeros(1,n);
for i=2:n
    t(i)=t(i-1)+1/fs;
end

% Specify  the frames for the DIP joint
n3_1=50;

% Time for DIP joint
t3=zeros(1,n3_1);
for i=2:n3_1
    t3(i)=t(i-1)+1/fs;
end

% Time for abduction trials
ta=zeros(1,nab);
for i=2:nab
    ta(i)=ta(i-1)+1/fs;
end

% Identify the peaks of the signals. Chage the values where appropriate!
[p1,n1]=findpeaks(th1,'MINPEAKPROMINENCE',4*pi/180);
[p2,n2]=findpeaks(th2,'MINPEAKPROMINENCE',10*pi/180);
[p3,n3]=findpeaks(th3,'MINPEAKPROMINENCE',13*pi/180);
[pa,na]=findpeaks(-tha,'MINPEAKWIDTH',50); %For the abduction movement since the digit is moved towards the midline (smaller angles) the peaks are the found from the -tha matrix
 

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

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

% MCP Joint
for i=1:length(n1)-1
    
% Update waitbar and message
waitbar(i/length(n1),f,sprintf('Proximal segment data fitting at %d%s',floor((i/length(n1))*100),'%'));
% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
      
% Starting point for underdamped case
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

%DIP Joint
for k=1:length(n3)
% Update waitbar and message
waitbar(k/length(n3),f,sprintf('Distal segment data fitting at %d%s',floor((k/length(n3))*100),'%'));

% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
%Starting point for underdamped case
x0=[th3(n3(k)+n3_1-1) 20 th3(n3(k))-th3(n3(k)+n3_1-1) 0.2 30];
x01=[th3(n3(k)+n3_1-1) 20 th3(n3(k))-th3(n3(k)+n3_1-1)];
[Fit,GoF]=fit(transpose(t3),th3(n3(k):n3(k)+n3_1-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(t3),th3(n3(k):n3(k)+n3_1-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(t3),th3(n3(k):n3(k)+n3_1-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);

if GoF_rmse==GoF.rmse

Ydip(:,k)=Fit(t3);
coef=coeffvalues(Fit);
Bdip(k)=2*Idip*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Idip-Bdip(k)^2)/(2*Idip)};
Kdip(k)=eval(solve(eqn,K));
theqdip(k)=coef(1);
th0dip(k)=coef(3)+theqdip(k);
figure(j+i+k-2)
plot(t3,Fit(t3).*180/pi,t3,th3(n3(k):n3(k)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
elseif GoF_rmse==GoF1.rmse
   
    Ydip(:,k)=Fit1(t3);
coef=coeffvalues(Fit1);
b=coef(2);
c=coef(3);
rf=b*c/(c+(coef(1)-th3(n3(k))));
Kdip(k)=rf*b*Idip;
Bdip(k)=abs(rf+b)*Idip;
theqdip(k)=coef(1);
th0pip(k)=th3(n3(k));
figure(j+i+k-2)
plot(t3,Fit1(t3).*180/pi,t3,th3(n3(k):n3(k)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF1.rmse*180/pi)+" and R^2: "+GoF1.rsquare);
else
    
    Ydip(:,k)=Fit2(t3);
    coef=coeffvalues(Fit2);
    Bdip(k)=2*Idip*coef(2);
    syms K
    eqn={Bdip(k)^2-4*K*Idip==0};
    Kdip(k)=eval(solve(eqn,K));
    theqdip(k)=coef(1);
th0dip(k)=th3(n3(k));
figure(j+i+k-2)
plot(t3,Fit2(t3).*180/pi,t3,th3(n3(k):n3(k)+n3_1-1).*180/pi);
legend("Fitted curve","Data from index "+n3(k));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("DIP joint fit with RMSE: "+(GoF2.rmse*180/pi)+" and R^2: "+GoF2.rsquare);
end
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end

delete(f);

%Create a waitbar functionality
f = waitbar(0,'1','Name','Curve fitting...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

%Abduction Movement
for m=1:length(na)
% Update waitbar and message
waitbar(m/length(na),f,sprintf('Abduction movement data fitting at %d%s',floor((m/length(na))*100),'%'));

% Check for clicked Cancel button
if getappdata(f,'canceling')
    break
end
%Starting point for underdamped case
x0=[tha(na(m)+nab-1) 20 tha(na(m))-tha(na(m)+nab-1) 0.2 40];
x01=[tha(na(m)+nab-1) 20 tha(na(m))-tha(na(m)+nab-1)];
[Fit,GoF]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x0,'ToLFun',10^-8);
[Fit1,GoF1]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun1,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);
[Fit2,GoF2]=fit(transpose(ta),tha(na(m):na(m)+nab-1),fitfun2,'MaxFunEvals',10^6,'MaxIter',10^6,'StartPoint',x01,'ToLFun',10^-8);

GoF_rmse=min([GoF.rmse GoF1.rmse GoF2.rmse]);

if GoF_rmse==GoF.rmse
   
Ya(:,m)=Fit(ta);
coef=coeffvalues(Fit);
Ba(m)=2*Ia*coef(2);
syms K
eqn={abs(coef(5))==sqrt(4*K*Ia-Ba(m)^2)/(2*Ia)};
Ka(m)=eval(solve(eqn,K));
theqa(m)=coef(1);
th0a(m)=coef(3)+theqdip(m);
figure(j+i+k+m-3)
plot(ta,Fit(ta).*180/pi,ta,tha(na(m):na(m)+nab-1).*180/pi);
legend("Fitted curve","Data from index "+na(m));
xlabel("Time (s)");
ylabel("Angle (degrees)");
title("Abduction movement fit with RMSE: "+(GoF.rmse*180/pi)+" and R^2: "+GoF.rsquare);
elseif GoF_rmse==GoF1.rmse
    
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
clear Fit Fit1 Fit2 GoF GoF1 GoF2;
end

delete(f);

disp("Mean MCP K: "+mean(Kmcp)+" +/- "+std(Kmcp));
disp("Mean MCP B: "+mean(Bmcp)+" +/- "+std(Bmcp));
disp("Mean PIP K: "+mean(Kpip)+" +/- "+std(Kpip));
disp("Mean PIP B: "+mean(Bpip)+" +/- "+std(Bpip));
disp("Mean DIP K: "+mean(Kdip)+" +/- "+std(Kdip));
disp("Mean DIP B: "+mean(Bdip)+" +/- "+std(Bdip));
disp("Mean Abduction K: "+mean(Ka)+" +/- "+std(Ka));
disp("Mean Abduction B: "+mean(Ba)+" +/- "+std(Ba));
