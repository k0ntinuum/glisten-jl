using Random
using Printf
using LinearAlgebra

function key(n)
    copy(transpose(reduce(hcat, [Random.randperm(n) for i in 1:n])))
end


function print_key(k)
    n = size(k)[begin]
	for i in 1:n print(str_from_vec( k[i,:]," " ),"\n") end
	print("\n")
end

function rgb(r,g,b)
    "\e[38;2;$(r);$(g);$(b)m"
end

function red()
    rgb(255,0,0)
end

function yellow()
    rgb(255,255,0)
end

function white()
    rgb(255,255,255)
end

function gray(h)
    rgb(h,h,h)
end

function str_from_vec(v,c)
    #alph = "O|"
    alph = "abcdefghijklmnopqrstuvwxyz"
    join(map(i -> alph[i:i]*c, v))
end



function encode(p,q)
    n = size(q)[begin]
    k = copy(q)
    c = Int64[]
    m = 1
    for i in eachindex(p)
        push!(c, k[m,p[i]])
        k[p[i],:] = map(x -> mod1(x+c[i],n), k[p[i],:])
        m = c[i]
    end
    c
end

function decode(c,q)
    n = size(q)[begin]
    k = copy(q)
    p = Int64[]
    m = 1
    for i in eachindex(c)
        push!(p, findfirst(isequal(c[i]),k[m,:])) 
        k[p[i],:] = map(x -> mod1(x+c[i],n), k[p[i],:])
        m = c[i]
    end
    p
end

function spin(q,r)
    k = copy(q)
    n = size(q)[begin]
    for i in 1:r
        for j in 1:n
            k[j,:] = map(x -> mod1(x+k[j,j],n), k[j,:])
        end
    end
    k
end

function encrypt(p, q)
    n = size(q)[begin]
    for i in 1:n
        k = spin(q,i)
        p = encode(p,k)
        p = reverse(p)
    end
    p
end

function decrypt(c, q)
    n = size(q)[begin]
    for i in 1:n
        k = spin(q,n + 1 - i)
        c = reverse(c)
        c = decode(c,k)
    end
    c
end



function demo()
    n = 26
    k = key(n)
    print(white(),"k = \n", gray(155))
    print_key(k)
    for i in 1:20
        p = Random.randperm(n)
        #p = rand(1:n,24)
        c = encrypt(p,k)
        d = decrypt(c,k)
        print(white(),"f( ", red(), str_from_vec(p,""),white()," ) = ")
        print(yellow(), str_from_vec(c,""),white(),"\n")
        if p != d @printf "ERROR\n\n" end
    end
end
