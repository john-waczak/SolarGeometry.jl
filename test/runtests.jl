using SolarGeometry
using Dates: DateTime, second
using Test

@testset "SolarGeometry.jl" begin
    # Write your tests here.
    dt = DateTime(1990, 4, 19, 0, 0, 0)
    az, alt = solar_azimuth_altitude(dt, 60.0, 15.0, 0)
    @test isapprox(az, 15.68, atol=0.01)
    @test isapprox(alt, -17.96, atol=0.01)


    # test out second version
    Δt = 1.0
    dt2 = DateTime(1990, 4, 19, 0, 0, 1)
    println(dt)
    println(dt2)
    az, alt = solar_azimuth_altitude(Δt, dt, 60.0, 15.0, 0)
    az2, alt2 = solar_azimuth_altitude(dt2, 60.0, 15.0, 0)
    @test isapprox(az,az2, rtol=1e-3)
    @test isapprox(alt,alt2, rtol=1e-3)
end



