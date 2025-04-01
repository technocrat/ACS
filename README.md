# ACS.jl

A Julia package for retrieving data from the U.S. Census Bureau's American Community Survey (ACS) API. This is based on the R `tidycensus` package by Kyle Walker (https://github.com/walkerke/tidycensus/tree/master)

## Features

- Fetch data from 1-year, 3-year, and 5-year ACS estimates
- Support for various geographic levels (state, county, tract, block group)
- Automatic handling of state FIPS codes
- Robust error handling and retries
- Returns data in DataFrame format
- Separate functions for estimates and margin of error values

## Planned enhancements

- Fetch the list of available variables
- TIGER shapefiles

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/ACS.jl")
```

## Usage

```julia
using ACS

# Get total population estimates for all states (5-year ACS)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state"
)

# Get margin of error for total population (5-year ACS)
df_moe = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state"
)

# Get 1-year estimates for counties in California
df = get_acs(
    variables = ["B01003_001E"],
    geography = "county",
    state = "CA",
    survey = "acs1"
)
```

## API Functions

### Estimates

- `get_acs5`: Get 5-year ACS estimates (2009-present)
- `get_acs3`: Get 3-year ACS estimates (2007-2013)
- `get_acs1`: Get 1-year ACS estimates (2005-present, except 2020)
- `get_acs`: Wrapper function to access any ACS survey type

### Margin of Error

- `get_acs_moe5`: Get 5-year ACS margin of error values
- `get_acs_moe3`: Get 3-year ACS margin of error values
- `get_acs_moe1`: Get 1-year ACS margin of error values
- `get_acs_moe`: Wrapper function to access any ACS MOE values

## Geographic Levels

- `state`: State-level data
- `county`: County-level data
- `tract`: Census tract-level data
- `block group`: Block group-level data

## Variable Codes

- Estimate variables must end with 'E' (e.g., "B01003_001E")
- MOE variables must end with 'M' (e.g., "B01003_001M")

## Census API Key

To use this package, you should have a Census API key. You can get one at:
https://api.census.gov/data/key_signup.html

Set your API key as an environment variable:

```julia
ENV["CENSUS_API_KEY"] = "your-api-key-here"
```

## Notes

- 1-year ACS data is only available for geographies with populations of 65,000 or greater
- 3-year ACS data was only produced from 2007-2013 and is available for geographies with populations of 20,000 or greater
- The regular 1-year ACS for 2020 was not released due to COVID-19 impacts on data collection

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License
