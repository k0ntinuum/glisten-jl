using Random
using Printf
using LinearAlgebra


key(n) = copy(transpose(reduce(hcat, [Random.randperm(n) for i in 1:n])))

str_from_vec(v)  = join(map(i -> alph[i:i], v))

function print_key(k)
	for i in 1:n print(join(map(i -> alph[i:i]*" ", k[i,:])),"\n") end
	print("\n")
end

str_from_vec(v,c)  = join(map(i -> alph[i+1:i+1]*c, v))

vec_from_str(s) = map(i -> findfirst(isequal(i),alph),collect(s))

rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);
yellow() = rgb(255,255,0);
white() = rgb(255,255,255);
gray(h) = rgb(h,h,h)

function encode(p,q)
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
    for i in 1:r
        for j in 1:n
            k[j,:] = map(x -> mod1(x+k[j,j],n), k[j,:])
        end
    end
    k
end

function encrypt(p, q, r)
    for i in 1:r
        k = spin(q,i)
        p = encode(p,k)
        p = reverse(p)
    end
    p
end

function decrypt(c, q, r)
    for i in 1:r
        k = spin(q,r + 1 - i)
        #print(k,"\n")
        c = reverse(c)
        c = decode(c,k)
    end
    c
end



function demo()
    print(white(),"k = \n", gray(155))
    print_key(k)
    print(gray(155),"r = ",r,"\n\n")
    for i in 1:20
        p = Random.randperm(n)
        c = encrypt(p,k,r)
        d = decrypt(c,k,r)
        print(white(),"f( ", red(), str_from_vec(p),white()," ) = ")
        print(yellow(), str_from_vec(c),white(),"\n")
        if p != d @printf "ERROR\n\n" end
    end
end


alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
n = length(alph)
k = key(n)
r = 5
