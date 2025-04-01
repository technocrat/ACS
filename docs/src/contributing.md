# Contributing

We welcome contributions to ACS.jl! Here's how you can help:

## Types of Contributions

- Bug reports
- Feature requests
- Documentation improvements
- Code contributions
- Examples and tutorials

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/ACS.jl.git
   ```
3. Add the original repository as upstream:
   ```bash
   git remote add upstream https://github.com/originalowner/ACS.jl.git
   ```
4. Create a new branch for your changes:
   ```bash
   git checkout -b feature-name
   ```

## Running Tests

```julia
using Pkg
Pkg.test("ACS")
```

## Documentation

- Documentation is built using Documenter.jl
- Build the documentation locally:
  ```julia
  include("docs/make.jl")
  ```
- Preview the documentation in your browser at `docs/build/index.html`

## Code Style Guidelines

- Follow Julia's style guide
- Use meaningful variable names
- Add docstrings for all public functions
- Include examples in docstrings
- Write tests for new functionality

## Submitting Changes

1. Commit your changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```
2. Push to your fork:
   ```bash
   git push origin feature-name
   ```
3. Create a Pull Request from your fork to the main repository

## Code Review Process

1. All contributions require review
2. Address any feedback from maintainers
3. Keep pull requests focused on a single change
4. Maintain a clean commit history

## Getting Help

- Open an issue for questions
- Join our community discussions
- Read the existing documentation 