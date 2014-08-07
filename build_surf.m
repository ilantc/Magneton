function  build_surf(p)
    z = csvread(p,1,1);
    m = csvread(p,0,0);
    x=m(1,:);
    x(1)=[];
    y=m(:,1);
    y(1)=[];
    temp=0;
    %fix missing data
    for amoda = 1:(size(z,2))
        for shura = 1:(size(z,1))
            if z(shura,amoda)==0
                z(shura,amoda)=temp;
            else
                temp=z(shura,amoda);
            end
        end
    end
    %plot
    surf(x,y,z)
    zlabel('LP Value')
    xlabel('buildP')
    ylabel('runP')
end    

    
