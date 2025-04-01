module ACS

using DataFrames
using HTTP
using JSON3

# Export main interface functions
export get_acs, get_acs1, get_acs3, get_acs5
export get_acs_moe, get_acs_moe1, get_acs_moe3, get_acs_moe5

# Export helper functions
export state_postal_to_fips, create_geoid

# Export internal functions (for advanced users)
export make_census_request, build_census_url, process_census_response

# Helper functions
include("utils.jl")
include("api.jl")
include("estimates.jl")
include("moe.jl")

end # module 