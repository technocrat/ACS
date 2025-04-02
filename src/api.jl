# Census API interaction functions
using Downloads
using HTTP
using JSON3

"""
    make_census_request(url::String, headers::Vector{Pair{String,String}}) -> JSON3.Array

Make a request to the Census API and return the raw JSON response.
"""
function make_census_request(url::String, headers::Vector{Pair{String,String}})
    try
        # Build curl command with headers
        header_args = []
        for (k, v) in headers
            push!(header_args, "-H")
            push!(header_args, "$k: $v")
        end
        
        cmd = `curl -s -L --max-time 180 $header_args $url`
        
        # Run curl and capture output
        output = read(cmd, String)
        
        # Parse and return the raw JSON
        data = JSON3.read(output)
        
        if length(data) < 2
            @warn "No data returned from Census API"
            return nothing
        end
        
        return data
    catch e
        if e isa ProcessFailedException
            error("Census API request failed: $(e.msg)")
        else
            rethrow(e)
        end
    end
end

"""
    fetch_census_data(;
        variables::Vector{String},
        geography::String,
        year::Int,
        survey::String,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> JSON3.Array

Fetch raw data from the Census API. Returns the JSON response directly.
"""
function fetch_census_data(;
    variables::Vector{String},
    geography::String,
    year::Int,
    survey::String,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    url = build_census_url(;
        variables=variables,
        geography=geography,
        year=year,
        survey=survey,
        state=state,
        county=county
    )
    
    headers = [
        "Accept" => "application/json",
        "User-Agent" => "ACS.jl/0.1.0"
    ]
    
    # Try up to 3 times with exponential backoff
    max_retries = 3
    base_delay = 2.0  # seconds
    
    for attempt in 1:max_retries
        try
            data = make_census_request(url, headers)
            if !isnothing(data)
                return data
            end
        catch e
            if attempt == max_retries
                @error "Failed to fetch Census data after $max_retries attempts" exception=e
                return JSON3.Array([])
            end
            
            # Add some jitter to prevent thundering herd
            jitter = rand() * base_delay
            sleep(base_delay * 2^(attempt - 1) + jitter)
            @warn "Retrying Census API request (attempt $attempt of $max_retries)"
        end
    end
    
    return JSON3.Array([])
end

"""
    build_census_url(;
        variables::Vector{String},
        geography::String,
        year::Int,
        survey::String,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> String

Build a Census API URL for the given parameters.
"""
function build_census_url(;
    variables::Vector{String},
    geography::String,
    year::Int,
    survey::String,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Construct base URL
    base_url = "https://api.census.gov/data/$(year)/acs/$(survey)"
    
    # Build GET parameters
    params = String[]
    
    # Add NAME and variables
    push!(params, "get=NAME," * join(variables, ","))
    
    # Add geography
    push!(params, "for=$(geography):*")
    
    # Add state/county filters if specified
    if !isnothing(state)
        # Convert postal code to FIPS if needed
        state_fips = length(state) == 2 ? state_postal_to_fips(state) : state
        push!(params, "in=state:$(state_fips)")
        
        if !isnothing(county)
            push!(params, "in=county:$(county)")
        end
    end
    
    # Add API key - required for all requests
    api_key = get(ENV, "CENSUS_API_KEY", nothing)
    if isnothing(api_key)
        error("Census API key not found in environment. Please set the CENSUS_API_KEY environment variable.")
    end
    push!(params, "key=$(api_key)")
    
    # Construct final URL
    return base_url * "?" * join(params, "&")
end

"""
    as_dataframe(data::JSON3.Array) -> DataFrame

Convert Census API JSON data to a DataFrame.
"""
function as_dataframe(data::JSON3.Array)
    isempty(data) && return DataFrame()
    
    # Convert each row to a vector
    rows = [[x for x in row] for row in data]
    headers = rows[1]
    data_rows = rows[2:end]
    
    # Create a dictionary of columns
    cols = Dict{Symbol,Vector{String}}()
    for (i, header) in enumerate(headers)
        cols[Symbol(header)] = [row[i] for row in data_rows]
    end
    
    # Create DataFrame from columns
    return DataFrame(cols)
end

"""
    as_structarray(data::JSON3.Array) -> StructArray

Convert Census API JSON data to a StructArray.
"""
function as_structarray(data::JSON3.Array)
    isempty(data) && return StructArray()
    
    # Convert each row to a vector
    rows = [[x for x in row] for row in data]
    headers = rows[1]
    data_rows = rows[2:end]
    
    # Create a dictionary of columns
    cols = Dict{Symbol,Vector{String}}()
    for (i, header) in enumerate(headers)
        cols[Symbol(header)] = [row[i] for row in data_rows]
    end
    
    # Create StructArray from columns
    return StructArray(cols)
end

"""
    as_namedtuples(data::JSON3.Array) -> Vector{NamedTuple}

Convert Census API JSON data to a Vector of NamedTuples.
"""
function as_namedtuples(data::JSON3.Array)
    isempty(data) && return Vector{NamedTuple}()
    
    # Convert each row to a vector
    rows = [[x for x in row] for row in data]
    headers = Symbol.(rows[1])
    data_rows = rows[2:end]
    
    # Create NamedTuples from rows
    NT = NamedTuple{Tuple(headers)}
    return [NT(Tuple(row)) for row in data_rows]
end

"""
    as_columnar(data::JSON3.Array) -> NamedTuple{Vector}

Convert Census API JSON data to a NamedTuple of Vectors (columnar format).
"""
function as_columnar(data::JSON3.Array)
    isempty(data) && return NamedTuple()
    
    # Convert each row to a vector
    rows = [[x for x in row] for row in data]
    headers = rows[1]
    data_rows = rows[2:end]
    
    # Create a dictionary of columns
    cols = Dict{Symbol,Vector{String}}()
    for (i, header) in enumerate(headers)
        cols[Symbol(header)] = [row[i] for row in data_rows]
    end
    
    # Convert dictionary to NamedTuple
    return NamedTuple{Tuple(Symbol.(keys(cols)))}(Tuple(values(cols)))
end 