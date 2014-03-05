function generate_configuration(len,info_detail,info_ind,start_time,end_time,mat_A)
global conf_list;
global n_tasks;
if(len>0)
    conf_list=[conf_list,info_detail];
    for i=1:n_tasks
        if (info_ind(i)==1)
        fprintf('%2d %4.4f %4.4f\n',i,info_detail(i,1),info_detail(i,2));
        end
    end
            fprintf('\n');
end

for i=1:n_tasks
    if(info_ind(i)==0)
        if(mat_A(i,2)<5)
        if (max(start_time,mat_A(i,4))<(min(end_time,mat_A(i,5))-mat_A(i,6)))
            info_detail_new=info_detail;
            info_ind_new=info_ind;
            info_detail_new(i,1)=max(start_time,mat_A(i,4));
            info_detail_new(i,2)=info_detail_new(i,1)+mat_A(i,6);
            info_ind_new(i)=1;
            generate_configuration(len+1,info_detail_new,info_ind_new,info_detail_new(i,2),end_time,mat_A)
        end
        end
    end
end
            
            