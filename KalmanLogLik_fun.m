%% Group 14
function  [LL,theta,l] = KalmanLogLik_fun(y,R,Z,T,d,c,theta)

% find length of data vector
len = length(y);

%create missing values vector
mis_y = zeros(1,len);
for i = 1:len
    if isnan(y(i))
        mis_y(i) = 1
    end
end

% initialise a1 and P1 
a(1) = 0;
P(1) = 10^7;

%
%T = theta(1);               %phi
H = theta(1)                %variance of eps
Q = theta(2)                %variance of eta

%% Run Kalman filter
for t = 1:len
        v(t) = y(t) - c - Z * a(t); 
        F(t) = Z * P(t) * Z' + H;
    if mis_y(t) == 0
        K(t) = T * P(t) * Z' * (1/F(t));
        a(t+1) =  d + T * a(t) + K(t) * v(t) ;
    elseif mis_y(t) == 1   
        K(t) = 0;     
        a(t+1) =  d + T * a(t);
    end
        P(t+1) = T * P(t) * T' + R * Q * R' - K(t) * F(t) * K(t)';
        %loglikelihood
        l(t) = - 1/2 * log(2*pi) - 1/2 * log(F(t)) - 1/2 * v(t)^2 / F(t); 
end


%% calculate average loglikelihood, this value will be maximised
LL = nanmean(l(2:end));

