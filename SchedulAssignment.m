function [goodOptions2, goodOptions3, goodOptions4, goodOptions5] = ...
    SchedulAssignment(maxNumOfOptions, MissionsDB, FlightsDB, types, flightNum)

% Init
goodOptions2=zeros(maxNumOfOptions,10);
goodOptions3=zeros(maxNumOfOptions,6);



numMissions=length(MissionsDB);
PossibleMissionsIdx=zeros(1,numMissions);

for m=1:numMissions
    if types(MissionsDB(m).Type)==1
        maxStart=max(MissionsDB(m).StartAfter,FlightsDB(flightNum).TakeoffTime);
        minEnd=min(MissionsDB(m).EndBefore,FlightsDB(flightNum).LandingTime);
        if minEnd-maxStart>=MissionsDB(m).Duration;
            PossibleMissionsIdx(m)=1;
        end
    end
end

% TODO: Limit Max Posible missions to 40, in order to prevent Out of Memory
% problem in combs(40,5)  or nchoosek(40,5) is of size 658K !!!


%% Chains of 2
numNotFeasible=0;
numGoodOptions2=0;
A=combs(find(PossibleMissionsIdx>0),2);
numRows=size(A,1);
notFeasibleOptions2=zeros(numRows,2);
for r=1:numRows
    if numGoodOptions2>=maxNumOfOptions, break; end
    minUnionTime=min([MissionsDB(A(r,1)).StartAfter,MissionsDB(A(r,2)).StartAfter]);
    maxUnionTime=max([MissionsDB(A(r,1)).EndBefore,MissionsDB(A(r,2)).EndBefore]);
    if maxUnionTime-minUnionTime<MissionsDB(A(r,1)).Duration+MissionsDB(A(r,2)).Duration
        % both are bad
        numNotFeasible=numNotFeasible+1;
        notFeasibleOptions2(numNotFeasible,1:2)=[A(r,1), A(r,2)];
    else % maybe feasible
        % check both options
        startFirst=MissionsDB(A(r,1)).StartAfter;
        startSecond=max(startFirst+MissionsDB(A(r,1)).Duration,MissionsDB(A(r,2)).StartAfter);
        if startSecond+MissionsDB(A(r,2)).Duration >MissionsDB(A(r,2)).EndBefore % check if feasible
            % not feasible
            % check the opposite option
            startFirst=MissionsDB(A(r,2)).StartAfter;
            startSecond=max(startFirst+MissionsDB(A(r,2)).Duration,MissionsDB(A(r,1)).StartAfter);
            if startSecond+MissionsDB(A(r,1)).Duration>MissionsDB(A(r,1)).EndBefore % check if feasible
                % not feasible
                numNotFeasible=numNotFeasible+1;
                notFeasibleOptions2(numNotFeasible,:)=[A(r,1);A(r,2)];
            else
                % feasible
                numGoodOptions2=numGoodOptions2+1;
                goodOptions2(numGoodOptions2,1:4)=[A(r,2), A(r,1), startFirst, startSecond];
            end
        else % feasible
            numGoodOptions2=numGoodOptions2+1;
            goodOptions2(numGoodOptions2,1:4)=[A(r,1), A(r,2), startFirst, startSecond];
        end
    end
end
notFeasibleOptions2=notFeasibleOptions2(1:numNotFeasible,:);
goodOptions2=goodOptions2(1:numGoodOptions2,1:2);

%% chains of three
numNotFeasible=0;
PossibleMissionsIdx=find(PossibleMissionsIdx>0);
A=combs(find(PossibleMissionsIdx>0),3);
numRows=size(A,1);
notFeasibleOptions3=zeros(numRows,3);
feasible3=ones(numRows,1);
for r=1:numRows
    minUnionTime=min([MissionsDB(A(r,1)).StartAfter,MissionsDB(A(r,2)).StartAfter,MissionsDB(A(r,3)).StartAfter]);
    maxUnionTime=max([MissionsDB(A(r,1)).EndBefore,MissionsDB(A(r,2)).EndBefore,MissionsDB(A(r,3)).EndBefore]);
    if maxUnionTime-minUnionTime<MissionsDB(A(r,1)).Duration+MissionsDB(A(r,2)).Duration+MissionsDB(A(r,3)).Duration
        % not feasible
        numNotFeasible=numNotFeasible+1;
        notFeasibleOptions3(numNotFeasible,:)=[A(r,1),A(r,2), A(r,3)];
        feasible3(r)=0;
    end
end

