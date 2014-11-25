function [] = plot_stat(matrix_stat)
    build_col=matrix_stat(1,:);
    build_col(1)=[];
    run_row=matrix_stat(:,1);
    run_row(1)=[];
    
    matrix_stat(1,:)=[];
    matrix_stat(:,1)=[];
    matrix_stat_fixed=fix_matrix(matrix_stat);

    surf(build_col,run_row,matrix_stat_fixed)
    xlabel('Build Param')
    ylabel('Run Param')
    zlabel('Value')
end

function [matrix_stat]=fix_matrix(matrix_stat)
    for c=1:size(matrix_stat,2)
        maxim=max(matrix_stat(:,c));
        for r=1:size(matrix_stat,1)
            if matrix_stat(r,c)==0
                matrix_stat(r,c)=maxim;
            end
        end
    end
end