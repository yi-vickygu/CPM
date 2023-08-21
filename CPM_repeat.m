function [perform, mse_err, predict_label, pos_edge, neg_edge] = CPM_repeat(time, Data, Label, Covarate, K_fold, P_thr, pos_neg, Para_sel, Regre_method, Print, Shuffle, Norma)
    perform = zeros(time, 1);
    mse_err = zeros(time, 1);
    predict_label = zeros(size(Label, 1), time);
    pos_edge = zeros(time, size(Data, 2));
    neg_edge = zeros(time, size(Data, 2));
    parfor idx = 1:time
        [perform(idx), mse_err(idx), predict_label(:, idx), pos_edge(idx, :), neg_edge(idx, :)] = CPM_main(Data, Label, Covarate, K_fold, P_thr, pos_neg, Para_sel, Regre_method, false, true, Norma);
    end
end