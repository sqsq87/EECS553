function plot_time(csvname)
% csvname = './result/blog_modest_time';
table = readtable(csvname);
varname_list = table.Properties.VariableNames;
for i = 1: length(varname_list)
    eval( strcat(string(varname_list(i)),'=table{:,i};'))
end
krylov_conf = zeros(size(datasize_list, 1), 1);
ROPTLIB_conf = zeros(size(datasize_list, 1), 1);
ssdp_conf = zeros(size(datasize_list, 1), 1);
socp_conf = zeros(size(datasize_list, 1), 1);

N = 10;

SEM_ssdp = ssdp_std/ sqrt(N);
SEM_socp = socp_std/ sqrt(N);
SEM_krylov = krylov_std/ sqrt(N);
SEM_ROPTLIB = ROPTLIB_std / sqrt(N);
CI95 = tinv(0.975, N-1);

for i=1:size(krylov_mr, 1)
   krylov_conf(i, 1) = SEM_krylov(i,1) * CI95;
   ROPTLIB_conf(i, 1) = SEM_ROPTLIB(i, 1) * CI95;
   ssdp_conf(i, 1) = SEM_ssdp(i, 1) * CI95;
   socp_conf(i, 1) = SEM_socp(i, 1) * CI95;
end

figure(1)
hold on
xlabel('m');
ylabel('Running time (seconds)');

errorbar(datasize_list, ssdp_mr, ssdp_conf, 'LineStyle',  '-.' ,'LineWidth',2,'color',[0.9290,0.6940,0.1250]);
errorbar(datasize_list, socp_mr, socp_conf, 'LineStyle',  '-.' ,'LineWidth',2,'color',[0.4940,0.1840,0.5560]);
errorbar(datasize_list, krylov_mr, krylov_conf, 'LineStyle',  '-.','LineWidth',2,'color',[0,0.4470,0.7410]);
errorbar(datasize_list, ROPTLIB_mr, ROPTLIB_conf, 'LineStyle', '-.','LineWidth',2,'color',[0.8500,0.3250,0.0980]);

% set(gca,'YScale','log');
set(0,'defaultTextInterpreter','latex');

legend('Single SDP','SOCP','LTRSR','RTRNewton','Location','northeast')
%wine

if contains(csvname,'building')
    loc = 'northeast';
else
    loc = 'best';
end

% loc = 'best';

legend('Single SDP','SOCP','LTRSR','RTRNewton','Location',loc) % east/blog; northeast/wine

max_y = (int32(max(ROPTLIB_mr)/5) + 1) * 5;    

xlim([min(datasize_list),max(datasize_list)]);

yTick_min = min(unique(int32( floor(get(gca,'ytick')))));
yTick_max = max(unique(int32( ceil(get(gca,'ytick')))));
ylim([yTick_min , yTick_max]);
yTick = [yTick_min:1:yTick_max];
set(gca,'YTick',yTick)
yTickLabels = cellstr(num2str((yTick(:)),'10^{%d}'));
yticklabels(yTickLabels);

% save eps
dataname = csvname(10:end);
figname = strcat('./figures/',dataname);
saveas(gcf,figname,'epsc');

hold off
close
