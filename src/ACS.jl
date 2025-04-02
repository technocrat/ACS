module ACS

using DataFrames
using HTTP
using JSON3
using NamedTupleTools
using StructArrays

# Export main interface functions
export get_acs, get_acs1, get_acs3, get_acs5
export get_acs_moe, get_acs_moe1, get_acs_moe3, get_acs_moe5

# Export helper functions
export state_postal_to_fips, create_geoid

# Export internal functions (for advanced users)
export make_census_request, build_census_url, process_census_response

# Include helper functions from src directory
include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "api.jl"))
include(joinpath(@__DIR__, "estimates.jl"))
include(joinpath(@__DIR__, "moe.jl"))

end # module 
