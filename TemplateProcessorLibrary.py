"""
Template Processor Library - Robot Framework Keywords

This module provides Robot Framework keywords for template-based file generation.
Import this library in your Robot Framework tests, not TemplateProcessorCore.

Example:
    Library    TemplateProcessorLibrary.py
    
Keywords:
    - generate_file: Generates file from template
    - generate_file_and_return_content: Generates file and returns content + timestamp
"""

__version__ = "1.0.0"

import datetime
from pathlib import Path
from typing import Tuple

from TemplateProcessorCore import TemplateProcessor


def generate_file(output_file: str, template_file: str, **parameters) -> datetime.datetime:
    """
    Generate file from template.
    
    Args:
        output_file: Path to output file
        template_file: Path to template file
        **parameters: Template parameters (ID=value, LOOP1=[...], etc.)
        
    Returns:
        Timestamp used in generation
        
    Example:
        generate_file(
            '/tmp/output.txt',
            'template.txt',
            ID='test123',
            ITEMS=['A', 'B', 'C']
        )
    """
    # Read template
    template_path = Path(template_file)
    if not template_path.exists():
        raise FileNotFoundError(f"Template file not found: {template_file}")
    
    template_content = template_path.read_text(encoding='utf-8')
    
    # Process template
    processor = TemplateProcessor()
    result = processor.process(template_content, parameters)
    
    # Write output
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(result, encoding='utf-8')
    
    return processor.now


def generate_file_and_return_content(
    output_file: str,
    template_file: str,
    **parameters
) -> Tuple[str, datetime.datetime]:
    """
    Generate file from template and return both content and timestamp.
    
    Args:
        output_file: Path to output file
        template_file: Path to template file
        **parameters: Template parameters
        
    Returns:
        Tuple of (generated_content, timestamp)
        
    Example:
        content, now = generate_file_and_return_content(
            '/tmp/output.txt',
            'template.txt',
            ID='test123'
        )
    """
    # Read template
    template_path = Path(template_file)
    if not template_path.exists():
        raise FileNotFoundError(f"Template file not found: {template_file}")
    
    template_content = template_path.read_text(encoding='utf-8')
    
    # Process template
    processor = TemplateProcessor()
    result = processor.process(template_content, parameters)
    
    # Write output
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(result, encoding='utf-8')
    
    return result, processor.now
