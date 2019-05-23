%% Now filter function captures 3 groups: filter name, filter value
function [handle] = filterEth(ethArr, filterStr)
tic;   
    expression = '(eth\.(?:src|dst))\s*(==|!=)\s*((?:[\d\w]{2}:){5}[\d\w]{2})';
    [tokens, matches] = regexp(filterStr,expression,'tokens','match');
    findObjFilter = {};
    i = 1;
    if ~isempty(tokens)
        while i<=length(tokens)
            filterName = tokens{i}{1};
            equalSign = tokens{i}{2};
            if strcmp(equalSign,'!=')
                equalRule = '-not';
            else
                equalRule = '-and';
            end         
            if isempty(findObjFilter)
                findObjFilter = {equalRule};
            else 
                findObjFilter = {findObjFilter; equalRule};
            end            
            switch filterName
                case 'eth.src'                    
                    srcMac = strsplit(tokens{i}{3},':');
                    srcMacDec = hex2dec(srcMac);                    
                    findObjFilter = {findObjFilter{:}; 'srcMac'; srcMacDec};
                case 'eth.dst'                    
                    dstMac = strsplit(tokens{i}{3},':');
                    dstMacDec = hex2dec(dstMac);
                    findObjFilter = {findObjFilter{:}; 'dstMac'; dstMacDec};
            end
            i = i + 1;
        end
        handle = findobj (ethArr,findObjFilter{:})';
toc        
    end
end