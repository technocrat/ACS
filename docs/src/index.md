# ACS.jl Documentation

Welcome to the documentation for ACS.jl, a Julia package for retrieving data from the U.S. Census Bureau's American Community Survey (ACS) API.

## Overview

ACS.jl provides a simple and robust interface to access American Community Survey data through the Census Bureau's API. The package supports:

- Data retrieval from 1-year, 3-year, and 5-year ACS estimates
- Various geographic levels (state, county, tract, block group)
- Automatic handling of state FIPS codes
- Robust error handling and retries
- DataFrame output format
- Separate functions for estimates and margin of error values

## Quick Start

```julia
using ACS

# Set your Census API key
ENV["CENSUS_API_KEY"] = "your-api-key-here"

# Get total population estimates for all states (5-year ACS)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state"
)

# Get margin of error for total population
df_moe = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state"
)
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/ACS.jl")
```

## Package Features

### Survey Types
- 5-year estimates (2009-present)
- 3-year estimates (2007-2013)
- 1-year estimates (2005-present, except 2020)

### Geographic Levels
- State
- County
- Census tract
- Block group

### Data Types
- Estimates (variables ending in 'E')
- Margins of error (variables ending in 'M')

## Census API Key

To use this package, you need a Census API key. You can obtain one at:
[https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on our GitHub repository. 