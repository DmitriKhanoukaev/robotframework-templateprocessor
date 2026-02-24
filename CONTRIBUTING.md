# Contributing to Robot Framework Template Processor

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project follows the [Robot Framework Code of Conduct](https://github.com/robotframework/robotframework/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

- Use a clear and descriptive title
- Describe the exact steps to reproduce the problem
- Provide the template content and parameters used
- Include the actual vs expected output
- Specify your environment (OS, Python version, Robot Framework version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the proposed functionality
- Include examples of how the feature would be used
- Explain why this enhancement would be useful

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add or update tests as needed
5. Ensure all tests pass
6. Update documentation if needed
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/robotframework-templateprocessor.git
cd robotframework-templateprocessor

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install in development mode
pip install -e .

# Install development dependencies
pip install pytest pytest-cov robotframework
```

## Running Tests

### Robot Framework Tests
```bash
# Run all Robot Framework tests
robot tests/TemplateBasedGeneratorNew.robot

# Run with detailed logging
robot -L DEBUG tests/TemplateBasedGeneratorNew.robot
```

### Python Unit Tests
```bash
# Run with pytest
pytest tests/test_template_processor.py -v

# Run with coverage
pytest tests/test_template_processor.py --cov=. --cov-report=html
```

## Coding Standards

- Follow PEP 8 style guide
- Use meaningful variable and function names
- Add docstrings to all public functions and classes
- Keep functions focused and single-purpose
- Maximum line length: 120 characters
- Use type hints where appropriate

### Code Style

```python
def process_template(template: str, parameters: Dict[str, Any]) -> str:
    """
    Process a template with given parameters.
    
    Args:
        template: Template content with placeholders
        parameters: Dictionary of parameter name to value
        
    Returns:
        Processed template string
    """
    # Implementation here
    pass
```

## Documentation

- Update README.md if adding new features
- Add examples for new placeholder types
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
- Include docstrings for all public APIs

## Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters
- Reference issues and pull requests after the first line

Examples:
```
Add support for WEEKDELTA placeholder

- Implement week-based date offset calculation
- Add tests for WEEKDELTA functionality
- Update documentation with examples

Fixes #123
```

## Testing Guidelines

- Write tests for all new features
- Ensure backward compatibility
- Test edge cases and error conditions
- Provide both unit tests (Python) and integration tests (Robot Framework)
- Include example templates and expected outputs

### Test Structure

```
tests/
├── data/                      # Template files
│   └── Feature_TEMPLATE.txt
├── temp/                      # Expected outputs (for documentation)
│   └── FeatureOutput.txt
├── test_*.py                  # Python unit tests
└── *.robot                    # Robot Framework tests
```

## Release Process

Maintainers will handle releases following Semantic Versioning:

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Questions?

- Open a [GitHub Discussion](https://github.com/MarketSquare/robotframework-templateprocessor/discussions)
- Join Robot Framework Slack (#tools channel)
- Check existing issues and documentation

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for contributing to Robot Framework Template Processor! 🤖
