function dydt=ibk(I1,B,K,theq,t,y)

dydt=zeros(2,1);

dydt(1)=y(2);
dydt(2)=-K*(y(1)-theq)/I1-B*y(2)/I1;
end
