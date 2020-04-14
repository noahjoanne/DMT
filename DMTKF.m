%DMT 
clear all
clc
%% Read in Data
data = readtable('history_data.csv');
%% BIG FOR LOOP
%For each patient
% 
list_patients = string(unique(data.id))
for p = 13:13%length(list_patients)
    
%%
tab = data(:,{'id','date', 'mood', 'enough_history' });
mood= tab.mood(tab.id == list_patients(p)) ;
date = datenum(tab.date(tab.id == list_patients(p)));

%create mood series
series = [date mood];
y = mood;
years = date;

%DF test for nonstationarity H0 = unit root
DF(p) = adftest(y);
%% Make first plot to see series
figure
plot(series(:,1),y)
%% Make sure we start with a non NAN value
len = length(y)
start_i = 1
end_i = len
while isnan(y(start_i))
     start_i = start_i + 1;
end

while isnan(y(end_i))
     end_i = end_i - 1;
end


%continue with new series y(start_i:end)
y = y(start_i:end_i)

%% Parameter estimation
Z=1; 
R=1;
T=1;
% intialise   H Q
theta_ini = [1 1];
% create upper and lower bounds 
lb = [0.00001;0.00001];
ub = [10^7   ;10^7];


% find optimal values for var_eps and var_eta
theta_opt = fmincon(@(theta) - KalmanLogLik_fun(y,R,Z,T,0,0,theta), theta_ini,[],[],[],[],lb,ub) %optimise

%theta_opt = [1 1]; 
%T = theta_opt(1);               %phi
H = theta_opt(1)                %variance of eps
Q = theta_opt(2)                %variance of eta
[LL,theta,v] = KalmanLogLik_fun(y,R,Z,T,0,0,theta_opt);
AIC = 2*3 - 2*LL;
BIC = log(len) *3 - 2*LL;
%% Kalman Filtering 
% start with simple local level model
Z=1; 
R=1;
T=1;
%H=1;
%Q=1;
[a,P,F,v,K] = KalmanFilter_fun(y,H,Q,R,T,Z,0,0)



%% Kalman Smoothing 
L = T - Z * K;
[r,alpha_hat,N,V] = KalmanSmoother_fun(y,a,P,F,v,L,Z,T)

%% Plot results Filtering & Smoothing 
x_axis = years(start_i:end_i)';

%%% Plot results
figure
%subplot(2,1,1)
plot(x_axis(2:end),y(2:end))
hold on 
plot(x_axis(2:end),a(2:end-1))
datetick('x','dd/mm','keepticks','keeplimits')
title(sprintf('Filtered state for  %s',list_patients(p))) 
legend('mood (y)','predicted mood (a)','Location','southeast')
%subplot(2,1,2)
%plot(x_axis(2:end), y(2:end))
%hold on
%plot(x_axis(2:end),alpha_hat(2:end))
%datetick('x','dd/mm','keepticks','keeplimits')
%title(sprintf('Smooted state for patient %s',list_patients(p)))

end