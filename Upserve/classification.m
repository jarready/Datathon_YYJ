
clear all;

M=readtable('cateM233.csv');
M0=table2cell(M);
ticket=[M0(:,2) M0(:,9)];
ticket=cell2mat(ticket);
ticket(395,2)=0;
[idxT,CT] = kmeans(ticket(:,2),4);


Idex=[ticket(:,1) idxT];
group=zeros(4);
for k=1:400
for i=1:4
   %area
for j=1:4 %label
      
          if Idex(k,1)==i && Idex(k,2)==j
               group(i,j)=group(i,j)+1;
               
           end
end
           
end
end


%%
M1=cell2mat(table2cell(M));

alcohol=M1(:,3)+M1(:,4)+M1(:,6)+M1(:,7)+M1(:,8);
total=M1(:,3)+M1(:,4)+M1(:,5)+M1(:,6)+M1(:,7)+M1(:,8);
alcofood=[alcohol M1(:,5)];
alcofood(279,2)=(sum(M1(:,5))-alcofood(279,2)-alcofood(218,2)-alcofood(340,2)-alcofood(357,2)-alcofood(395,2))/395;
alcofood(218,2)=alcofood(279,2);
alcofood(340,2)=alcofood(279,2);
alcofood(357,2)=alcofood(279,2);
alcofood(395,2)=alcofood(279,2);
alcofood(279,1)=(sum(alcohol)-alcofood(279,1))/399;
[idxAF,CAF] = kmeans(alcofood,4);

%scatter(alcofood(:,1),alcofood(:,2))
idx2Region = kmeans(alcofood,5);
figure;
gscatter(alcofood(:,1),alcofood(:,2),idx2Region,...
    [0,0.75,0.75;0.75,0,0.75;0.75,0.75,0],'..');
hold on;

