# Examples

## Basic Usage

### Getting Population Estimates

```julia
using ACS

# Get total population for all states using 5-year estimates
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state"
)

# Get population and median household income
df = get_acs(
    variables = ["B01003_001E", "B19013_001E"],
    geography = "state"
)
```

### Working with Margins of Error

```julia
# Get MOE for total population
df_moe = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state"
)
```

## Geographic Levels

### State Level

```julia
# Get state-level data
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state"
)
```

### County Level

```julia
# Get all counties in California
df = get_acs(
    variables = ["B01003_001E"],
    geography = "county",
    state = "CA"
)
```

### Census Tract Level

```julia
# Get all tracts in a specific county
df = get_acs(
    variables = ["B01003_001E"],
    geography = "tract",
    state = "CA",
    county = "001"  # Alameda County
)
```

## Survey Types

### 1-Year Estimates

```julia
# Get 1-year estimates (65,000+ population areas only)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs1"
)
```

### 3-Year Estimates

```julia
# Get 3-year estimates from 2013 (20,000+ population areas)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    year = 2013,
    survey = "acs3"
)
```

### 5-Year Estimates

```julia
# Get 5-year estimates (all areas)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs5"
)
```

## Error Handling

The package includes robust error handling for common scenarios:

```julia
# Invalid year for 3-year estimates
try
    df = get_acs(
        variables = ["B01003_001E"],
        geography = "state",
        year = 2020,
        survey = "acs3"
    )
catch e
    println("Error: ", e)
end

# Invalid geography level
try
    df = get_acs(
        variables = ["B01003_001E"],
        geography = "invalid"
    )
catch e
    println("Error: ", e)
end
``` 