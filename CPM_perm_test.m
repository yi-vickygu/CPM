function [perform, mse_err] = CPM_perm_test(Data, Label, time, K_fold, P_thr, pos_neg, Para_sel, Regre_method, Print, Shuffle, Norma)
    if nargin < 3
        time = 1000;
    end
    if nargin < 4
        K_fold = 10;
    end
    if nargin < 5
        P_thr = 0.05;
    end
    if nargin < 6
        pos_neg = 3;
    end
    if nargin < 7
        Para_sel = 1;
    end
    if nargin < 8
        Regre_method = 1;
    end
    if nargin < 9
        Print = false;
    end
    if nargin < 10
        Shuffle = true;
    end
    if nargin < 11
        Norma = true;
    end
    
    perform = zeros(time, 1);
    mse_err = zeros(time, 1);
    num_sub = size(Data, 1);
    
    parfor idx = 1:time
        [perform(idx), mse_err(idx), ~, ~, ~] = CPM_main(Data, Label(randperm(num_sub)), K_fold, P_thr, pos_neg, Para_sel, Regre_method, false, true, Norma);
    end
end