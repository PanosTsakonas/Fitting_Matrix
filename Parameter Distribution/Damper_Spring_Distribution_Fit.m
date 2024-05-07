clc;
close all;
clear all;

D=["Index","Middle","Ring","Little"];

Kmcp=zeros(23,4);
Bmcp=Kmcp;
Kpip=Kmcp;
Bpip=Kmcp;
Kdip=Kmcp;
Bdip=Kmcp;
Ka=Kmcp;
Ba=Kmcp;

GG=input("Are you working from laptop or uni pc? :",'s');
if GG=='l'
    FF="C:\Users\panos\OneDrive - University of Warwick\PhD\Publication\Parameter estimation of a model describing the human fingers\Supplementary material\Publication Data.xlsx";
else
    FF="C:\Users\u1857308\OneDrive - University of Warwick\PhD\Publication\Parameter estimation of a model describing the human fingers\Supplementary material\Publication Data.xlsx";
end


for i=1:4
I=importfile(FF,D(i));

Kmcp(:,i)=I.data(1:23,1);
Bmcp(:,i)=I.data(1:23,2);
Kpip(:,i)=I.data(1:23,3);
Bpip(:,i)=I.data(1:23,4);
Kdip(:,i)=I.data(1:23,5);
Bdip(:,i)=I.data(1:23,6);
Ka(:,i)=I.data(1:23,7);
Ba(:,i)=I.data(1:23,8);
end

a=0.05;

