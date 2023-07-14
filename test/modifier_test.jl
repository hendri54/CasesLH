using CasesLH, Test

mdl = CasesLH;

function modifier_test()
    @testset "Modifier" begin
        m1 = Modifier((:a, 1));
        s1 = make_string(m1);
        @test isequal(s1, "a1");

        m2 = Modifier((:a, 1.0));
        s2 = make_string(m2);
        @test isequal(s2, "a1p0");

        m4 = Modifier((:entryPrefScale, 2));
        @test isequal(make_string(m4), "entryPrefScale2");
        @test isequal(m4[2], 2);

        m3 = Modifier(:a);
        @test isequal(make_string(m3), "a");

        m4 = Modifier((:x, :y));
        @test isequal(make_string(m4), "xy");

        @test isequal(make_modifier((:z, 2)), Modifier((:z, 2)));
        @test isequal(make_modifier(m3), m3);
    end
end

@testset "Modifier" begin
    modifier_test();
end

# -------------