% This code belongs to Furkan Kaya. Student number is 191216002. 
function Main()
    msg = importdata("Mesaj.txt");
    msg = cell2mat(msg);
    msgLen = length(msg);
    
    function itemP = ReturnItemProbMap(M)
        % This function return probability dict based on symbol count.
        itemP = containers.Map('KeyType','char','ValueType','double');
        for m = keys(M)
            thekey = m{1};
            count = double(M(thekey));
            itemP(thekey) = double(count/msgLen);
        end
    end
    function itemCount = ReturnItemCountMap(l)
        % This function count every symbol in given list.
        itemCount = containers.Map('KeyType','char','ValueType','int32');
        for m = l
            if (isKey(itemCount, m))
                itemCount(m) = itemCount(m) + 1;
                continue;
            end
            itemCount(m) = 1;
        end
    end
    
    itemCounts = ReturnItemCountMap(msg);
    itemPs = ReturnItemProbMap(itemCounts);
    [dict, avglen] = huffmandict(cell2mat(keys(itemPs)), cell2mat(values(itemPs)));
    [dict, avglen]
    %itemCounts("c")
    %itemPs("c")
    
end
