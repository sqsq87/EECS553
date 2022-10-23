function [Infossdp,Infosocp,InfoLTR,InfoRTR,InfoLTR2,InfoRTR2] =  getTime_realData(X, y, z, gamma,size_range, varargin)
fold = 10;
num_size = length(size_range);
rng(2021);
% nargin = length(varargin);

[m,n] = size(X);
ssdp_yes = 1; socp_yes = 1; LTR_yes = 1;RTR_yes = 1;
LTR_yes2 = 1;RTR2_yes = 1;

% flatten out
time_ssdp = zeros(num_size,1);
time_socp = zeros(num_size,1);time_eig = zeros(num_size,1);
time_LTR = zeros(num_size,1);
time_RTR = zeros(num_size,1); 
time_LTR2 = zeros(num_size,1);
time_RTR2 = zeros(num_size,1); 

optval_ssdp = zeros(num_size,1);
optval_socp = zeros(num_size,1);
optval_LTR = zeros(num_size,1);
optval_RTR = zeros(num_size,1);
optval_LTR2 = zeros(num_size,1);
optval_RTR2 = zeros(num_size,1);

w_ssdp = zeros(n+1,fold);
w_socp = zeros(n+1,fold);
w_LTR = zeros(n+1,fold);
w_LTR2 = zeros(n+1,fold);
w_RTR = zeros(n+1,fold);
w_RTR2 = zeros(n+1,fold);
    

for i = 1:num_size
    
    fprintf('Starting a dataset size m = %d\n',m);
    timessdp = zeros(1, fold);
    timesocp = zeros(1, fold);
    timeeig = zeros(1, fold);
    timeLTR = zeros(1, fold);
    timeRTR = zeros(1, fold);
    timeLTR2 = zeros(1, fold);
    timeRTR2 = zeros(1, fold);
    
    optvalssdp = zeros(1, fold);
    optvalsocp = zeros(1, fold);
    optvalLTR = zeros(1, fold);
    optvalRTR = zeros(1, fold);
    optvalLTR2 = zeros(1, fold);
    optvalRTR2 = zeros(1, fold);
    
    m_curr = size_range(i);
    
    for idx = 1:fold
        ridx = randperm(m,m_curr);
        if ssdp_yes
            fprintf('\nDoing ssdp\n');
            [w_ssdp(:,idx), optvalssdp(idx), timessdp(idx)] = singlesdp_mosek(X(ridx,:) , y(ridx,:), z(ridx,:), gamma);            
        end
         
        if socp_yes
            fprintf('\nDoing socp\n');
            [w_socp(:,idx), optvalsocp(idx), timesocp(idx), timeeig(idx)] = socp_mosek(X(ridx,:) , y(ridx,:), z(ridx,:), gamma);
        end
        
        if LTR_yes
            fprintf('\nDoing LTRSR1\n');
            [w_LTR(:,idx),optvalLTR(idx),timeLTR(idx)] = LTRSR1(X(ridx,:), y(ridx,:), z(ridx,:), gamma);
        end
        
        if LTR_yes2
            fprintf('\nDoing LTRSR2\n');
            [w_LTR2(:,idx),optvalLTR2(idx),timeLTR2(idx)] = LTRSR2(X(ridx,:), y(ridx,:), z(ridx,:), gamma);
        end
        
        if RTR_yes
           fprintf('\nDoing RTRNewton1\n')
           [w_RTR(:,idx),optvalRTR(idx),timeRTR(idx)] = RTRNewton1(X(ridx,:), y(ridx,:), z(ridx,:), gamma);
        end  
       
        if RTR2_yes
           fprintf('\nDoing RTRNewton2\n')
           [w_RTR2(:,idx),optvalRTR2(idx),timeRTR2(idx)] = RTRNewton2(X(ridx,:), y(ridx,:), z(ridx,:), gamma);
        end  
           
    end
    time_ssdp(i,1) = mean(log10(timessdp));time_socp(i,1) = mean(log10(timesocp));time_eig(i,1) = mean(log10(timeeig));
    time_LTR(i,1) = mean(log10(timeLTR));time_LTR2(i,1) = mean(log10(timeLTR2));time_RTR(i,1) = mean(log10(timeRTR));time_RTR2(i,1) = mean(log10(timeRTR2));
    timestd_ssdp(i,1) = std(log10(timessdp));timestd_socp(i,1) = std(log10(timesocp));timestd_eig(i,1) = std(log10(timeeig));
    timestd_LTR(i,1) = std(log10(timeLTR));timestd_LTR2(i,1) = std(log10(timeLTR2));timestd_RTR(i,1) = std(log10(timeRTR));timestd_RTR2(i,1) = std(log10(timeRTR2));
    optval_ssdp(i,1) = mean(optvalssdp);optval_socp(i,1) = mean(optvalsocp);
    optval_LTR(i,1) = mean(optvalLTR);optval_LTR2(i,1) = mean(optvalLTR2);optval_RTR(i,1) = mean(optvalRTR);optval_RTR2(i,1) = mean(optvalRTR2);    
end 
 
Infossdp.fval = optval_ssdp;Infossdp.logtime = time_ssdp;Infossdp.logtimestd = timestd_ssdp;
Infosocp.fval = optval_socp;Infosocp.logtime = time_socp;Infosocp.logtimestd = timestd_socp;Infosocp.logtimeeig = time_eig;Infosocp.logtimestdeig = timestd_eig;
InfoLTR.fval = optval_LTR;InfoLTR.logtime = time_LTR;InfoLTR.logtimestd = timestd_LTR;
InfoLTR2.fval = optval_LTR2;InfoLTR2.logtime = time_LTR2;InfoLTR2.logtimestd = timestd_LTR2;
InfoRTR.fval = optval_RTR;InfoRTR.logtime = time_RTR;InfoRTR.logtimestd = timestd_RTR;
InfoRTR2.fval = optval_RTR2;InfoRTR2.logtime = time_RTR2;InfoRTR2.logtimestd = timestd_RTR2;

     






 