% pairs which are not feasible
for r=1:size(notFeasibleOptions2,1)
    [row,~] = find(A==notFeasibleOptions2(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions2(r,2)); % row_idx is index of row
    row = sort(row(row_idx));
    for s=1:size(row,1)
        if feasible3(row(s))==1;
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions3(numNotFeasible,:)=[A(row(s),1), A(row(s),2), A(row(s),3)];
            feasible3(row(s))=0;
        end
    end
end

permutations=permsr(1:1:3);
numGoodOptions3=0;
rowNum=0;
for r=1:numRows
    if numGoodOptions3>=maxNumOfOptions, break; end
    if feasible3(r)==0
        continue
    end
    options=zeros(6,3);
    optionFound=false;
    for s=1:6
        if optionFound, break; end
        rowNum=rowNum+1;
        options(rowNum,1:3)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3))];
        startFirst=MissionsDB(options(rowNum,1)).StartAfter;
        startSecond=max(startFirst+MissionsDB(options(rowNum,1)).Duration,MissionsDB(options(rowNum,2)).StartAfter);
        if startSecond+MissionsDB(options(rowNum,2)).Duration>MissionsDB(options(rowNum,2)).EndBefore, continue; end
        startLast=max(startSecond+MissionsDB(options(rowNum,2)).Duration,MissionsDB(options(rowNum,3)).StartAfter);
        if startLast+MissionsDB(options(rowNum,3)).Duration>MissionsDB(options(rowNum,3)).EndBefore
            continue;
        else
            optionFound = true;
            numGoodOptions3=numGoodOptions3+1;
            goodOptions3(numGoodOptions3,1:3)=options(s,:);
            goodOptions3(numGoodOptions3,4:6)=[startFirst, startSecond, startLast];
        end
    end
    if optionFound == false % not feasible option
        feasible3(r)=0;
        numNotFeasible=numNotFeasible+1;
        notFeasibleOptions3(numNotFeasible,:)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3))];
    end
end

notFeasibleOptions3=notFeasibleOptions3(1:numNotFeasible,:);
goodOptions3=goodOptions3(1:numGoodOptions3,1:3);

%% chains of 4
numNotFeasible=0;
A=combs(find(PossibleMissionsIdx>0),4);
numRows=size(A,1);
notFeasibleOptions4=zeros(numRows,4);
feasible4=ones(numRows,1);

for r=1:numRows
    minUnionTime=min([MissionsDB(A(r,1)).StartAfter,MissionsDB(A(r,2)).StartAfter,MissionsDB(A(r,3)).StartAfter,MissionsDB(A(r,4)).StartAfter]);
    maxUnionTime=max([MissionsDB(A(r,1)).EndBefore,MissionsDB(A(r,2)).EndBefore,MissionsDB(A(r,3)).EndBefore,MissionsDB(A(r,4)).EndBefore]);
    if maxUnionTime-minUnionTime<MissionsDB(A(r,1)).Duration+MissionsDB(A(r,2)).Duration+MissionsDB(A(r,3)).Duration+MissionsDB(A(r,4)).Duration
        % not feasible
        numNotFeasible=numNotFeasible+1;
        notFeasibleOptions4(numNotFeasible,:)=[A(r,1), A(r,2), A(r,3), A(r,4)];
        feasible4(r)=0;
    end
end

