%sdp_compare
clear all
clc

% set m, n list, where m = multiple * n
n_list = [10000,15000,20000,25000,30000]';
multiple_list = [0.5,1,2,3];
gamma_list = [1e-1,1e-2];
density_list = [0.0001, 0.001, 0.01]';
% normalization or not
normalize_yes = 0;
% set synthetic data path
path = './datasets/synthetic/sparse_matrix';
% % add path
% addpath('./Krylov method');
% addpath('./ROPTLIB')

for gamma_idx = 1: length(gamma_list)
    gamma = gamma_list(gamma_idx);
    for multiple_idx = 1:length(multiple_list)
        for j = 1:length(density_list)
            density = density_list(j);
            multiple = multiple_list(multiple_idx);
            m_list = multiple * n_list;
            len_m = length(m_list);
            % initial
            time_eig_list = zeros(len_m,1);SOCPtime = zeros(len_m,1); LTRtime = zeros(len_m,1); RTRtime = zeros(len_m,1);LTRtime2 = zeros(len_m,1); RTRtime2 = zeros(len_m,1);
            socpOptval = zeros(len_m,1);LTROptval = zeros(len_m,1);RTROptval = zeros(len_m,1);LTROptval2 = zeros(len_m,1);RTROptval2 = zeros(len_m,1);
            for idx = 1: len_m
                % read data
                m = m_list(idx); n = n_list(idx);
                fprintf('\ndataset size(%d,%d)\n',m,n);               
                % read sparse data: function make_sparse_uncorrelated
                matname = strcat(path,'/m',string(m),'n',string(n),'sparse',string(density),'_Msparse.mat');
                tload = tic;
                load(matname)  
                timeload = toc(tload);
                % creat fake z 
                y_quantile_low = quantile(y,0.25); y_quantile_high = quantile(y,0.75);        
                z = y; z(z<y_quantile_low) = y_quantile_low; 
                %normalization
                if normalize_yes
                    X = normalize(X,'range'); 
                end

                [Infosocp,InfoLTR,InfoRTR,InfoLTR2,InfoRTR2] = getTime_syntheticData(X, y, z, gamma);
                SOCPtime(idx) = Infosocp.timesocp; time_eig_list(idx) = Infosocp.timeeig;LTRtime(idx) = InfoLTR.time; RTRtime(idx) = InfoRTR.time;LTRtime2(idx) = InfoLTR2.time; RTRtime2(idx) = InfoRTR2.time;
                socpOptval(idx) = Infosocp.fval;LTROptval(idx) = InfoLTR.fval; RTROptval(idx) = InfoRTR.fval;LTROptval2(idx) = InfoLTR2.fval; RTROptval2(idx) = InfoRTR2.fval; 
            end
            % compare result
            LTR_idx = LTRtime>LTRtime2; RTR_idx = RTRtime>RTRtime2;
            LTRtime(LTR_idx) = LTRtime2(LTR_idx);  RTRtime(RTR_idx) = RTRtime2(RTR_idx);  
            % calculate the ratios
            ratio1 = (SOCPtime)./LTRtime;
            ratio2 = RTRtime./LTRtime;
            % sava result
            result_table = table(m_list,n_list,SOCPtime,time_eig_list,LTRtime,RTRtime,ratio1,ratio2);      
            table_name =strcat('./result/synthetic_result/gamma',string(gamma),'/sparse',string(density),'_multiple',string(multiple),'.csv');
            writetable(result_table,table_name);
        end
        

    end
    
end