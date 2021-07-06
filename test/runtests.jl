using CasesLH
using Test

@testset "CasesLH.jl" begin
    include("modifier_test.jl");
    include("case_spec_test.jl");
end
