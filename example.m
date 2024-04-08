clear
clc

num_sub = 300;
num_edge = 5000;

Label = randi([20 100], num_sub, 1);
Data = Label*randn(1, num_edge) + Label.*randn(num_sub, num_edge)*20;

[perform, rmse_err, predict_label, pos_edge, neg_edge] = CPM_main(Data, Label);

disp('perform');
disp(perform);
disp('rmse_err');
disp(rmse_err);

[perform, mse_err, predict_label, pos_edge, neg_edge] = CPM_repeat(Data, Label);

disp('perform');
disp(mean(perform, 'omitnan'));
disp('rmse_err');
disp(mean(rmse_err, 'omitnan'));

time = 10000; %number of repeat runs
[perform_perm, mse_err_perm] = CPM_perm_test(Data, Label, time);

plot_figure(perform_perm, perform);