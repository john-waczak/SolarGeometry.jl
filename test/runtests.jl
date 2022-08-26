using SolarGeometry
using Dates: DateTime
using Test

@testset "SolarGeometry.jl" begin
    # Write your tests here.
    dt = DateTime(1990, 4, 19, 0, 0, 0)
    az, alt = solar_azimuth_elevation(dt, 60.0, 15.0, 0)
    @test isapprox(az, 15.68, atol=0.01)
    @test isapprox(alt, -17.96, atol=0.01)
end



