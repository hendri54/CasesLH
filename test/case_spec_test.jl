using CasesLH, Test

function case_spec_test()
    @testset "CaseSpec" begin
        c1 = CaseSpec(:a);
        @test !has_mods(c1);
        @test !has_xp_mods(c1);
        @test !has_modifier(c1, :a);
        @test isequal(c1, CaseSpec(:a));
        @test isequal(make_case_spec(:a), c1);
        @test isequal(make_string(c1), "[a][Base]");
        @test isequal(case_fn(c1), "a_XP_Base");

        c2 = CaseSpec([:a, :b, :c])
        @test has_mods(c2);
        @test !has_xp_mods(c2);
        @test isequal(get_mods(c2), [Modifier(:b), Modifier(:c)])
        @test has_modifier(c2, :b)
        @test isequal(make_case_spec(c2), c2)
        @test isequal(make_string(c2), "[a_b_c][Base]");
        

        c3 = CaseSpec([:a, :c, :b]);
        @test isequal(make_case_spec(c2), make_case_spec(c3))
        @test length(make_string(c2)) > length(make_string(c1)) > 0

        c4 = CaseSpec(:a, [:b, :c]);
        @test !has_mods(c4);
        @test has_xp_mods(c4);
        @test isequal(make_string(c4), "[a][b_c]");
        @test isequal(case_fn(c4),  "a_XP_b_c");

        c5 = CaseSpec(:a, [(:b, 1), :c]);
        @test isequal(make_string(c5), "[a][b1_c]");

        arg = ([:a, :b], [(:b, 1), :c]);
        c6 = CaseSpec(arg);
        @test isequal(make_string(c6), "[a_b][b1_c]");
        @test isequal(c6, make_case_spec(arg));

        c7 = CaseSpec(arg);
        c7a = replace_xp_mods(c7, [:d, :e]);
        @test isequal(make_string(c7a), "[a_b][d_e]");

        arg = (:a, [(:b, 1), :c]);
        c6a = CaseSpec(arg);
        @test isequal(make_string(c6a),  make_string(c5));

        c7 = CaseSpec(arg);
        c7b = replace_mods(c7, [:d, :e]);
        @test isequal(make_string(c7b), "[a_d_e][b1_c]");

        # strV = string_vector(c1; prefixStr = "-");
        # @test length(strV) == 1
        # @test strV[1] == "-a"

        # strV = string_vector(c3; prefixStr = "-");
        # @test length(strV) == 3
        # @test isequal(strV,  ["-a", "-b", "-c"])
    end
end

function modify_test()
    @testset "Modify" begin
        c1 = CaseSpec(:test, [:two, :three]);
        @test has_xp_mods(c1);
        c2 = remove_xp_mods(c1);
        @test !has_xp_mods(c2);
    end
end

@testset "CaseSpec" begin
    case_spec_test();
    modify_test();
end

# ----------