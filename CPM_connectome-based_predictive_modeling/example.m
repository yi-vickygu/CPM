clear
clc

num_sub = 300;
num_edge = 5000;

Label = randi([20 100], num_sub, 1);
Data = Label*randn(1, num_edge) + Label.*randn(num_sub, num_edge)*20;

[perform, rmse_err, predict_label, pos_edge, neg_edge] = CPM_main(Data, Label, [], 10, 0.05, 3, 1, 1, false, true, true);

disp('perform');
disp(perform);
disp('rmse_err');
disp(rmse_err);

time = 1000; %重复运行的次数
[perform, mse_err, predict_label, pos_edge, neg_edge] = CPM_repeat(time, Data, Label, [], 10, 0.05, 3, 1, 1, false, true, true);

disp('perform');
disp(mean(perform, 'omitnan'));
disp('rmse_err');
disp(mean(rmse_err, 'omitnan'));

time = 10000; %重复运行的次数
[perform_perm, mse_err_perm] = CPM_perm_test(time, Data, Label, [], 10, 0.05, 3, 1, 1, false, true, true);

plot_figure(perform_perm, perform);