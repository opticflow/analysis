function v = selectKthMatlab(V, k)
% select the kth smallest value in V.

% float select(unsigned long k, unsigned long n, float arr[])
% Returns the kth smallest value in the array arr[1..n]. The input array will be rearranged
% to have this value in location arr[k], with all smaller elements moved to arr[1..k-1] (in
% arbitrary order) and all larger elements in arr[k+1..n] (also in arbitrary order).
% {
l = 1;
ir = length(V);
while true,
    if ir <= l+1, % Active partition contains 1 or 2 elements
        if ir == l+1 && V(ir) < V(l),
            %swap(V(ir),V(l));
            tmp = V(ir);
            V(ir) = V(l);
            V(l) = tmp;
        end
        v = V(k);
        return
    else
        mid = floor(bitsra(l+ir,1));
        %swap(V(mid),V(l+1))
        tmp = V(mid);
        V(mid) = V(l+1);
        V(l+1) = tmp;
        if V(l) > V(ir),
            %swap(V(l),V(ir))
            tmp = V(l);
            V(l) = V(ir);
            V(ir) = tmp;
        end
        if V(l+1) > V(ir),
            %swap(V(l+1),V(ir))
            tmp = V(l+1);
            V(l+1) = V(ir);
            V(ir) = tmp;
        end
        if V(l) > V(l+1),
            %swap(V(l),V(l+1))
            tmp = V(l);
            V(l) = V(l+1);
            V(l+1) = tmp;
        end
        i = l + 1;
        j = ir;
        a = V(l+1);
        while true,
            i = i + 1;
            while V(i) < a, i = i + 1; end
            j = j - 1;
            while V(j) > a, j = j - 1; end           
            if j < i,
                break;
            end
            %swap(V(i),V(j))
            tmp = V(i);
            V(i) = V(j);
            V(j) = tmp;
        end
        V(l+1) = V(j);
        V(j) = a;        
        if j >= k, 
            ir = j - 1;
        end
        if j <= k,
            l = i;
        end
    end
end