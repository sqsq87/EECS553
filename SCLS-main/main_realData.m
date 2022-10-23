% real data
dataname_list = ["wine_modest", "wine_severe", "insurance_modest","insurance_severe","building_modest","building_severe","blog_modest","blog_severe"]';
len_name = length(dataname_list);
gamma_list = [1e-1];
% normalization or not
normalize_yes = 1;
% % add path
% addpath('./Krylov method');
% addpath('./ROPTLIB')

for gamma_idx = 1: length(gamma_list)
    gamma = gamma_list(gamma_idx);
    
    ssdp_mr = zeros(len_name,1);socpeig_mr = zeros(len_name,1);socp_mr = zeros(len_name,1); LTR_mr = zeros(len_name,1); RTR_mr = zeros(len_name,1);LTR2_mr = zeros(len_name,1); RTR2_mr = zeros(len_name,1);
    ssdp_std = zeros(len_name,1);socpeig_std = zeros(len_name,1);socp_std = zeros(len_name,1); LTR_std = zeros(len_name,1); RTR_std = zeros(len_name,1);LTR2_std = zeros(len_name,1); RTR2_std = zeros(len_name,1);
    socpOptval = zeros(len_name,1);LTROptval = zeros(len_name,1);RTROptval = zeros(len_name,1);LTROptval2 = zeros(len_name,1);RTROptval2 = zeros(len_name,1);
    for idx = 1:len_name
        dataname = dataname_list(idx);
        [X, y, z, const, gamma_list, gamma_time, datasize_list] = data_read(dataname);
        %normalization
        if normalize_yes
            X = normalize(X,'range'); 
        end
        [Infossdp,Infosocp,InfoLTR,InfoRTR,InfoLTR2,InfoRTR2] = getTime_realData(X, y, z, gamma, datasize_list);
       
        % save the results
        ssdp_mr  = Infossdp.logtime;socp_mr  = Infosocp.logtime; socpeig_mr  = Infosocp.logtimeeig;LTR_mr  = InfoLTR.logtime; RTR_mr  = InfoRTR.logtime;LTR2_mr  = InfoLTR2.logtime; RTR2_mr  = InfoRTR2.logtime;
        ssdp_std  = Infossdp.logtimestd;socp_std  = Infosocp.logtimestd; socpeig_std  = Infosocp.logtimestdeig;LTR_std  = InfoLTR.logtimestd;LTR2_std  = InfoLTR2.logtimestd; RTR_std  = InfoRTR.logtimestd;RTR2_std  = InfoRTR2.logtimestd;        
        socpOptval  = Infosocp.fval;LTROptval  = InfoLTR.fval; RTROptval  = InfoRTR.fval;LTROptval2  = InfoLTR2.fval; RTROptval2  = InfoRTR2.fval; 
        
        % save compared table
        LTR_idx = LTR_mr>LTR2_mr; RTR_idx = RTR_mr>RTR2_mr;
        LTR_std(LTR_idx) = LTR2_std(LTR_idx);LTR_mr(LTR_idx) = LTR2_mr(LTR_idx);
        RTR_std(RTR_idx) = RTR2_std(RTR_idx);RTR_mr(RTR_idx) = RTR2_mr(RTR_idx);
        res_table_cmp = table(datasize_list,ssdp_mr,ssdp_std,socp_mr,socp_std,socpeig_mr,socpeig_std,LTR_mr,LTR_std,RTR_mr,RTR_std); 
        table_name_cmp =strcat('./result/',string(dataname),'_time.csv');
        writetable(res_table_cmp,table_name_cmp);


    end

end
