function [X, y, z,const, gamma_list, gamma_time, datasize_list] =  data_read(dataname)
switch dataname
    case {'wine_modest','wine_severe'}
        table = readtable('datasets/wine.csv');
        X = table{:, 1:11};
        y = table{:, 12};
        z = y*1;
        z(z > 10.0) = 10.0;
        z(z < 0.0) = 0.0;
        if contains(dataname,'modest')
            z(z <6) = 6;
        else
            z(z <7) = 7;
        end
        const = 0.1; % the constant for normalization
        gamma_list = linspace(1e-3,0.75,40)';% setting of ICML
%         gamma_list = 2;
        gamma_time = 0.5;
        datasize_list = linspace(150,1500,16)';
%         datasize_list = linspace(150,1500,21)';
    case {'insurance_modest','insurance_severe'}
        csvname = ['datasets/insurance.csv'];
        table = readtable(csvname);
        T = createOneHotEncoding(table, 'sex');
        T = createOneHotEncoding(T, 'smoker');
        T = createOneHotEncoding(T, 'region');
        y = T.charges;
        if contains(dataname,'modest')
            z = y - 100;
        else
            z = y - 300;
        end
        
        z(z < 0.0) = 0.0;
        z = z / 100;
        y = y / 100;
        T = removevars(T,{'charges'});
        X = T{:,:};
        const = 0.03; % the constant for normalization
%         gamma_list = linspace(1e-3,0.75,40)';% setting of ICML
        gamma_list = [1e-3];
        gamma_time = 0.5;
        datasize_list = linspace(100,1300,25)';  
    case {'building_modest','building_severe'}
        Table=xlsread('datasets/building.xlsx');
        y=Table(:,108);
        X=Table(:,1:107);
        if contains(dataname,'modest')
            z = y + 20 ;
        else
            z = y + 40 ; 
        end
        z(z < 0.0) = 0.0; 
        const = 0.01; % the constant for normalization
%         gamma_list = linspace(1e-3,0.75,40)';% setting of ICML
        gamma_list = [20];
        gamma_time = 0.5;
        datasize_list = linspace(100,300,21)'; 
        nor = const*max(abs(y));
        y = y/nor;
        z = z/nor;
        
    case {'building_modest170','building_severe170'}
        Table=xlsread('datasets/building.xlsx');
        y=Table(:,108);
        X=Table(:,1:107);
        if contains(dataname,'modest')
            z = y + 20 ;
        else
            z = y + 40 ; 
        end
        z(z < 0.0) = 0.0; 
        const = 0.01; % the constant for normalization
%         gamma_list = linspace(1e-3,0.75,40)';% setting of ICML
        gamma_list = [20];
        gamma_time = 0.5;
        datasize_list = [170]'; 
        nor = const*max(abs(y));
        y = y/nor;
        z = z/nor;        
      
 
    case{'blog_modest','blog_severe'}
        Table = csvread('datasets/blog.csv');
        y = Table(:,281);
        X = Table(:,1:280);
       if contains(dataname,'modest')
           z=y+5;
       else
           z=y+10;
       end
       z(z<0)=0;        
       const = 0.01; % the constant for normalization
%        gamma_list = linspace(1e-3,0.75,40)';% setting of ICML
       gamma_list = 200;
       gamma_time = 0.5;
       datasize_list = linspace(5000,50000,10)';  
end
