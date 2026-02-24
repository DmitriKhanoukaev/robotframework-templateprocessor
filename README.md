# Robot Framework Template Processor

A powerful Robot Framework library for generating test data files from templates with dynamic content. Perfect for creating test fixtures, mock data, and complex test scenarios with date/time manipulation, loops, and auto-incrementing values.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features

- **Dynamic Date/Time**: Generate timestamps with day or month offsets
- **Auto-Incrementing Values**: Create sequential IDs and counters
- **Loops**: Iterate over lists to generate repeated content blocks
- **Nested Loops**: Support for complex nested loop structures
- **Variable Substitution**: Replace placeholders with constant values
- **Synchronized Lists**: Iterate multiple lists in parallel within loops
- **Loop-Scoped Counters**: Independent counters that reset per iteration

## Installation

```bash
pip install robotframework-templateprocessor
```

Or install from source:

```bash
git clone https://github.com/MarketSquare/robotframework-templateprocessor.git
cd robotframework-templateprocessor
pip install -e .
```

## Quick Start

### Robot Framework Usage

```robot
*** Settings ***
Library    TemplateProcessorLibrary.py

*** Test Cases ***
Generate Test Data File
    ${timestamp}=    Generate File
    ...    output_file=/tmp/output.txt
    ...    template_file=template.txt
    ...    ID=test123
    ...    ENV=Production
```

### Python Usage

```python
from TemplateProcessorCore import TemplateProcessor

processor = TemplateProcessor()
template_content = "ID: %%%CONSTANT@ID%%%, Time: %%%NOW@0@%Y-%m-%d%%%"
result = processor.process(template_content, {"ID": "test001"})
print(result)  # ID: test001, Time: 2026-02-20
```

## Template Syntax

### 1. Date/Time Placeholders

**Syntax**: `%%%NOW@offset@format%%%`

Generate current date/time with day offset:

**Template:**
```
Test run at: %%%NOW@0@%Y.%m.%d %H:%M:%S%%%
4 days ago: %%%NOW@-4@%Y.%m.%d%%%
3 days ahead: %%%NOW@3@%Y.%m.%d%%%
```

**Output:**
```
Test run at: 2026.02.20 15:08:29
4 days ago: 2026.02.16
3 days ahead: 2026.02.23
```

**Syntax**: `%%%MONTHDELTA@offset@format%%%`

Generate date/time with month offset:

**Template:**
```
2 months ago: %%%MONTHDELTA@-2@%Y.%m.%d%%%
1 month ahead: %%%MONTHDELTA@1@%Y.%m.%d%%%
```

**Output:**
```
2 months ago: 2025.12.20
1 month ahead: 2026.03.20
```

### 2. Variable Substitution

**Syntax**: `%%%CONSTANT@ID%%%`

Replace with parameter values:

**Template:**
```
File ID: %%%CONSTANT@ID%%%
Environment: %%%CONSTANT@ENV%%%
```

**Robot Framework:**
```robot
Generate File    output.txt    template.txt    ID=file001    ENV=Production
```

**Output:**
```
File ID: file001
Environment: Production
```

### 3. Auto-Incrementing Counters

**Syntax**: `%%%INC@base@increment%%%`

Generate sequential values:

**Template:**
```
%%%INC@1.1@0.001%%%
%%%INC@1.1@0.001%%%
%%%INC@1.1@0.001%%%
```

**Output:**
```
1.1
1.101
1.102
```

### 4. Loops

**Syntax**: 
```
%%%LOOP@INPUT@loopname%%%
    ... content ...
%%%LOOP@END@loopname%%%
```

Generate repeated content blocks:

**Template:**
```
%%%LOOP@ITEMS@myloop%%%
Item #%%%INDEX%%%: %%%myloop.VALUE%%%
%%%LOOP@END@myloop%%%
```

**Robot Framework:**
```robot
Generate File    output.txt    template.txt    ITEMS=${['Apple', 'Banana', 'Cherry']}
```

**Output:**
```
Item #1: Apple
Item #2: Banana
Item #3: Cherry
```

### 5. Loop-Scoped Counters

**Syntax**: `%%%LOOPINC@base@increment%%%`

Counters that reset for each loop iteration:

**Template:**
```
%%%LOOP@ITEMS@myloop%%%
Loop index: %%%INDEX%%%
Counter: %%%LOOPINC@2.1@0.2%%%
%%%LOOP@END@myloop%%%
```

