clc
close all
clear all 
ts=0.01;

epsilon=0.1;
%% Reference
Data = readtable('./Data/BLOC101.csv');
indici_righe_da_rimuovere = [4501:length(Data.Var1)];
Data(indici_righe_da_rimuovere, :) = [];
T.Var3=Data.HAN1;
T.Var4=Data.Var9;
T.Var5=Data.Var10;
traj_ref_x = T.Var3(565:756);
traj_ref_y = T.Var4(565:756);
traj_ref_z=  T.Var5(565:756);
reference=[traj_ref_x, traj_ref_y,traj_ref_z];
rangePre=0;
rangePost=length(reference)-1;
%% Trajectory
Data = readtable('./Data/BLOC103.csv');
indici_righe_da_rimuovere = [4400:length(Data.Var1)];
Data(indici_righe_da_rimuovere, :) = [];

T.Var3=Data.HAN1;
T.Var4=Data.Var9;
T.Var5=Data.Var10;
trajectory=[T.Var3';T.Var3';T.Var5']';
meanTrajectory = mean(trajectory);
centeredTrajectory = trajectory - meanTrajectory;
[coeff, score, latent] = pca(centeredTrajectory);
principalComponent1 = score(:, 1);
check=diff(principalComponent1);
slope=mean(check(1:15));
if slope < 0
    principalComponent1=principalComponent1*-1;
end
phase=unwrap(angle(hilbert(principalComponent1)));
Vx=diff(T.Var3);
Vy=diff(T.Var4);
Vz=diff(T.Var5);
NormV=sqrt(Vx.^2+Vy.^2+Vz.^2);
gamma=2;
localMinLogical = islocalmin(NormV);
belowAlphaLogical = NormV < gamma;
combinedLogical = localMinLogical & belowAlphaLogical;
filteredMinIndices = find(combinedLogical);
firstIndexGreaterThan100 = find(filteredMinIndices > 100, 1);
indici_righe_da_rimuovere = 1:filteredMinIndices(firstIndexGreaterThan100+10);
T.Var3(indici_righe_da_rimuovere, :) = [];
T.Var4(indici_righe_da_rimuovere, :) = [];
T.Var5(indici_righe_da_rimuovere, :) = [];
phase(indici_righe_da_rimuovere, :) = [];
phase=phase-phase(1);
phase=wrapTo2Pi(phase);
T.Var2=(0:0.01:(length(T.Var5)-1)/100)';
Time=(length(T.Var5)-1)*ts;
tsX=timeseries(T.Var3,T.Var2);
tsY=timeseries(T.Var4,T.Var2);
tsZ=timeseries(T.Var5,T.Var2);