% pairs which are not feasible
for r=1:size(notFeasibleOptions2,1)
    [row,~] = find(A==notFeasibleOptions2(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions2(r,2)); % row_idx is index of raw
    row = sort(row(row_idx));
    for s=1:size(row,1)
        if  feasible4(row(s))==1
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions4(numNotFeasible,:)=[A(row(s),1), A(row(s),2), A(row(s),3), A(row(s),4)];
            feasible4(row(s))=0;
        end
    end
end

% triplets which are not feasible
for r=1:size(notFeasibleOptions3,1)
    [row,~] = find(A==notFeasibleOptions3(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions3(r,2)); % row_idx is index of row
    row = sort(row(row_idx));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions3(r,3)); % row_idx is index of row
    row = sort(row(row_idx));
    for s=1:size(row,1)
        if feasible4(row(s))==1
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions4(numNotFeasible,:)=[A(row(s),1),A(row(s),2),A(row(s),3),A(row(s),4)];
            feasible4(row(s))=0;
        end
    end
end

permutations=permsr(1:1:4);
goodOptions4=zeros(maxNumOfOptions,8);
numGoodOptions4=0;

rowNum=0;
for r=1:numRows
    if numGoodOptions4>=maxNumOfOptions, break; end
    if feasible4(r)==0
        continue
    end
    options=zeros(24,4);
    optionFound=false;
    for s=1:24
        if optionFound, break; end
        rowNum=rowNum+1;
        options(rowNum,1:4)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3)),A(r,permutations(s,4))];
        startFirst=MissionsDB(options(rowNum,1)).StartAfter;
        startSecond=max(startFirst+MissionsDB(options(rowNum,1)).Duration,MissionsDB(options(rowNum,2)).StartAfter);
        if startSecond+MissionsDB(options(rowNum,2)).Duration>MissionsDB(options(rowNum,2)).EndBefore, continue; end
        startThird=max(startSecond+MissionsDB(options(rowNum,2)).Duration,MissionsDB(options(rowNum,3)).StartAfter);
        if startThird+MissionsDB(options(rowNum,3)).Duration>MissionsDB(options(rowNum,3)).EndBefore, continue; end
        startLast=max(startThird+MissionsDB(options(rowNum,3)).Duration,MissionsDB(options(rowNum,4)).StartAfter);
        if startLast+MissionsDB(options(rowNum,4)).Duration>MissionsDB(options(rowNum,4)).EndBefore,
            continue;
        else
            optionFound = true;
            numGoodOptions4=numGoodOptions4+1;
            goodOptions4(numGoodOptions4,1:4)=options(s,:);
            goodOptions4(numGoodOptions4,5:8)=[startFirst, startSecond, startThird, startLast];
        end
    end
    if optionFound == false % not feasible option
        if feasible4(r)==1
            feasible4(r)=0;
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions4(numNotFeasible,:)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3)),A(r,permutations(s,4))];
        end
    end
end

notFeasibleOptions4=(notFeasibleOptions4(1:numNotFeasible,:));
goodOptions4=goodOptions4(1:numGoodOptions4,1:4);

%% chains of 5
numNotFeasible=0;
A=combs(find(PossibleMissionsIdx>0),5);
numRows=size(A,1);
notFeasibleOptions5=zeros(numRows,5);
feasible5=ones(numRows,1);
for r=1:numRows
    if numRows>=maxNumOfOptions*2, break; end
    minUnionTime=min([MissionsDB(A(r,1)).StartAfter,MissionsDB(A(r,2)).StartAfter,MissionsDB(A(r,3)).StartAfter,MissionsDB(A(r,4)).StartAfter,MissionsDB(A(r,5)).StartAfter]);
    maxUnionTime=max([MissionsDB(A(r,1)).EndBefore,MissionsDB(A(r,2)).EndBefore,MissionsDB(A(r,3)).EndBefore,MissionsDB(A(r,4)).EndBefore,MissionsDB(A(r,5)).EndBefore]);
    if maxUnionTime-minUnionTime<MissionsDB(A(r,1)).Duration+MissionsDB(A(r,2)).Duration+MissionsDB(A(r,3)).Duration+MissionsDB(A(r,4)).Duration+MissionsDB(A(r,5)).Duration
        % not feasible
        numNotFeasible=numNotFeasible+1;
        notFeasibleOptions5(numNotFeasible,:)=[A(r,1), A(r,2), A(r,3), A(r,4), A(r,5)];
        feasible5(r)=0;
    end
end

