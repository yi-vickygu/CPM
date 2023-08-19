function [perform, mse_err] = CPM_perm_test(time, Data, Label, Covarate, K_fold, P_thr, pos_neg, Para_sel, Regre_method, Print, Shuffle, Norma)
    perform = zeros(time, 1);
    mse_err = zeros(time, 1);
    num_sub = size(Data, 1);
    
    parfor idx = 1:time
        [perform(idx), mse_err(idx), ~, ~, ~] = CPM_main(Data, Label(randperm(num_sub)), Covarate, K_fold, P_thr, pos_neg, Para_sel, Regre_method, false, true, Norma);
    end
end