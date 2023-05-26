module CasesLH

using DocStringExtensions

# Best to avoid characters that pose latex typesetting problems.
const OpenBracket = '(';
const CloseBracket = ')';
const Connector = '-';

function inbrackets(s; brackets = true)
    if brackets
        return OpenBracket * s * CloseBracket;
    else
        return s
    end
end

# include("types.jl");
include("modifier.jl");
include("base_case.jl"); # wrong name +++

end