Data=[Kmcp Kpip Kdip Ka];
CI_m=[];
[~,len]=size(Data);
n=1;
Jo=["MCP","PIP","DIP","Abduction"];
for i=1:len
    
    if (mod(i,4)==1)
        fi="Index";
    elseif (mod(i,4)==2)
        fi="Middle";
    elseif (mod(i,4)==3)
        fi="Ring";
    else
        fi="Little";
    end
    
   
    if i<=4
        J=Jo(1);
    elseif i<=8
        J=Jo(2);
    elseif i<=12
        J=Jo(3);
    else
        J=Jo(4);
    end
    
    [H1,p1]=swtest(Data(:,i),a);
    [H2,p2]=swtest(log(Data(:,i)),a);
    
    if(p2>a|| p1>a)
        if (p2>p1)
           pd=fitdist(Data(:,i),'lognormal');
           flag='log';
        else
            pd=fitdist(Data(:,i),'normal');
            flag='normal';
        end
    
    %Obtain the CI of the parameters
    CI=paramci(pd);
    CI_m=[CI_m,paramci(pd)];
    mu_CI_l=CI(1,1);
    mc_CI_u=CI(2,1);
    s_CI_l=CI(1,2);
    s_CI_u=CI(2,2);
    
    mu=pd.mu;
    s=pd.sigma;
    
    if strcmp(flag,'log')==1
        Mpd=makedist('Lognormal','mu',mu','sigma',s);
        p=p2;
    else
        Mpd=makedist('Normal','mu',mu','sigma',s);
        p=p1;
    end
    
    m=min(Data(:,i));
    M=max(Data(:,i));
    x=linspace(m-m*0.2,M+M*0.2,1000);
    
    figure
    histogram(Data(:,i),7,'Normalization','pdf');
    hold on
    plot(x,pdf(Mpd,x),'LineWidth',0.9);
    xlabel("Torsional Spring (Nm/rad)");
    ylabel("PDF");
    if strcmp(flag,'log')==1
        title("Lognormal PDF for torsional spring data of "+fi+" finger "+J+" joint");
    else
        title("Normal PDF for torsional spring data of "+fi+" finger "+J+" joint");
    end
    s={"\mu= "+mu,"\sigma= "+s,"Shapiro-Wilk test p-value: "+p};
           annotation('textbox', [0.45, 0.55, 0.1, 0.1],'String',s,'FitBoxToText','on')
    
    end
    if(mod(len,4)==0 && n==1)
        n=2;
    elseif (mod(len,4)==0 && n==2)
        n=3;
    elseif (mod(len,4)==0 && n==3)
        n=4;
    end
    clear mu s pd Mpd;
end


Save=input("Do you want to save the figures? :",'s');

if (Save=='Y' || Save=='y')
    if GG=='l'
        sf="C:\Users\panos\OneDrive - University of Warwick\PhD\Thesis\Chapter 6\Distribution Fit\Spring\";
    else
        sf="C:\Users\u1857308\OneDrive - University of Warwick\PhD\Thesis\Chapter 6\Distribution Fit\Spring\";
    end
    for i=1:len
        h=figure(i);
        saveas(h,sf+"figure_"+i,'jpg');
    end
end


Data1=[Bmcp Bpip Bdip Ba];
CI_mB=[];
[~,len1]=size(Data1);
n=1;
Jo=["MCP","PIP","DIP","Abduction"];
for i=1:len1
    
    if (mod(i,4)==1)
        fi="Index";
    elseif (mod(i,4)==2)
        fi="Middle";
    elseif (mod(i,4)==3)
        fi="Ring";
    else
        fi="Little";
    end
    
   
    if i<=4
        J=Jo(1);
    elseif i<=8
        J=Jo(2);
    elseif i<=12
        J=Jo(3);
    else
        J=Jo(4);
    end
    
    [H1,p1]=swtest(Data1(:,i),a);
    [H2,p2]=swtest(log(Data1(:,i)),a);
    
    if(p2>a || p1>a)
        if (p2>p1)
           pd=fitdist(Data1(:,i),'lognormal');
           flag='log';
        else
            pd=fitdist(Data1(:,i),'normal');
            flag='normal';
        end
    
    %Obtain the CI of the parameters
    CI=paramci(pd);
    CI_mB=[CI_mB,paramci(pd)];
    mu_CI_l=CI(1,1);
    mc_CI_u=CI(2,1);
    s_CI_l=CI(1,2);
    s_CI_u=CI(2,2);
    
    mu=pd.mu;
    s=pd.sigma;
    
    if strcmp(flag,'log')==1
        Mpd=makedist('Lognormal','mu',mu','sigma',s);
        p=p2;
    else
        Mpd=makedist('Normal','mu',mu','sigma',s);
        p=p1;
    end
    
    m=min(Data1(:,i));
    M=max(Data1(:,i));
    x=linspace(m-m*0.2,M+M*0.2,1000);
    
    figure
    histogram(Data1(:,i),7,'Normalization','pdf');
    hold on
    plot(x,pdf(Mpd,x),'LineWidth',0.9);
    xlabel("Torsional Damper (Nms/rad)");
    ylabel("PDF");
    if strcmp(flag,'log')==1
        title("Lognormal PDF for torsional damper data of "+fi+" finger "+J+" joint");
    else
        title("Normal PDF for torsional damper data of "+fi+" finger "+J+" joint");
    end
    s={"\mu= "+mu,"\sigma= "+s,"Shapiro-Wilk test p-value: "+p};
           annotation('textbox', [0.45, 0.55, 0.1, 0.1],'String',s,'FitBoxToText','on')
    
    end
    if(mod(len,4)==0 && n==1)
        n=2;
    elseif (mod(len,4)==0 && n==2)
        n=3;
    elseif (mod(len,4)==0 && n==3)
        n=4;
    end
    clear mu s pd Mpd;
end


Save=input("Do you want to save the figures? :",'s');

if (Save=='Y' || Save=='y')
    if GG=='l'
        sf="C:\Users\panos\OneDrive - University of Warwick\PhD\Thesis\Chapter 6\Distribution Fit\Damper\";
    else
        sf="C:\Users\u1857308\OneDrive - University of Warwick\PhD\Thesis\Chapter 6\Distribution Fit\Damper\";
    end
    for i=len+1:len+len1
        h=figure(i);
        saveas(h,sf+"figure_"+i,'jpg');
    end
end

    