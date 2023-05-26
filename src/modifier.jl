export Modifier
export make_string, make_modifier, make_modifier_vector, main_mod, n_mods;
export key_value;

"""
	$(SIGNATURES)

Modifier for a `Case` or `Experiment`. Can be a `Symbol`, such as `:openAdmission`, or a `Tuple`, such as `(:capacityUp, 10)`.
"""
struct Modifier{T}
    m :: T
end

"""
	$(SIGNATURES)

Return main modifier.
"""
main_mod(x :: Modifier{T}) where T = x.m[1];
main_mod(x :: Modifier{Symbol}) = x.m;

"""
	$(SIGNATURES)

Return number of modifiers.
"""
n_mods(x :: Modifier{T}) where T = length(x.m);
n_mods(x :: Modifier{Symbol}) = 1;

function find_main_mod(xV :: AbstractVector, mainMod :: Symbol)
    if isempty(xV)
        return nothing
    else
        # matchV = [main_mod(x) == mainMod  for x in xV];
        j = findfirst(x -> main_mod(x) == mainMod,  xV);
        if isnothing(j)
            return nothing
        else
            return xV[j]
        end
    end
end


"""
    $(SIGNATURES)

Extract a key value from a Modifier.
The modifier contains (key, value) pairs.

# Example
```
keyName = :x;
mod1 = Modifier([:a, :x, 2.0, :b]);
key_value(keyName, mod1) == 2.0;
```
"""
function key_value(keyName, mod1 :: Modifier{T}) where T
    idx = findfirst(x -> (x .== keyName), mod1.m);
    if isnothing(idx)
        return nothing;
    else
        return mod1.m[idx + 1]
    end
end

key_value(keyName, mod1 :: Modifier{Symbol}) = nothing;


"""
	$(SIGNATURES)

Make a Modifier or pass through an existing one.
"""
make_modifier(x :: Modifier{T}) where T = x;
make_modifier(x :: T) where T = Modifier(x);

"""
	$(SIGNATURES)

Convert a Vector of anything into a Vector of Modifier.
"""
function make_modifier_vector(v :: AbstractVector)
    if isempty(v)
        return Vector{Modifier}();
    else
        return sort([make_modifier(x)  for x in v]);
    end
end

make_modifier_vector(v :: AbstractVector{Modifier}) = sort(v);


Base.show(io :: IO, m :: Modifier{T}) where T = 
    print(io, make_string(m));


## ------------  String representation

"""
	$(SIGNATURES)

String representation of a `Modifier`. 
Note: These are used to generate file names. Avoid dashes. Longleaf does not like them.

# Example
```julia
make_string(Modifier((:workStudyPrefScale, 2.0))) == "workStudyPrefScale2p0"
```
"""
make_string(m :: Modifier{Symbol}) = string(m.m);

function make_string(m :: Modifier{T1}) where T1 
    return join(make_string.(m.m), "");
end

function make_string(m :: Modifier{Tuple{Symbol, T}}) where T <: Integer
    return make_string(m.m);
end

# 1.0 => "1p0"
make_string(m :: Real) = replace(string(m), "." => "p");
make_string(m :: Symbol) = string(m);

# Ints stay Ints
function make_string(m :: Tuple{Symbol,T1}) where T1 <: Integer
    return "$(m[1])$(m[2])";
end

# Floats get rounded
function make_string(m :: Tuple{Symbol,T1}) where T1 <: Real
    s2 = make_string(m[2]);
    return "$(m[1])$(s2)";
end


function make_string(mods :: AbstractVector{Modifier})
    modStr = join(make_string.(mods), Connector);
end



## -----------  Access

# So we can sort a Modifier vector.
Base.isless(m1 :: Modifier{T1}, m2 :: Modifier{T2}) where {T1, T2} = 
    Base.isless(make_string(m1), make_string(m2));

Base.isequal(m1 :: Modifier{T1}, m2 :: Modifier{T1}) where T1 = 
    Base.isequal(m1.m, m2.m);
Base.isequal(m1 :: Modifier{T1}, m2 :: Modifier{T2}) where {T1, T2} = 
    false;

Base.getindex(m :: Modifier{T1}, idx) where T1 = m.m[idx];


# ----------------