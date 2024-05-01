%This function calculates the fitted parameters for the underdamped case of
%the IBK model
clc;
close all;
D=["Thumb","Index","Middle","Ring","Little"];

Par=input("Give the number of the participant you want to examine: ");

%Set the sampling frequency of the motion capture system
if Par==1
    fs=200;
else
fs=150;
end

fn=fs/2;

%Uncomment the following when I am working from my Laptop
I=importfile("Load the moments of inertia from the excel file".xlsx","");

in=input("Specify the digit you are working on: ");
%1 for thumb, 2 for index etc.
Imcp=I.data(27+in,4);
Ipip=I.data(27+in,5);
Idip=I.data(27+in,6);
Ia=I.data(27+in,7);
L=(I.data(in,2)+I.data(in,4)+I.data(in,6))*10^-3;
m1=(I.data(in,8)+I.data(in,9)+I.data(in,10));
Lmcp=I.data(in,4)*10^-3;
Lip=I.data(in,2)*10^-3;
Mmcp=I.data(in,9);
Mip=I.data(in,8);
%Specify the number of frames you want for flexion. 
n=60;

[b,a]=butter(4,15/fn,'low');
[b1,a1]=butter(4,12/fn,'low');


th1f=filtfilt(b,a,th1).*pi/180;
th2f=filtfilt(b,a,th2).*pi/180;
th3f=filtfilt(b1,a1,th3).*pi/180;
% thaf=filtfilt(b1,a1,thq).*pi/180;
tim=zeros(n,1);

for i=2:n
    tim(i)=tim(i-1)+1/fs;
end

[p1,n1]=findpeaks(th1f,'MINPEAKPROMINENCE',15*pi/180);
n1=n1(1:length(n1)-1);

[p2,n2]=findpeaks(th2f,'MINPEAKPROMINENCE',15*pi/180);
n2=n2(1:end-1);
[p3,n3]=findpeaks(th3f,'MINPEAKPROMINENCE',15*pi/180);
n3=n3(1:end-1);
if in==3
 [pa,na]=findpeaks(thaf,'MINPEAKPROMINENCE',1*pi/180);
%[pa,na]=findpeaks(tha,'MINPEAKWIDTH',15);
else

[pa,na]=findpeaks(-thaf,'MINPEAKWIDTH',9);
end
na=na(1:length(na)-1);


B=zeros(length(n1),4);
Km=B;
Bu=B;
Bl=B;
Kmu=B;
Kml=B;
Bpl=B;
Bplu=B;
Bpll=B;
Kpl=B;
Kplu=B;
Kpll=B;


%MCP Joint
for i=1:length(n1)
[B(i,1),Bl(i,1),Bu(i,1),Km(i,1),Kml(i,1),Kmu(i,1),Bpl(i,1),Bpll(i,1),Bplu(i,1),Kpl(i,1),Kpll(i,1),Kplu(i,1)]=calculations(Imcp,tim,n1,i,th1f(n1(i):n1(i)+n-1),'MCP');
end

%PIP Joint
for i=1:length(n2)
[B(i,2),Bl(i,2),Bu(i,2),Km(i,2),Kml(i,2),Kmu(i,2),Bpl(i,2),Bpll(i,2),Bplu(i,2),Kpl(i,2),Kpll(i,2),Kplu(i,2)]=calculations(Ipip,tim,n2,i,th2f(n2(i):n2(i)+n-1),'PIP');
end

%DIP Joint
for i=1:length(n3)
[B(i,3),Bl(i,3),Bu(i,3),Km(i,3),Kml(i,3),Kmu(i,3),Bpl(i,3),Bpll(i,3),Bplu(i,3),Kpl(i,3),Kpll(i,3),Kplu(i,3)]=calculations(Idip,tim,n3,i,th3f(n3(i):n3(i)+n-1),'DIP');
end

%Abduction Joint
for i=1:length(na)
[B(i,4),Bl(i,4),Bu(i,4),Km(i,4),Kml(i,4),Kmu(i,4),Bpl(i,4),Bpll(i,4),Bplu(i,4),Kpl(i,4),Kpll(i,4),Kplu(i,4)]=calculations(Ia,tim,na,i,thaf(na(i):na(i)+n-1));
end