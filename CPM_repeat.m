function [perform, mse_err, predict_label, pos_edge, neg_edge] = CPM_repeat(Data, Label, time, K_fold, P_thr, pos_neg, Para_sel, Regre_method, Print, Shuffle, Norma)
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
    predict_label = zeros(size(Label, 1), time);
    pos_edge = zeros(time, size(Data, 2));
    neg_edge = zeros(time, size(Data, 2));
    parfor idx = 1:time
        [perform(idx), mse_err(idx), predict_label(:, idx), pos_edge(idx, :), neg_edge(idx, :)] = CPM_main(Data, Label, K_fold, P_thr, pos_neg, Para_sel, Regre_method, false, true, Norma);
    end
end