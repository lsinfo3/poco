% findFullCoveragePlacements
function [solution,k,islands]=findFullCoveragePlacements(topology,maxnumb,maxk,mink)
mydist=allToAllShortestPathMatrix(topology);
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

if ~exist('maxnumb','var')
    maxnumb=2;
end

if ~exist('maxk','var')
    maxk=10;
end
if ~exist('mink','var')
    mink=1;
end

%% SPEED UP 1 create islands based on failure cases
islands=[];
for i=(maxnumb):(-1):1
    fprintf('Considering all combinations of %d node failure(s)',i);
    try
        nkb=combnk(1:size(mydist,1),i); % select broken nodes
    catch ME
        idSegLast = regexp(ME.identifier, '(?<=:)\w+$', 'match');
        %clean up for possible error conditions here. Rethrow if unknown error.
        switch idSegLast{1}
            case 'nomem'
                %out of memory - too large set of failure scenarios
                disp('Out of memory. Too large set of failure scenarios');
                solution=[];
                return
            otherwise
                %An unexpected error happened
                rethrow(ME);
        end
    end
    tic; % limit island creation to 1500 secs per (25 min), if not done escape
    for j=1:size(nkb,1)
        toctemp=toc;
        if toctemp>1500
            fprintf('Out of time. Too long runtime (%d (current) >= 1500 sec)\n',floor(toctemp));
            solution=[]; % took too long
            return;
        end
        if j>100 && (toctemp/j)*size(nkb,1)>1500
            fprintf('Out of time. Too long runtime (%d (estimated) >= 1500 sec)\n',floor((toctemp/j)*size(nkb,1)));
            solution=[]; % took too long
            return;
        end
        if mod(j,ceil(size(nkb,1)/10))==0
            fprintf('.');
        end
        topologyreduced=topology;
        topologyreduced(nkb(j,:),:)=Inf;
        topologyreduced(:,nkb(j,:))=Inf;
        mydistreduced=allToAllShortestPathMatrix(topologyreduced);
        for m=1:length(nkb(j,:))
            mydistreduced(nkb(j,m),nkb(j,m))=Inf;
        end
        countaccess=0;
        for m=1:size(mydistreduced,1)
            if length(find(mydistreduced(m,:)~=inf))==1
                mydistreduced(m,:)=Inf;
                mydistreduced(:,m)=Inf;
                countaccess=countaccess+1;
            end
        end
        if matlabVersion < 2013
            islands=unique([islands;mydistreduced==inf],'rows'); % !!!explanation: islands consist of all nodes being a zero entry
        else
            islands=unique([islands;mydistreduced==inf],'rows','legacy'); % !!!explanation: islands consist of all nodes being a zero entry
        end
    end
    fprintf('\n');
end
% remove empty island
islands=islands(sum(islands,2)<size(topology,1),:);

%% SPEED UP 2 remove larger islands if smaller islands exist
islandsout=[];
for i=1:size(islands,1)
    append=1;
    delidx=[];
    for j=1:size(islandsout,1)
        mypat=islands(i,:)-islandsout(j,:);
        minpat=min(mypat);
        maxpat=max(mypat);
        if(minpat>-1 && maxpat<1) % gleich
            append=1;
            break;
        end
        if(maxpat<1) % islandsout hat immer nur größere oder gleiche Werte, also wenigergroße oder gleichgroße Inseln
            append=0;
            break;
        end
        if(minpat>-1) % nie schlechter
            delidx(end+1)=j;
        end
    end
    if matlabVersion < 2013
        remainidx=setdiff(1:size(islandsout,1),delidx);
    else
        remainidx=setdiff(1:size(islandsout,1),delidx,'legacy');
    end    
    islandsout=islandsout(remainidx,:);
    if append
        islandsout(end+1,:)=islands(i,:);
    end
end
islands=islandsout;

%% SPEED UP 3 remove all nodes that are not on any island as these nodes are no necessary controller candidates
remainidx=find(sum(islands,1)<size(islands,1));
islands=islands(:,remainidx);

%% SPEED UP 4 create all possible worst case solutions and remove double
% entries and controllers

fprintf('Worst case: k=%d, %d solutions', size(islands,1),prod(sum(islands==0,2)));


try
    if prod(sum(islands==0,2))<1e8

        % create all solutions
        nk=find(~islands(1,:))'; % find all entries of island 1
        for i=2:size(islands,1)
            placei=find(~islands(i,:))'; % find all entries of island i
            if matlabVersion < 2013
                nk=unique(sort([repmat(nk,length(placei),1) reshape(repmat(placei,1,size(nk,1))',length(placei)*size(nk,1),1)],2),'rows'); 
            else
                nk=unique(sort([repmat(nk,length(placei),1) reshape(repmat(placei,1,size(nk,1))',length(placei)*size(nk,1),1)],2),'rows'); 
            end
            % create all combinations of 1 entry per island
            fprintf('.');
        end

        %             nk

        % remove double entries
        temp=sum(diff(sort(nk,2),1,2)>0,2)+1;
        k=min(temp);
        temp=remainidx(nk(temp==k,:));
        solution=zeros(size(temp,1),k);
        for i=1:size(temp,1)
            if matlabVersion < 2013
                solution(i,:)=unique(temp(i,:));
            else
                solution(i,:)=unique(temp(i,:),'legacy');
            end
        end
        if matlabVersion < 2013
            solution=unique(solution,'rows');
        else
            solution=unique(solution,'rows','legacy');
        end
        fprintf('\nSuccessfull with k=%d, %d solutions\n',k,size(solution,1));
        return;
    end
catch ME
    idSegLast = regexp(ME.identifier, '(?<=:)\w+$', 'match');
    %clean up for possible error conditions here. Rethrow if unknown error.
    switch idSegLast{1}
        case 'nomem'
            %out of memory - try for loop approach
            disp('\nOut of memory. Cannot be solved that way, try for loop.');
        otherwise
            %An unexpected error happened
            rethrow(ME);
    end
end

% for k=mink:maxk
%     fprintf('Trying k=%d ',k);
%     try
%         nk=combnk(1:size(islands,2),k);
%         avgarray=plotcombs(islands,nk);
%     catch ME
%         idSegLast = regexp(ME.identifier, '(?<=:)\w+$', 'match');
%         %clean up for possible error conditions here. Rethrow if unknown error.
%         switch idSegLast{1}
%             case 'nomem'
%                 %out of memory
%                 disp('Out of memory. Cannot be solved that way, return [].')
%                 solution=[];
%                 return;
%             otherwise
%                 %An unexpected error happened
%                 rethrow(ME)
%         end
%     end
%     %     min(avgarray)
%     if ~isempty(find(avgarray==0,1))
%         solution=unique(remainidx(nk(avgarray==0,:)),'rows');
%         fprintf('successfull, %d solutions\n',size(solution,1));
%         return;
%     end
%     fprintf('not successfull, %.2d%% percent of islands covered\n',100-ceil(min(avgarray)*100));
% end
end