% pairs which are not feasible
for r=1:size(notFeasibleOptions2,1)
    [row,~] = find(A==notFeasibleOptions2(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions2(r,2)); % row_idx is index of raw
    row = sort(row(row_idx));
    for s=1:size(row,1)
        if  feasible5(row(s))==1
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions5(numNotFeasible,:)=[A(row(s),1), A(row(s),2), A(row(s),3), A(row(s),4),A(row(s),5)];
            feasible5(row(s))=0;
        end
    end
end

% triplets which are not feasible
for r=1:size(notFeasibleOptions3,1)
    [row,~] = find(A==notFeasibleOptions3(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions3(r,2)); % row_idx is index of row
    row = sort(row(row_idx));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions3(r,3)); % row_idx is index of row
    row = sort(row(row_idx));
    for s=1:size(row,1)
        if feasible5(row(s))==1
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions5(numNotFeasible,:)=[A(row(s),1),A(row(s),2),A(row(s),3),A(row(s),4),A(row(s),5)];
            feasible5(row(s))=0;
        end
    end
end

% quartets which are not feasible
for r=1:size(notFeasibleOptions4,1)
    [row,~] = find(A==notFeasibleOptions4(r,1));
    [row_idx,~] = find(A(row,:) == notFeasibleOptions4(r,2)); % row_idx is index of row
    row = row(row_idx);
    [row_idx,~] = find(A(row,:) == notFeasibleOptions4(r,3)); % row_idx is index of row
    row = row(row_idx);
    [row_idx,~] = find(A(row,:) == notFeasibleOptions4(r,4)); % row_idx is index of row
    row = row(row_idx);
    for s=1:size(row,1)
        if feasible5(row(s))==1
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions5(numNotFeasible,:)=[A(row(s),1),A(row(s),2),A(row(s),3),A(row(s),4),A(row(s),5)];
            feasible5(row(s))=0;
        end
    end
end

permutations=permsr(5:-1:1);
goodOptions5=zeros(maxNumOfOptions,10);
numGoodOptions5=0;

rowNum=0;
for r=1:numRows
    if numGoodOptions5>=maxNumOfOptions, break; end
    if feasible5(r)==0
        continue
    end
    options=zeros(120,5);
    optionFound=false;
    for s=1:120
        if optionFound, break; end
        rowNum=rowNum+1;
        options(rowNum,1:5)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3)), ...
            A(r,permutations(s,4)),A(r,permutations(s,5))];
        startFirst=MissionsDB(options(rowNum,1)).StartAfter;
        startSecond=max(startFirst+MissionsDB(options(rowNum,1)).Duration,MissionsDB(options(rowNum,2)).StartAfter);
        if startSecond+MissionsDB(options(rowNum,2)).Duration>MissionsDB(options(rowNum,2)).EndBefore, continue; end
        startThird=max(startSecond+MissionsDB(options(rowNum,2)).Duration,MissionsDB(options(rowNum,3)).StartAfter);
        if startThird+MissionsDB(options(rowNum,3)).Duration>MissionsDB(options(rowNum,3)).EndBefore, continue; end
        startForth=max(startThird+MissionsDB(options(rowNum,3)).Duration,MissionsDB(options(rowNum,4)).StartAfter);
        if startForth+MissionsDB(options(rowNum,4)).Duration>MissionsDB(options(rowNum,4)).EndBefore, continue; end
        startLast=max(startForth+MissionsDB(options(rowNum,4)).Duration,MissionsDB(options(rowNum,5)).StartAfter);
        if startLast>MissionsDB(options(rowNum,5)).EndBefore
            continue;
        else
%             disp(['r = ',num2str(r),'s = ',num2str(s)]);
            optionFound = true;
            numGoodOptions5=numGoodOptions5+1;
            goodOptions5(numGoodOptions5,1:5)=options(s,:);
            goodOptions5(numGoodOptions5,6:10)=[startFirst, startSecond, startThird, startForth, startLast];
        end
    end
    if optionFound == false % not feasible option
        if feasible5(r)==1
            feasible5(r)=0;
            numNotFeasible=numNotFeasible+1;
            notFeasibleOptions5(numNotFeasible,:)=[A(r,permutations(s,1)),A(r,permutations(s,2)),A(r,permutations(s,3)),...
                A(r,permutations(s,4)), A(r,permutations(s,5))];
        end
    end
end

% notFeasibleOptions5 shall be used for permutations of 6
notFeasibleOptions5=(notFeasibleOptions5(1:numNotFeasible,:));

goodOptions5=goodOptions5(1:numGoodOptions5,1:5);

function P = permsr(V)
% subfunction to help with recursion

V = V(:).'; % Make sure V is a row vector
n = length(V);
if n <= 1
    P = V; 
    return; 
end

q = permsr(1:n-1);  % recursive calls
m = size(q,1);
P = zeros(n*m,n);
P(1:m,:) = [n*ones(m,1) q];

for i = n-1:-1:1,
   t = q;
   t(t == i) = n;
   P((n-i)*m+1:(n-i+1)*m,:) = [i*ones(m,1) t]; % assign the next m
                                               % rows in P.
end

P = V(P);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function P = combs(v,m)
%COMBS  All possible combinations.
%   COMBS(1:N,M) or COMBS(V,M) where V is a row vector of length N,
%   creates a matrix with N!/((N-M)! M!) rows and M columns containing
%   all possible combinations of N elements taken M at a time.
%
%   This function is only practical for situations where M is less
%   than about 15.

v = v(:).'; % Make sure v is a row vector.
n = length(v);
if n == m
    P = v;
elseif m == 1
    P = v.';
else
    P = [];
    if m < n && m > 1
        for k = 1:n-m+1
            Q = combs(v(k+1:n),m-1);
            P = [P; [v(ones(size(Q,1),1),k) Q]]; %#ok
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

