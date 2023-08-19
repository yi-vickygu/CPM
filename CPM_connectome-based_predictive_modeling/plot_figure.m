function plot_figure(perform_perm, perform)
    figure, 
    hist = histogram(perform_perm); 
    hold on;
    top = max(100, max(hist.Values)+20);
    left = min(-0.46, min(hist.BinEdges)-0.2);
    right = max(0.46, max(hist.BinEdges)+0.2);

    scatter(mean(perform, 'omitnan'), 0, 'ro', 'LineWidth', 2);
    plot([mean(perform, 'omitnan'), mean(perform, 'omitnan')], [0, top], 'r-');
    set(gca, 'Fontname', 'Times New Roman', 'FontSize', 12);
    xlabel('Correlation Coefficient', 'Fontname', 'Times New Roman', 'FontSize', 12)
    xlim([left, right])
    ylim([0, top])
    ylabel('Number of Occurance', 'Fontname', 'Times New Roman', 'FontSize', 12)
end