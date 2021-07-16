export CaseSpec, BaseMods, XpMods
export make_case_spec, has_mods, get_mods, has_modifier, find_main_mod, replace_mods, base_name, modifier_string, add_modifier
export has_xp_mods, get_xp_mods, has_xp_modifier, replace_xp_mods, remove_xp_mods, exper_string
export case_fn

struct BaseMods end
struct XpMods end


"""
	$(SIGNATURES)

Contains base name and a list of (sorted) modifications.

Note: The order of modifiers does not matter. They are always sorted.
"""
struct CaseSpec
    baseName :: Symbol
    mods :: Vector{Modifier}
    xpMods :: Vector{Modifier}

    # Inner constructor ensures that mods are sorted
    function CaseSpec(bn :: Symbol, modInV :: AbstractVector, 
        xpModV :: AbstractVector)
        cn = new(bn, make_modifier_vector(modInV), make_modifier_vector(xpModV));
        return cn
    end
end

# No modifiers. No experiment.
# Symbol first. Then the rest is experiment.
function CaseSpec(bn :: Symbol, xpModV = Vector{Modifier}())
    return CaseSpec(bn, Vector{Modifier}(), xpModV);
end

CaseSpec(bn :: Symbol, xpMod :: Modifier{T}) where T = 
    CaseSpec(bn, [xpMod]);

# 2 vectors are interpreted as [base], [experiment]
function CaseSpec(cv :: AbstractVector, xpV :: AbstractVector = Vector{Modifier}())
    baseName = cv[1];
    @assert (baseName isa Symbol)  "Invalid CaseSpec: $cv";
    if length(cv) > 1
        return CaseSpec(baseName,  cv[2 : end], xpV);
    else
        return CaseSpec(baseName, Vector{Modifier}(), xpV);
    end
end

# Nested vectors are interpreted as ([base], [experiment])
function CaseSpec(vv :: Tuple{T1, Vector{T2}}) where {T1, T2}
    return CaseSpec(vv...);
end

# function CaseSpec(vv :: Tuple{Vector{T1}, Vector{T2}}) where {T1, T2}
#     return CaseSpec(vv...);
# end


"""
	$(SIGNATURES)

A simple pass-through function that makes a `CaseSpec` if needed and passes it through otherwise.
"""
make_case_spec(cn :: CaseSpec) = cn;
# make_case_spec(cn :: Case) = cn.name;
make_case_spec(cn) = CaseSpec(cn);


## --------  Properties

get_mods(cn :: CaseSpec) = cn.mods;
get_xp_mods(cn :: CaseSpec) = cn.xpMods;
get_modifiers(cn :: CaseSpec, ::Type{BaseMods}) = get_mods(cn);
get_modifiers(cn :: CaseSpec, ::Type{XpMods}) = get_xp_mods(cn);

"""
	$(SIGNATURES)

Base name of a CaseSpec.
"""
base_name(cn :: CaseSpec) = cn.baseName;

"""
	$(SIGNATURES)

Does CaseSpec contain modifiers?
"""
has_mods(cn :: CaseSpec) = !isempty(get_mods(cn));

has_xp_mods(cn :: CaseSpec) = !isempty(get_xp_mods(cn));

has_modifiers(cn :: CaseSpec, ::Type{BaseMods}) = has_mods(cn);
has_modifiers(cn :: CaseSpec, ::Type{XpMods}) = has_xp_mods(cn);


"""
	$(SIGNATURES)

Does CaseSpec have a given Modifier?
"""
has_modifier(cn :: CaseSpec, modName) = 
    make_modifier(modName) ∈ get_mods(cn);

has_xp_modifier(cn :: CaseSpec, modName) = 
    make_modifier(modName) ∈ get_xp_mods(cn);

has_modifier(cn :: CaseSpec, ::Type{BaseMods}, modName) = 
    has_modifier(cn, modName);
has_modifier(cn :: CaseSpec, ::Type{XpMods}, modName) = 
    has_xp_modifier(cn, modName);

"""
	$(SIGNATURES)

Find modifier that has the target main modifier. Returns `nothing if not found`.
"""
function find_main_mod(cn :: CaseSpec, mainMod :: Symbol)
    if has_mods(cn)
        return find_main_mod(get_mods(cn), mainMod);
    else
        return nothing
    end
end

function Base.isequal(cn1 :: CaseSpec, cn2 :: CaseSpec)
    return equal_base_names(cn1, cn2)  &&  equal_mods(cn1, cn2)  &&
        equal_xp_mods(cn1, cn2);
