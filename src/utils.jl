# Utility functions for ACS.jl

"""
    state_postal_to_fips(postal_code::String) -> String

Convert a state postal code to its FIPS code.
"""
function state_postal_to_fips(postal_code::String)
    # Add state postal code to FIPS mapping
    postal_to_fips = Dict(
        "AL" => "01", "AK" => "02", "AZ" => "04", "AR" => "05", "CA" => "06",
        "CO" => "08", "CT" => "09", "DE" => "10", "DC" => "11", "FL" => "12",
        "GA" => "13", "HI" => "15", "ID" => "16", "IL" => "17", "IN" => "18",
        "IA" => "19", "KS" => "20", "KY" => "21", "LA" => "22", "ME" => "23",
        "MD" => "24", "MA" => "25", "MI" => "26", "MN" => "27", "MS" => "28",
        "MO" => "29", "MT" => "30", "NE" => "31", "NV" => "32", "NH" => "33",
        "NJ" => "34", "NM" => "35", "NY" => "36", "NC" => "37", "ND" => "38",
        "OH" => "39", "OK" => "40", "OR" => "41", "PA" => "42", "RI" => "44",
        "SC" => "45", "SD" => "46", "TN" => "47", "TX" => "48", "UT" => "49",
        "VT" => "50", "VA" => "51", "WA" => "53", "WV" => "54", "WI" => "55",
        "WY" => "56", "AS" => "60", "GU" => "66", "MP" => "69", "PR" => "72",
        "VI" => "78"
    )
    
    postal_code = uppercase(postal_code)
    if !haskey(postal_to_fips, postal_code)
        throw(ArgumentError("Invalid state postal code: $postal_code"))
    end
    
    return postal_to_fips[postal_code]
end

"""
    create_geoid(df::DataFrame, geography::String) -> Vector{String}

Create GEOID values for a DataFrame based on geography type.
"""
function create_geoid(df::DataFrame, geography::String)
    if geography == "state"
        return df.state
    elseif geography == "county"
        return [string(s, pad=2) * string(c, pad=3) 
                for (s, c) in zip(df.state, df.county)]
    elseif geography == "tract"
        return [string(s, pad=2) * string(c, pad=3) * string(t, pad=6)
                for (s, c, t) in zip(df.state, df.county, df.tract)]
    elseif geography == "block group"
        return [string(s, pad=2) * string(c, pad=3) * string(t, pad=6) * string(b)
                for (s, c, t, b) in zip(df.state, df.county, df.tract, df.block_group)]
    else
        throw(ArgumentError("Invalid geography level: $geography"))
    end
end 