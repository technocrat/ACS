# Margin of Error functions

"""
    get_acs_moe5(;
        variables::Vector{String},
        geography::String,
        year::Int = 2023,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 5-year estimates.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2023)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states
df = get_acs_moe5(
    variables = ["B01003_001M"],
    geography = "state"
)
```
"""
function get_acs_moe5(;
    variables::Vector{String},
    geography::String,
    year::Int = 2023,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate inputs
    if isempty(variables)
        throw(ArgumentError("Must specify at least one variable"))
    end
    
    if !in(geography, ["state", "county", "tract", "block group"])
        throw(ArgumentError("Invalid geography level: $geography"))
    end
    
    if !isnothing(county) && isnothing(state)
        throw(ArgumentError("County can only be specified with state"))
    end
    
    # Validate all variables end with 'M' for MOE
    if !all(v -> endswith(v, "M"), variables)
        throw(ArgumentError("All variables must end with 'M' for margin of error"))
    end
    
    # Validate year range for 5-year ACS
    if year < 2009
        throw(ArgumentError("5-year ACS support begins with 2009 (2005-2009 5-year ACS)"))
    end
    
    # Build URL
    url = build_census_url(
        variables = variables,
        geography = geography,
        year = year,
        survey = "acs5",
        state = state,
        county = county
    )
    
    # Make request with robust connection handling
    headers = [
        "Accept" => "application/json",
        "Accept-Encoding" => "gzip, deflate, br",
        "Accept-Language" => "en-US,en;q=0.9",
        "Connection" => "keep-alive",
        "User-Agent" => "ACS.jl/0.1.0"
    ]
    
    r = make_census_request(url, headers)
    
    # Process response
    return process_census_response(r, geography)
end

"""
    get_acs_moe1(;
        variables::Vector{String},
        geography::String,
        year::Int = 2023,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 1-year estimates.
Only available for geographies with populations of 65,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2023)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states
df = get_acs_moe1(
    variables = ["B01003_001M"],
    geography = "state"
)
```
"""
function get_acs_moe1(;
    variables::Vector{String},
    geography::String,
    year::Int = 2023,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Check for 2020 1-year ACS restriction
    if year == 2020
        error("""
        The regular 1-year ACS for 2020 was not released and is not available.
        
        Due to low response rates, the Census Bureau instead released a set of experimental estimates for the 2020 1-year ACS.
        
        These estimates can be downloaded at:
        https://www.census.gov/programs-surveys/acs/data/experimental-data/1-year.html
        
        1-year ACS data can still be accessed for other years by supplying an appropriate year to the `year` parameter.
        """)
    end
    
    # Validate year range for 1-year ACS
    if year < 2005
        throw(ArgumentError("1-year ACS support begins with 2005"))
    end
    
    @info "The 1-year ACS provides data for geographies with populations of 65,000 and greater."
    
    # Use same implementation as get_acs_moe5 but with acs1 endpoint
    return get_acs_moe5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    get_acs_moe3(;
        variables::Vector{String},
        geography::String,
        year::Int = 2013,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 3-year estimates.
Only available from 2007-2013 for geographies with populations of 20,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (2007-2013)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states in 2013
df = get_acs_moe3(
    variables = ["B01003_001M"],
    geography = "state",
    year = 2013
)
```
"""
function get_acs_moe3(;
    variables::Vector{String},
    geography::String,
    year::Int = 2013,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate year range for 3-year ACS
    if year < 2007 || year > 2013
        throw(ArgumentError("3-year ACS is only available from 2007-2013"))
    end
    
    @info "The 3-year ACS provides data for geographies with populations of 20,000 and greater."
    
    # Use same implementation as get_acs_moe5 but with acs3 endpoint
    return get_acs_moe5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    get_acs_moe(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        survey::String = "acs5",
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Main interface to fetch margin of error data from the American Community Survey.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `survey`: Survey type ("acs1", "acs3", or "acs5", default: "acs5")
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states using 5-year estimates
df = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state",
    survey = "acs5"
)
```
"""
function get_acs_moe(;
    variables::Vector{String},
    geography::String,
    year::Int = 2023,
    survey::String = "acs5",
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate survey type
    if !in(survey, ["acs1", "acs3", "acs5"])
        throw(ArgumentError("Invalid survey type: $survey. Must be 'acs1', 'acs3', or 'acs5'"))
    end
    
    # Route to appropriate function based on survey type
    if survey == "acs1"
        return get_acs_moe1(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    elseif survey == "acs3"
        return get_acs_moe3(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    else  # acs5
        return get_acs_moe5(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    end
end 