end

function equal_base_names(cnV...)
    areEqual = true;
    for cn in cnV
        areEqual = areEqual  &&  isequal(base_name(cn), base_name(cnV[1]));
    end
    return areEqual
end

function equal_modifiers(::Type{T}, cnV...) where T
    areEqual = true;
    hasMods = has_mods(cnV[1]);
    for cn in cnV
        if !hasMods
            areEqual = areEqual  &&  !has_mods(cn);
        else
            areEqual = areEqual  &&  
                isequal(get_modifiers(cn, T), get_modifiers(cnV[1], T));
        end
    end
    return areEqual
end

equal_mods(cnV...) = equal_modifiers(BaseMods, cnV...);
equal_xp_mods(cnV...) = equal_modifiers(XpMods, cnV...);


## -----------  Apply modifiers

replace_mods(cn :: CaseSpec, newMods) =
    CaseSpec(base_name(cn), newMods, get_xp_mods(cn));
replace_xp_mods(cn :: CaseSpec, newMods) =
    CaseSpec(base_name(cn), get_mods(cn), newMods);
remove_xp_mods(cn :: CaseSpec) = replace_xp_mods(cn, Vector{Modifier}());

"""
	$(SIGNATURES)

Add modifiers to an existing CaseSpec. Errors if any of the modifiers already exist.
"""
function add_modifier(cn :: CaseSpec, modName; ignoreExisting = false)
    newMod = make_modifier(modName);
    if has_modifier(cn, newMod)
        if !ignoreExisting
            error("Modifier $modName already exists.");
        end
    else
        return CaseSpec(base_name(cn), vcat(get_mods(cn), newMod), get_xp_mods(cn));
    end
end


## ---------- Show (as string)

"""
	$(SIGNATURES)

String representation of a Case's name. Not used for file names. See `case_fn`.
E.g.: `[Base, Mod1, (Mod2, 2)][xp1, (xp2, 3)]`
"""
function make_string(cn :: CaseSpec)
    return base_case_string(cn) * exper_string(cn);
end

function base_case_string(cn :: CaseSpec; brackets = true)
    s = string(base_name(cn));
    if has_mods(cn)
        s = s * "_" * make_string(get_mods(cn));
    end
    if brackets
        s = "[" * s * "]";
    end
    return s
end

function modifier_string(cn :: CaseSpec; brackets = true)
    if has_mods(cn)
        s = make_string(get_mods(cn));
        if brackets
            s = "[" * s * "]";
        end
    else
        s = "";
    end
    return s
end

function exper_string(cn :: CaseSpec; brackets = true)
    if has_xp_mods(cn)
        s = make_string(get_xp_mods(cn));
    else
        s = "Base";
    end
    if brackets
        s = "[" * s * "]";
    end
    return s
end

Base.show(io :: IO, cn :: CaseSpec) = print(io, make_string(cn));

# Used for file names
function case_fn(cn :: CaseSpec)
    return base_case_string(cn; brackets = false) * "_XP_" * 
        exper_string(cn; brackets = false);
end



# """
# 	$(SIGNATURES)

# Return modifiers as a string of the form "mod1_mod2". Only for the base Case, excluding the experiments.
# """
# function modifier_string(cn)
#     cn = make_case_spec(cn);
#     if !has_mods(cn)
#         return ""
#     else
#         modStr = join(make_string.(cn.mods), "_");
#         return modStr
#     end
# end


# function command_string(symV :: AbstractVector{Symbol})
#     if length(symV) == 1
#         return command_string(symV[1]);
#     else
#         return "[" * join(command_string.(symV), ",") * "]";
#     end
# end

# command_string(s :: Symbol) = ":" * string(s);


# function command_argument(cn :: CaseSpec)
    # strV = string_vector(cn, prefixStr = ":");
    # str1 = strV[1];
    # if length(strV) > 1
    #     str1 = "[" * str1;
    #     for j = 2 : length(strV)
    #         str1 = str1 * ", " * strV[j];
    #     end
    #     str1 = str1 * "]";
    # end
    # return str1
# end


# function string_vector(cn :: CaseSpec; prefixStr = "")
#     n = 1 + length(cn.mods);
#     strV = Vector{String}(undef, n);
#     strV[1] = prefixStr * String(cn.CaseSpec);
#     if n > 1
#         for j = 2 : n
#             strV[j] = prefixStr * make_string(cn.mods[j-1]);
#         end
#     end
#     return strV
# end


# ---------------