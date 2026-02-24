"""Tests for TemplateProcessor module."""

import unittest
import datetime
from unittest.mock import patch
import sys
import os

# Add parent directory to path to import TemplateProcessorCore
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from TemplateProcessorCore import TemplateProcessor


class TestTemplateProcessor(unittest.TestCase):
    """Test cases for TemplateProcessor class."""

    def test_process_basic_string(self):
        """Test process with basic string without placeholders."""
        processor = TemplateProcessor()
        result = processor.process("Hello World", {})
        self.assertEqual(result, "Hello World")
        self.assertIsInstance(processor.now, datetime.datetime)

    def test_process_now_placeholder(self):
        """Test process with NOW placeholder."""
        processor = TemplateProcessor()
        # Set a known timestamp
        processor.now = datetime.datetime(2023, 1, 15, 12, 0, 0)
        
        result = processor.process("Current time: %%%NOW@0@%Y-%m-%d%%%", {})
        self.assertEqual(result, "Current time: 2023-01-15")

    def test_process_now_with_offset(self):
        """Test process with NOW placeholder and day offset."""
        processor = TemplateProcessor()
        processor.now = datetime.datetime(2023, 1, 15, 12, 0, 0)
        
        result = processor.process("Yesterday: %%%NOW@-1@%Y-%m-%d%%%", {})
        self.assertEqual(result, "Yesterday: 2023-01-14")
        
        result = processor.process("Tomorrow: %%%NOW@1@%Y-%m-%d%%%", {})
        self.assertEqual(result, "Tomorrow: 2023-01-16")

    def test_process_monthdelta_placeholder(self):
        """Test process with MONTHDELTA placeholder."""
        processor = TemplateProcessor()
        processor.now = datetime.datetime(2023, 6, 15, 12, 0, 0)
        
        result = processor.process("Last month: %%%MONTHDELTA@-1@%Y-%m%%%", {})
        self.assertEqual(result, "Last month: 2023-05")
        
        result = processor.process("Next month: %%%MONTHDELTA@1@%Y-%m%%%", {})
        self.assertEqual(result, "Next month: 2023-07")

    def test_process_constant_placeholder(self):
        """Test process with CONSTANT placeholder."""
        processor = TemplateProcessor()
        parameters = {
            'NETWORK001': 'TestNetwork',
            'METERID001': 'TM123456'
        }
        
        result = processor.process(
            "Network: %%%CONSTANT@NETWORK001%%%, Meter: %%%CONSTANT@METERID001%%%",
            parameters
        )
        self.assertEqual(result, "Network: TestNetwork, Meter: TM123456")

    def test_process_constant_missing_parameter(self):
        """Test process with CONSTANT placeholder but missing parameter."""
        processor = TemplateProcessor()
        
        with self.assertRaises(ValueError) as context:
            processor.process("Network: %%%CONSTANT@NETWORK001%%%", {})
        
        self.assertIn("Missing constant for ID: NETWORK001", str(context.exception))

    def test_process_constant_list_value_error(self):
        """Test process with CONSTANT placeholder that refers to a list."""
        processor = TemplateProcessor()
        parameters = {'NETWORK001': ['value1', 'value2']}
        
        with self.assertRaises(ValueError) as context:
            processor.process("Network: %%%CONSTANT@NETWORK001%%%", parameters)
        
        self.assertIn("refers to a list", str(context.exception))

    def test_process_inc_placeholder(self):
        """Test process with INC placeholder."""
        processor = TemplateProcessor()
        
        template = "Value1: %%%INC@10.0@0.5%%%, Value2: %%%INC@10.0@0.5%%%, Value3: %%%INC@10.0@0.5%%%"
        result = processor.process(template, {})
        self.assertEqual(result, "Value1: 10.0, Value2: 10.5, Value3: 11.0")

    def test_process_inc_different_keys(self):
        """Test process with INC placeholder using different base/increment values."""
        processor = TemplateProcessor()
        
        template = "A: %%%INC@1.0@0.1%%%, B: %%%INC@2.0@0.2%%%, A: %%%INC@1.0@0.1%%%"
        result = processor.process(template, {})
        self.assertEqual(result, "A: 1.0, B: 2.0, A: 1.1")

    def test_process_loop_with_integer(self):
        """Test process with LOOP placeholder using integer."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 3,
            'INDEXSHIFT': 0
        }
        
        template = """%%%LOOP@MYLOOPINPUT@myloop%%%
Item %%%INDEX%%%: %%%myloop.VALUE%%%
%%%LOOP@END@myloop%%%"""
        result = processor.process(template, parameters)
        expected = "Item 0: 0\nItem 1: 1\nItem 2: 2"
        self.assertEqual(result, expected)

    def test_process_loop_with_list(self):
        """Test process with LOOP placeholder using list."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': ['apple', 'banana', 'cherry'],
            'INDEXSHIFT': 1
        }
        
        template = """%%%LOOP@MYLOOPINPUT@myloop%%%
Item %%%INDEX%%%: %%%myloop.VALUE%%%
%%%LOOP@END@myloop%%%"""
        result = processor.process(template, parameters)
        expected = "Item 1: apple\nItem 2: banana\nItem 3: cherry"
        self.assertEqual(result, expected)

    def test_process_loop_with_looplist(self):
        """Test process with LOOP and LOOPLIST placeholders."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 2,
            'MYLIST1': ['red', 'blue'],
            'INDEXSHIFT': 0
        }
        
        template = """%%%LOOP@MYLOOPINPUT@myloop%%%
