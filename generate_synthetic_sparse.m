function [] = generate_synthetic()

n_list = [10000,15000, 20000, 25000, 30000, 35000, 40000]';
density_list = [0.0001,0.001,0.01];
multiple_list = [0.5,1,2,3];

for multiple_idx = 1:length(multiple_list)
    multiple = multiple_list(multiple_idx);
    m_list = multiple * n_list;
    for i = 1:length(n_list)
            m = m_list(i); n = n_list(i);
            for j = 1:length(density_list)
                density = density_list(j);
                X = sprandn(m,n,density);
                w = sprandn(n,1,1);
                xi = 0.5 * sprandn(m,1,1);
                y = X * w + xi;
                matname = strcat('./datasets/synthetic/sparse_matrix/m',string(m),'n',string(n),'sparse',string(density),'_Msparse.mat');
                save(matname,'X','y');
            end
    end
end