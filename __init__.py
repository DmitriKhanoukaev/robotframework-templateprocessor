"""
Robot Framework Template Processor Library

A powerful library for generating test data files from templates with dynamic content.

Features:
- Dynamic date/time generation with offsets
- Auto-incrementing counters
- Loop constructs for repeated content
- Variable substitution
- Nested loops support
- Synchronized list iteration
"""

__version__ = "1.0.0"
__author__ = "Robot Framework Template Processor Contributors"
__license__ = "Apache-2.0"

from TemplateProcessorCore import TemplateProcessor
from TemplateProcessorLibrary import generate_file, generate_file_and_return_content

__all__ = [
    "TemplateProcessor",
    "generate_file",
    "generate_file_and_return_content",
    "__version__",
]
