%% Group 14
function  [r,alpha_hat,N,V] = KalmanSmoother_fun(y,a,P,F,v,L,Z,T)

% find length of data vector
len = length(y);

%create missing values vector
mis_y = zeros(1,len);
for i = 1:len
    if isnan(y(i))
        mis_y(i) = 1
    end
end
% intialise vectors/matrices
r = zeros(1,len);
alpha = zeros(1,len);
N = zeros(1,len);
V = zeros(1,len);

% initalise last values of r and N at 0
r(len) = 0;
N(len) = 0;

% Smoothing function, recursing from end till 2
for t = len:-1:2
 if mis_y(t) == 0
        r(t-1) = Z' * (1./F(t)) * v(t) + L(t)' * r(t);
        N(t-1) = Z' * (1./F(t)) * Z + L(t)' * N(t) * L(t);
    elseif mis_y(t) == 1   
        r(t-1) = T * r(t);  
        N(t-1) = L(t)' * N(t) * L(t);
    end    
   
    alpha_hat(t) = a(t) + P(t) * r(t-1);
    V(t) = P(t) - P(t) * N(t-1) * P(t);
end

% create alpha,V(1) seperately as it is not possible in the loop
N0 = Z' * (1./F(1)) * Z + L(1)' * N(1) * L(1);  %
V(1) = P(1) - P(1) * N0 * P(1);                 %
