function [ val ] = nChooseK( n,k )
    val = factorial(n)/(factorial(k) * factorial(n-k));
end