Color %%%INDEX%%%: %%%LOOPLIST@MYLIST1%%%
%%%LOOP@END@myloop%%%"""
        result = processor.process(template, parameters)
        expected = "Color 0: red\nColor 1: blue"
        self.assertEqual(result, expected)

    def test_process_loop_with_loopinc(self):
        """Test process with LOOP and LOOPINC placeholders."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 3,
            'INDEXSHIFT': 0
        }
        
        template = """%%%LOOP@MYLOOPINPUT@myloop%%%
Value: %%%LOOPINC@5.0@1.5%%%
%%%LOOP@END@myloop%%%"""
        result = processor.process(template, parameters)
        expected = "Value: 5.0\nValue: 6.5\nValue: 8.0"
        self.assertEqual(result, expected)

    def test_process_loop_missing_input(self):
        """Test process with LOOP but missing loop input parameter."""
        processor = TemplateProcessor()
        
        with self.assertRaises(ValueError) as context:
            processor.process("%%%LOOP@MYLOOPINPUT@myloop%%%test%%%LOOP@END@myloop%%%", {})
        
        self.assertIn("Missing loop input for ID: MYLOOPINPUT", str(context.exception))

    def test_process_loop_invalid_input_type(self):
        """Test process with LOOP but invalid input type."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 'invalid_string',
            'INDEXSHIFT': 0
        }
        
        with self.assertRaises(ValueError) as context:
            processor.process("%%%LOOP@MYLOOPINPUT@myloop%%%test%%%LOOP@END@myloop%%%", parameters)
        
        self.assertIn("should be a list or int", str(context.exception))

    def test_process_loop_looplist_length_mismatch(self):
        """Test process with LOOPLIST length mismatch."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 3,
            'MYLIST1': ['red', 'blue'],  # Only 2 items for 3 iterations
            'INDEXSHIFT': 0
        }
        
        with self.assertRaises(ValueError) as context:
            processor.process("%%%LOOP@MYLOOPINPUT@myloop%%%Color: %%%LOOPLIST@MYLIST1%%%\n%%%LOOP@END@myloop%%%", parameters)
        
        self.assertIn("length (2) does not match loop size (3)", str(context.exception))

    def test_process_loop_looplist_not_list(self):
        """Test process with LOOPLIST that is not a list."""
        processor = TemplateProcessor()
        parameters = {
            'MYLOOPINPUT': 2,
            'MYLIST1': 'not_a_list',
            'INDEXSHIFT': 0
        }
        
        with self.assertRaises(ValueError) as context:
            processor.process("%%%LOOP@MYLOOPINPUT@myloop%%%Color: %%%LOOPLIST@MYLIST1%%%\n%%%LOOP@END@myloop%%%", parameters)
        
        self.assertIn("LOOPLIST 'MYLIST1' must be a list", str(context.exception))

    def test_process_complex_template(self):
        """Test process with multiple placeholder types."""
        processor = TemplateProcessor()
        processor.now = datetime.datetime(2023, 6, 15, 12, 0, 0)
        
        parameters = {
            'NETWORK': 'TestNet',
            'COUNTER': 2,
            'INDEXSHIFT': 1
        }
        
        template = """Date: %%%NOW@0@%Y-%m-%d%%%
Network: %%%CONSTANT@NETWORK%%%
Values: %%%INC@10.0@1.0%%%,%%%INC@10.0@1.0%%%
%%%LOOP@COUNTER@item%%%
  Item %%%INDEX%%%: %%%item.VALUE%%%
%%%LOOP@END@item%%%"""
        
        result = processor.process(template, parameters)
        expected = """Date: 2023-06-15
Network: TestNet
Values: 10.0,11.0
  Item 1: 0
  Item 2: 1"""
        self.assertEqual(result, expected)

    def test_monthdelta_positive_delta(self):
        """Test _monthdelta with positive delta."""
        processor = TemplateProcessor()
        date = datetime.datetime(2023, 1, 15)
        result = processor._monthdelta(date, 2)
        expected = datetime.datetime(2023, 3, 15)
        self.assertEqual(result, expected)

    def test_monthdelta_negative_delta(self):
        """Test _monthdelta with negative delta."""
        processor = TemplateProcessor()
        date = datetime.datetime(2023, 3, 15)
        result = processor._monthdelta(date, -2)
        expected = datetime.datetime(2023, 1, 15)
        self.assertEqual(result, expected)

    def test_monthdelta_year_boundary(self):
        """Test _monthdelta across year boundary."""
        processor = TemplateProcessor()
        date = datetime.datetime(2023, 11, 15)
        result = processor._monthdelta(date, 3)
        expected = datetime.datetime(2024, 2, 15)
        self.assertEqual(result, expected)

    def test_monthdelta_february_handling(self):
        """Test _monthdelta with February date handling."""
        processor = TemplateProcessor()
        # January 31 + 1 month should be February 28 (non-leap year)
        date = datetime.datetime(2023, 1, 31)
        result = processor._monthdelta(date, 1)
        expected = datetime.datetime(2023, 2, 28)
        self.assertEqual(result, expected)

    def test_monthdelta_leap_year(self):
        """Test _monthdelta with leap year February."""
        processor = TemplateProcessor()
        # January 31 + 1 month should be February 29 (leap year)
        date = datetime.datetime(2024, 1, 31)
        result = processor._monthdelta(date, 1)
        expected = datetime.datetime(2024, 2, 29)
        self.assertEqual(result, expected)

    def test_monthdelta_december_rollover(self):
        """Test _monthdelta with December rollover."""
        processor = TemplateProcessor()
        date = datetime.datetime(2023, 12, 15)
        result = processor._monthdelta(date, 1)
        expected = datetime.datetime(2024, 1, 15)
        self.assertEqual(result, expected)


if __name__ == '__main__':
    unittest.main()