**Output:**
```
Loop index: 1
Counter: 2.1
Loop index: 2
Counter: 2.3
Loop index: 3
Counter: 2.5
```

### 6. Synchronized Lists in Loops

**Syntax**: `%%%LOOPLIST@ID%%%`

Iterate multiple lists in parallel:

**Template:**
```
%%%LOOP@INDICES@myloop%%%
Code: %%%LOOPLIST@CODES%%%
Value: %%%LOOPLIST@VALUES%%%
%%%LOOP@END@myloop%%%
```

**Robot Framework:**
```robot
Generate File    output.txt    template.txt
...    INDICES=${[0, 1, 2]}
...    CODES=${['ABC', 'DEF', 'XYZ']}
...    VALUES=${[333, 444, 555]}
```

**Output:**
```
Code: ABC
Value: 333
Code: DEF
Value: 444
Code: XYZ
Value: 555
```

### 7. Nested Loops

Full support for nested loop structures with accessible loop context:

**Template:**
```
%%%LOOP@OUTER@loop1%%%
Outer #%%%loop1.INDEX%%%: %%%loop1.VALUE%%%
  %%%LOOP@INNER@loop2%%%
  Inner #%%%loop2.INDEX%%%: %%%loop2.VALUE%%%
  %%%LOOP@END@loop2%%%
%%%LOOP@END@loop1%%%
```

## Keywords

### Generate File

Generates a file from a template.

**Arguments:**
- `output_file`: Path to the output file
- `template_file`: Path to the template file
- `**parameters`: Template parameters (key=value pairs)

**Returns:** Timestamp used in generation

**Example:**
```robot
${timestamp}=    Generate File
...    /tmp/output.txt
...    template.txt
...    ID=test123
...    ENV=Production
...    ITEMS=${['A', 'B', 'C']}
```

### Generate File And Return Content

Generates a file and returns both the content and timestamp.

**Arguments:**
- `output_file`: Path to the output file
- `template_file`: Path to the template file
- `**parameters`: Template parameters (key=value pairs)

**Returns:** Tuple of (content, timestamp)

**Example:**
```robot
${content}    ${timestamp}=    Generate File And Return Content
...    /tmp/output.txt
...    template.txt
...    ID=test123
```

## Use Cases

- **Test Data Generation**: Create realistic test datasets with varying dates and IDs
- **API Test Payloads**: Generate JSON/XML files with dynamic content
- **Database Seeding**: Create SQL insert scripts with sequential values
- **Load Testing**: Generate large test files with repeated patterns
- **Time-Based Testing**: Test with past, present, and future dates
- **Localization Testing**: Generate test files in multiple formats

## Examples

Complete examples are available in the [tests/](tests/) directory:
- Date/time manipulation: [tests/data/DateTimeEdgeCases_TEMPLATE.txt](tests/data/DateTimeEdgeCases_TEMPLATE.txt) → [tests/temp/DateTimeEdgeCases.txt](tests/temp/DateTimeEdgeCases.txt)
- Loop examples: [tests/data/Loop_TEMPLATE.txt](tests/data/Loop_TEMPLATE.txt) → [tests/temp/Looped.txt](tests/temp/Looped.txt)
- Nested loops: [tests/data/NestedLoops_TEMPLATE.txt](tests/data/NestedLoops_TEMPLATE.txt) → [tests/temp/NestedLoops.txt](tests/temp/NestedLoops.txt)
- Complex combinations: [tests/data/ComplexCombinations_TEMPLATE.txt](tests/data/ComplexCombinations_TEMPLATE.txt) → [tests/temp/ComplexCombinations.txt](tests/temp/ComplexCombinations.txt)

## Running Tests

```bash
# Run Robot Framework tests
robot tests/TemplateBasedGeneratorNew.robot

# Run Python unit tests
pytest tests/test_template_processor.py
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/MarketSquare/robotframework-templateprocessor.git
cd robotframework-templateprocessor

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install development dependencies
pip install -e .
pip install -r requirements-dev.txt

# Run tests
robot tests/TemplateBasedGeneratorNew.robot
pytest tests/
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/MarketSquare/robotframework-templateprocessor/issues)
- **Discussions**: [GitHub Discussions](https://github.com/MarketSquare/robotframework-templateprocessor/discussions)
- **Robot Framework Slack**: `#tools` channel

## Credits

Developed for the Robot Framework community by the MarketSquare organization.
