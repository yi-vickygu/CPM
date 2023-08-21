function [perform, rmse_err, predict_label, pos_edge, neg_edge] = CPM_main(Data, Label, Covarate, K_fold, P_thr, pos_neg, Para_sel, Regre_method, Print, Shuffle, Norma)
%    input:
%    ----Data, matrix with shape: num_sub*num_edge, 
%              num_sub: number of data(subject).
%              num_edge: number of edge, which is equal to the number of 
%                        upper triangular elements in the FC matrix, = nROI*(nROI-1)/2.
%              for each element in data, data(:, idx) is the function
%              connective of idx th subject.
%    ----Label, matrix with shape: num_sub*1, the element of label is the
%              value of subjet which we want to predict, such as IQ, momery.
%    ----Covarate, matrix with shape: num_sub* ~ , information which used
%              to assist regression.
%    ----K_fold, number of fold in perform cross validation.
%    ----P_thr, threshold of P used when select edge.
%    ----pos_neg, The parameters used to control the selection of
%              parameters.
%              1: only use the positively correlated edges.
%              2: only use the negatively correlated edges.
%              3: use both positive and negative correlation edges.
%    ----Para_sel, whether to sum over positive or negative related edges.
%              1: sum
%              2: not sum
%    ----Regre_method, Methods used in regression analysis.
%              1: regress
%              2: robustfit
%              3: SVR
%    ----Print: Whether to print some information.
%    ----Shuffle: Whether to shuffle Data, Label and Covarte.
%    ----Norma: Whether to normalize the independent variables and covariables.

    [num_sub, num_edge] = size(Data);
    
    if Shuffle
        Shuffle_idx = randperm(num_sub);
        Data = Data(Shuffle_idx, :);
        Label = Label(Shuffle_idx);
        if ~isempty(Covarate)
            Covarate = Covarate(Shuffle_idx, :);
        end
    end
    
    predict_label = zeros(num_sub, 1);
    
    pos_edge = zeros(K_fold, num_edge);
    neg_edge = zeros(K_fold, num_edge);
    
    if Print
        fprintf("begin %d fold: \n", K_fold);
    end
    
    for fold = 1:K_fold
        if Print
            fprintf(" fold: %3d     ", fold);
        end
        
        select_idx = true(num_sub, 1);
        select_idx(floor((fold-1)*num_sub/K_fold)+1: floor(fold*num_sub/K_fold)) = false;
        
        train_data = Data(select_idx, :);
        train_label = Label(select_idx);
        num_train = size(train_data, 1);
        
        if Norma
            data_mean = mean(train_data);
            data_std = std(train_data);
            label_mean = mean(train_label);
            label_std = std(train_label);
            
            train_data = (train_data-data_mean)./data_std;
            train_label = (train_label-label_mean)./label_std;
        end
        
        if ~isempty(Covarate)
            train_covarate = Covarate(select_idx, :);
            
            if Norma
                cova_mean = mean(train_covarate);
                cova_std = std(train_covarate);
                
                train_covarate = (train_covarate-cova_mean)./cova_std;
            end
        else
            train_covarate = [];
        end
        
        valid_data = Data(~select_idx, :);
        valid_label = Label(~select_idx);
        num_valid = size(valid_data, 1);
        
        if Norma
            valid_data = (valid_data-data_mean)./data_std;
            valid_label = (valid_label-label_mean)./label_std;
        end
        
        if ~isempty(Covarate)
            valid_covarate = Covarate(~select_idx, :);
            
            if Norma
                valid_covarate = (valid_covarate-cova_mean)./cova_std;
            end
        else
            valid_covarate = [];
        end
        
        [r_val, p_val] = corr(train_data, train_label);
        
