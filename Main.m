% This code belongs to Furkan Kaya. Student number is 191216002. 
function Main()
    msg = importdata("Mesaj.txt");
    msg = cell2mat(msg);
    msgLen = length(msg);
    
    addedZeroLen = 0;
    
    p1 = [1,0,0,1,1,0,1,0,1,1,1];
    p2 = [1,1,0,1,0,1,1,1,1,0,0];
    p3 = [0,1,1,0,1,0,1,1,1,1,0];
    p4 = [0,0,1,1,0,1,0,1,1,1,1];
    A = [p1;p2;p3;p4];
    AT = transpose(A);
    G = [eye(11),AT];
    H = [A, eye(4)];
    frame = [0,1,1,1,1,1,1,1,1,0];
    
    
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

    function flattenArr = ReturnArrFlat(arr)
        flattenArr = [];
        for k = arr
            flattenArr = [flattenArr, transpose(k(1:end))];
        end
    end

    function withBurstError = ReturnBrokenArray(arr)
        for i=235:249
            arr(i) = mod(arr(i)+1, 2);
        end
        withBurstError = arr;
    end

    itemCounts = ReturnItemCountMap(msg);
    itemPs = ReturnItemProbMap(itemCounts);

    [dict, avglen] = huffmandict(keys(itemPs), cell2mat(values(itemPs)));
    
    huffEncoded = huffmanenco(msg, dict);
    if (mod(length(huffEncoded),11) ~= 0)
        remain = 11 - mod(length(huffEncoded), 11);
        addedZeroLen = remain;
        huffEncoded = [huffEncoded, zeros(1, remain)];
    end
    reshapedArr = reshape(huffEncoded, length(huffEncoded)/11, 11);
    encodedMessage = mod(reshapedArr*G, 2);
    interLeavedMessage = ReturnArrFlat(encodedMessage);
    finalMessage = [frame, interLeavedMessage];
    randomInt = randi([1 100]);
    randomBinary = de2bi(randomInt);
    finalWrandom = [randomBinary, finalMessage];
    withBurstError = ReturnBrokenArray(finalWrandom);
    
    %-----------------------------------------------------%
    sendrom = H * transpose(eye(15));
    
    function frameDeleted = DeleteBeforeFrame(arr, frame)
        index = 1;
        frameLen = length(frame);
        while(1)
            if(index>=length(arr)) 
                break;
            end
            if(arr(index:index+frameLen-1)==frame)
                index = index+frameLen;
                break;
            end
            index=index+1;
        end
        frameDeleted = arr(index:end);
    end

    frameDeleted = DeleteBeforeFrame(withBurstError, frame);
    reshaped2 = reshape(frameDeleted, length(frameDeleted)/15, 15);
    errors = mod(H*transpose(reshaped2),2);
    
    function indexNumber = GetIndexNumber(arr, item)
        indexNumber = 0;
        for a=arr
            indexNumber=indexNumber+1;
            if(a==item)
                break;
            end
        end
    end
    function fixedArr = FixErrorInArr(arr)
        counter = 1;
        for k=errors
            if(ismember(1,k))
                erroredBit = GetIndexNumber(sendrom, k);
                erroredRow = counter;
                arr(erroredRow, erroredBit) = mod(arr(erroredRow, erroredBit)+1,2);
            end
            counter=counter+1;
        end
        fixedArr=arr;
    end

    fixed = FixErrorInArr(reshaped2);
    errors2 = mod(H*transpose(fixed),2);
    
    %delete paradi columns
    fixed(:,[12, 13, 14, 15]) = [];
    fixed = ReturnArrFlat(fixed);
    fixed = fixed(1:end-addedZeroLen);
    
    encoded = huffmandeco(fixed, dict);
    
    cell2mat(encoded)
    msg
    
    
end
