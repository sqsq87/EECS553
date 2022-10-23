function [Infosocp,InfoLTR,InfoRTR,InfoLTR2,InfoRTR2] =  getTime_syntheticData(X, y, z, gamma_range, varargin)
rep = 1;
num_gamma = length(gamma_range);
rng(2021);

socp_yes = 1; LTR_yes = 1;RTR_yes = 1;LTR_yes2 = 1;RTR2_yes = 1;

% flatten out
simSpace = [rep, num_gamma];
numSims = prod(simSpace);

time_socp = zeros(numSims,1);time_eig = zeros(numSims,1);
time_LTR = zeros(numSims,1);
time_RTR = zeros(numSims,1); 
time_LTR2 = zeros(numSims,1);
time_RTR2 = zeros(numSims,1); 

optval_socp = zeros(numSims,1);
optval_LTR = zeros(numSims,1);
optval_RTR = zeros(numSims,1);
optval_LTR2 = zeros(numSims,1);
optval_RTR2 = zeros(numSims,1);

   
    
for idx = 1:numSims
        [i, j] = ind2sub(simSpace, idx);
        gamma = gamma_range(j);
         
        if socp_yes
            fprintf('\nDoing socp\n');
            [w_socp, optval_socp(idx), time_socp(idx), time_eig(idx)] = socp_mosek(X , y, z, gamma);
        end
        
        if LTR_yes
            fprintf('\nDoing LTRSR1\n');
            [w_LTR,optval_LTR(idx),time_LTR(idx)] = LTRSR1(X, y, z, gamma);
        end
        
        if LTR_yes2
            fprintf('\nDoing LTRSR2\n');
            [w_LTR2,optval_LTR2(idx),time_LTR2(idx)] = LTRSR2(X, y, z, gamma);
        end
        
        if RTR_yes
           fprintf('\nDoing RTRNewton1\n')
           [w_RTR,optval_RTR(idx),time_RTR(idx)] = RTRNewton1(X, y, z, gamma);
        end  
       
        if RTR2_yes
           fprintf('\nDoing RTRNewton2\n')
           [w_RTR2,optval_RTR2(idx),time_RTR2(idx)] = RTRNewton2(X, y, z, gamma);
        end  
end 
    
Infosocp.timesocp = mean(time_socp); Infosocp.timeeig = mean(time_eig);Infosocp.fval = mean(optval_socp);
InfoLTR.time = mean(time_LTR) ; InfoLTR.fval = mean(optval_LTR);
InfoLTR2.time = mean(time_LTR2) ; InfoLTR2.fval = mean(optval_LTR2);
InfoRTR.time = mean(time_RTR);InfoRTR.fval = mean(optval_RTR);
InfoRTR2.time = mean(time_RTR2);InfoRTR2.fval = mean(optval_RTR2);
    

    
      
    
     






 