%         p_sort = sort(p_val);
%         p_thresh = p_sort(ceil(0.9*length(p_val)));
        pos_mask = r_val > 0 & p_val < P_thr;
        neg_mask = r_val < 0 & p_val < P_thr;
        
        if sum(pos_mask)<3 || sum(neg_mask)<3
            fprintf("p threshold is too low: %.4f,      number of positively edges: %4d,      number of negatively edges: %4d\n",...
                P_thr, sum(pos_mask), sum(neg_mask));
        end
        
        pos_edge(fold, :) = pos_mask;
        neg_edge(fold, :) = neg_mask;
        
        if Print
            fprintf("number of positively edges: %4d,    number of negatively edges: %4d\n", sum(pos_mask), sum(neg_mask));
        end
        
        if Para_sel==1
            train_pos = zeros(num_train, 1);
            train_neg = zeros(num_train, 1);
        elseif Para_sel==2
            train_pos = zeros(num_train, sum(pos_mask));
            train_neg = zeros(num_train, sum(neg_mask));
        else
            fprintf("Incorrect input of parameter Para_sel: %d, should be 1 or 2.\n", Para_sel);
        end

        for idx = 1:num_train
            train_data_idx = train_data(idx, :);

            if Para_sel==1
                train_pos(idx) = mean(train_data_idx(pos_mask), 'omitnan');
                train_neg(idx) = mean(train_data_idx(neg_mask), 'omitnan');
            elseif Para_sel==2
                train_pos(idx, :) = train_data_idx(pos_mask);
                train_neg(idx, :) = train_data_idx(neg_mask);
            else
                fprintf("Incorrect input of parameter Para_sel: %d, should be 1 or 2.\n", Para_sel);
            end
        end
        
        if pos_neg==1
            train_input = [train_pos, train_covarate];
        elseif pos_neg==2
            train_input = [train_neg, train_covarate];
        elseif pos_neg==3
            train_input = [train_pos, train_neg, train_covarate];
        else
            fprintf("Incorrect input of parameter pos_neg: %d, should be 1, 2 or 3.\n", pos_neg);
        end

        if Regre_method==1
            model = regress(train_label, [ones(num_train, 1), train_input]);
        elseif Regre_method==2
            model = robustfit(train_input, train_label);
        elseif Regre_method==3
            model = svmtrain(train_label, train_input, '-s 3 -t 0 -q');
        else
            fprintf("Incorrect input of parameter Regre_method: %d, should be 1, 2 or 3.\n", Regre_method);
        end
        
        %验证集
        if Para_sel==1
            valid_pos = zeros(num_valid, 1);
            valid_neg = zeros(num_valid, 1);
        elseif Para_sel==2
            valid_pos = zeros(num_valid, sum(pos_mask));
            valid_neg = zeros(num_valid, sum(neg_mask));
        else
            fprintf("Incorrect input of parameter Para_sel: %d, should be 1 or 2.\n", Para_sel);
        end

        for idx = 1:num_valid
            valid_data_idx = valid_data(idx, :);

            if Para_sel==1
                valid_pos(idx) = mean(valid_data_idx(pos_mask));
                valid_neg(idx) = mean(valid_data_idx(neg_mask));
            elseif Para_sel==2
                valid_pos(idx, :) = valid_data_idx(pos_mask);
                valid_neg(idx, :) = valid_data_idx(neg_mask);
            else
                fprintf("Incorrect input of parameter Para_sel: %d, should be 1 or 2.\n", Para_sel);
            end
        end
        
        if pos_neg==1
            valid_input = [valid_pos, valid_covarate];
        elseif pos_neg==2
            valid_input = [valid_neg, valid_covarate];
        elseif pos_neg==3
            valid_input = [valid_pos, valid_neg, valid_covarate];
        else
            fprintf("Incorrect input of parameter pos_neg: %d, should be 1, 2 or 3.\n", pos_neg);
        end
        
        if Regre_method==1 || Regre_method==2
            pre_label = [ones(num_valid, 1), valid_input]*model;
        elseif Regre_method==3
            pre_label = svmpredict(valid_label, valid_input, model, '-q');
        else
            fprintf("Incorrect input of parameter Regre_method: %d, should be 1, 2 or 3.\n", Regre_method);
        end
        
        if Norma
            predict_label(~select_idx) = pre_label*label_std + label_mean;
        else
            predict_label(~select_idx) = pre_label;
        end
    end
    
    perform = corr(predict_label, Label);
    rmse_err = sqrt(mean((predict_label - Label).^2));
    pos_edge = sum(pos_edge);
    neg_edge = sum(neg_edge);
    if Shuffle
        [~, idx] = sort(Shuffle_idx);
        predict_label = predict_label(idx);
    end
end