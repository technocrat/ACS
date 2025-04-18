# Estimate retrieval functions

"""
    get_acs5(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        output_type::Symbol = :dataframe
    )

Fetch estimates from American Community Survey 5-year estimates.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `output_type`: Symbol indicating output type (:dataframe, :structarray, :namedtuples, or :columnar)

# Returns
Data in the requested format

# Example
```julia
# Get total population for all states as a DataFrame
df = get_acs5(
    variables = ["B01003_001E"],
    geography = "state"
)

# Get as a StructArray
sa = get_acs5(
    variables = ["B01003_001E"],
    geography = "state",
    output_type = :structarray
)
```
"""
function get_acs5(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    output_type::Symbol = :dataframe
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
    
    # Validate all variables end with 'E' for estimates
    if !all(v -> endswith(v, "E"), variables)
        throw(ArgumentError("All variables must end with 'E' for estimates"))
    end
    
    # Validate year range for 5-year ACS
    if year < 2009
        throw(ArgumentError("5-year ACS support begins with 2009 (2005-2009 5-year ACS)"))
    end

    # Fetch raw data
    data = fetch_census_data(
        variables = variables,
        geography = geography,
        year = year,
        survey = "acs5",
        state = state,
        county = county
    )

    # Convert to requested output type
    if output_type == :dataframe
        return as_dataframe(data)
    elseif output_type == :structarray
        return as_structarray(data)
    elseif output_type == :namedtuples
        return as_namedtuples(data)
    elseif output_type == :columnar
        return as_columnar(data)
    else
        throw(ArgumentError("Invalid output_type: $output_type. Must be one of :dataframe, :structarray, :namedtuples, or :columnar"))
    end
end

"""
    get_acs1(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        output_type::Type{T} = DataFrame
    ) where T

Fetch estimates from American Community Survey 1-year estimates.
Only available for geographies with populations of 65,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2023)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `output_type`: Type of output (DataFrame, StructArray, Vector{NamedTuple}, or NamedTuple{Vector})

# Returns
Data in the requested format

# Example
```julia
# Get total population for all states as a DataFrame
df = get_acs1(
    variables = ["B01003_001E"],
    geography = "state"
)

# Get as a StructArray
sa = get_acs1(
    variables = ["B01003_001E"],
    geography = "state",
    output_type = StructArray
)
```
"""
function get_acs1(;
    variables::Vector{String},
    geography::String,
    year::Int = 2023,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    output_type::Type{T} = DataFrame
) where T
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
    
    # Use same implementation as get_acs5 but with acs1 endpoint
    return get_acs5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county,
        output_type = output_type
    )
end

"""
    get_acs3(;
        variables::Vector{String},
        geography::String,
        year::Int = 2013,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        output_type::Type{T} = DataFrame
    ) where T

Fetch estimates from American Community Survey 3-year estimates.
Only available from 2007-2013 for geographies with populations of 20,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (2007-2013)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `output_type`: Type of output (DataFrame, StructArray, Vector{NamedTuple}, or NamedTuple{Vector})

# Returns
Data in the requested format

# Example
```julia
# Get total population for all states in 2013 as a DataFrame
df = get_acs3(
    variables = ["B01003_001E"],
    geography = "state",
    year = 2013
)

# Get as a Vector{NamedTuple}
nts = get_acs3(
    variables = ["B01003_001E"],
    geography = "state",
    year = 2013,
    output_type = Vector{NamedTuple}
)
```
"""
function get_acs3(;
    variables::Vector{String},
    geography::String,
    year::Int = 2013,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    output_type::Type{T} = DataFrame
) where T
    # Validate year range for 3-year ACS
    if year < 2007 || year > 2013
        throw(ArgumentError("3-year ACS is only available from 2007-2013"))
    end
    
    @info "The 3-year ACS provides data for geographies with populations of 20,000 and greater."
    
    # Use same implementation as get_acs5 but with acs3 endpoint
    return get_acs5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county,
        output_type = output_type
    )
end

"""
    get_acs(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        survey::String = "acs5",
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        output_type::Type{T} = DataFrame
    ) where T

Main interface to fetch data from the American Community Survey.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2023)
- `survey`: Survey type ("acs1", "acs3", or "acs5", default: "acs5")
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `output_type`: Type of output (DataFrame, StructArray, Vector{NamedTuple}, or NamedTuple{Vector})

# Returns
Data in the requested format

# Example
```julia
# Get total population for all states using 5-year estimates as a DataFrame
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs5"
)

# Get as a StructArray
sa = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs5",
    output_type = StructArray
)
```
"""
function get_acs(;
    variables::Vector{String},
    geography::String,
    year::Int = 2023,
    survey::String = "acs5",
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    output_type::Type{T} = DataFrame
) where T
    # Validate survey type
    if !in(survey, ["acs1", "acs3", "acs5"])
        throw(ArgumentError("Invalid survey type: $survey. Must be 'acs1', 'acs3', or 'acs5'"))
    end
    
    # Route to appropriate function based on survey type
    if survey == "acs1"
        return get_acs1(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county,
            output_type = output_type
        )
    elseif survey == "acs3"
        return get_acs3(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county,
            output_type = output_type
        )
    else  # acs5
        return get_acs5(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county,
            output_type = output_type
        )
    end
end 