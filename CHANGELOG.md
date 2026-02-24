# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-20

### Added
- Initial public release
- Template processing with multiple placeholder types
- `%%%NOW@offset@format%%%` - Date/time with day offset
- `%%%MONTHDELTA@offset@format%%%` - Date/time with month offset
- `%%%INC@base@increment%%%` - Auto-incrementing counter
- `%%%CONSTANT@ID%%%` - Variable substitution
- `%%%LOOP@INPUT@name%%%` - Loop construct for repeated content
- `%%%INDEX%%%` - Current loop iteration index
- `%%%loopname.INDEX%%%` - Specific named loop's index (nested loops)
- `%%%loopname.VALUE%%%` - Loop item value (nested loops)
- `%%%LOOPINC@base@increment%%%` - Loop-scoped counter
- `%%%LOOPLIST@ID%%%` - Synchronized list values in loops
- Support for nested loops
- Robot Framework keywords: `generate_file` and `generate_file_and_return_content`
- Python API via `TemplateProcessor` class
- Comprehensive test suite with examples
- Full documentation and examples

### Features
- Python 3.8+ support
- Robot Framework 4.0+ support
- Pure Python implementation with no external dependencies beyond Robot Framework
- Type hints for better IDE support
- Detailed docstrings and inline documentation

### Documentation
- README with usage examples
- Template syntax guide
- Real-world use cases
- Example templates and generated outputs
- Contributing guidelines
- Apache 2.0 license

[1.0.0]: https://github.com/MarketSquare/robotframework-templateprocessor/releases/tag/v1.0.0
