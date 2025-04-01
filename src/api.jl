# Census API interaction functions

"""
    make_census_request(url::String, headers::Vector{Pair{String,String}}) -> HTTP.Response

Make a request to the Census API with robust error handling and retries.
"""
function make_census_request(url::String, headers::Vector{Pair{String,String}})
    # Set up retry parameters
    max_retries = 3
    base_delay = 1.0  # seconds
    
    for attempt in 1:max_retries
        try
            return HTTP.get(
                url,
                headers;
                retry = false,
                readtimeout = 180,  # 3 minutes
                connecttimeout = 60  # 1 minute
            )
        catch e
            if attempt == max_retries
                @error "Failed to fetch Census data after $max_retries attempts" exception=e
                rethrow(e)
            end
            
            # Exponential backoff
            sleep(base_delay * 2^(attempt - 1))
            
            @warn "Retrying Census API request (attempt $attempt of $max_retries)"
        end
    end
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
    
    # Add API key if available
    api_key = get(ENV, "CENSUS_API_KEY", nothing)
    if !isnothing(api_key)
        push!(params, "key=$(api_key)")
    end
    
    # Construct final URL
    return base_url * "?" * join(params, "&")
end

"""
    process_census_response(r::HTTP.Response, geography::String) -> DataFrame

Process a Census API response into a DataFrame.
"""
function process_census_response(r::HTTP.Response, geography::String)
    # Parse response
    data = JSON3.read(String(r.body))
    
    # Check if we got any data
    if length(data) < 2
        @warn "No data returned from Census API"
        return DataFrame()
    end
    
    # First row contains column names
    col_names = String.(data[1])
    
    # Create DataFrame with proper column types
    df = DataFrame([name => [] for name in col_names])
    
    # Add data rows
    for row in data[2:end]
        push!(df, row)
    end
    
    # Create GEOID
    df.GEOID = create_geoid(df, geography)
    
    # Sort by GEOID
    sort!(df, :GEOID)
    
    return df
end 