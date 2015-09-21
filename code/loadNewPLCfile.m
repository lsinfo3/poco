function [topology,latlong,tm,nodenames]=loadNewPLCfile(fileid)
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

globalTopology=load('planetlab/selectedNodesAdv.mat');
% Load RTT to create variable topology
if nargin<1
    fidRTT=fopen('planetlab/currentPLC.csv');
else 
    fidRTT=fopen(['localbackup/rttglobal_' num2str(fileid)  '.csv']);
end
if fidRTT>0
    dataRTT=textscan(fidRTT,'%[^;];%[^;];%f','TreatAsEmpty','None');
    fclose(fidRTT);

    src=dataRTT{1};
    dst=dataRTT{2};
    rtt=dataRTT{3};
    if matlabVersion < 2013
        [src_u,tildevar,srcidx]=unique([src;globalTopology.nodeIPs]);
        [dst_u,tildevar,dstidx]=unique([dst;globalTopology.nodeIPs]);
    else 
        [src_u,tildevar,srcidx]=unique([src;globalTopology.nodeIPs],'legacy');
        [dst_u,tildevar,dstidx]=unique([dst;globalTopology.nodeIPs],'legacy');
    end
    topology=nan(length(src_u),length(dst_u));
    topology(sub2ind(size(topology),srcidx(1:length(rtt)),dstidx(1:length(rtt))))=rtt;

    cpuidx=find(~cellfun(@isempty,strfind(dst_u,'CPU')));

    % create tm
    if ~isempty(cpuidx)
        tm=topology(:,cpuidx)';
    else
        tm=[];
    end

    % remove CPU column from topology as well as all other strange/unknown IPs
    if matlabVersion < 2013
        [src_filtered,srcidx]=intersect(src_u,globalTopology.nodeIPs);
        [dst_filtered,dstidx]=intersect(dst_u,globalTopology.nodeIPs);
    else
        [src_filtered,srcidx]=intersect(src_u,globalTopology.nodeIPs,'legacy');
        [dst_filtered,dstidx]=intersect(dst_u,globalTopology.nodeIPs,'legacy');
    end
    topology=topology(srcidx,dstidx);
    tm=tm(srcidx);


    [tildevar,idx]=sort(globalTopology.nodeIPs);
    nodenames=globalTopology.nodenames(idx);
    latlong=globalTopology.latlong(idx,:);
else %file does not exist
    topology=[];
    latlong=[];
    tm=[];
    nodenames={};
end