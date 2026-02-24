"""
Template Processor Core - Pure Python Implementation

Contains the TemplateProcessor class that handles template processing logic.
This module is used internally by the TemplateProcessorLibrary Robot Framework library.
"""

__version__ = "1.0.0"

import re
import datetime
from datetime import timedelta
from typing import Dict, Any


class TemplateProcessor:
    """
    Processes template files with special placeholders for test data generation.
    
    Supported placeholders:
    - %%%NOW@offset@format%%% - Date/time with day offset
    - %%%MONTHDELTA@offset@format%%% - Date/time with month offset
    - %%%INC@base@increment%%% - Auto-incrementing counter
    - %%%CONSTANT@ID%%% - Variable substitution
    - %%%LOOP@INPUT@name%%% ... %%%LOOP@END@name%%% - Loop construct
    - %%%INDEX%%% - Current loop iteration index (inside loops, backward compatible)
    - %%%loopname.INDEX%%% - Specific named loop's index (accessible in nested loops)
    - %%%loopname.VALUE%%% - Loop item value (accessible in nested loops)
    - %%%LOOPINC@base@increment%%% - Loop-scoped counter
    - %%%LOOPLIST@ID%%% - Synchronized list values in loops
    """
    
    def __init__(self):
        self.now = datetime.datetime.now()
        self.inc_values = {}  # Global INC state
        
    def process(self, template_string: str, parameters: Dict[str, Any]) -> str:
        """
        Process template string with given parameters.
        
        Args:
            template_string: Template content with placeholders
            parameters: Dictionary of parameter name -> value
            
        Returns:
            Processed template string
        """
        # First, replace Robot Framework-style variables ${...}
        # This allows tests to use ${Data} or ${Temppath} and have them replaced
        for key, value in parameters.items():
            robot_var_pattern = f"${{{key}}}"
            if robot_var_pattern in template_string:
                # Convert value to string for replacement
                str_value = str(value) if not isinstance(value, (list, dict)) else robot_var_pattern
                template_string = template_string.replace(robot_var_pattern, str_value)
        
        # Process loops first (they may contain other placeholders)
        result = self._process_loops(template_string, parameters)
        
        # Process date/time placeholders
        result = re.sub(
            r"%%%(NOW|MONTHDELTA)@([-]?\d*)@(.*?)%%%",
            self._replace_date,
            result
        )
        
        # Process CONSTANT placeholders
        result = re.sub(
            r"%%%CONSTANT@(\S*?)%%%",
            lambda m: self._get_constant(m, parameters),
            result
        )
        
        # Process INC placeholders
        result = re.sub(
            r"%%%INC@([-\d.]+)@([-\d.]+)%%%",
            self._process_inc,
            result
        )
        
        return result
    
    def _replace_date(self, match: re.Match) -> str:
        """Replace date/time placeholders."""
        operation = match.group(1)
        offset_str = match.group(2)
        date_format = match.group(3)
        
        offset = int(offset_str) if offset_str else 0
        
        if operation == "NOW":
            target_date = self.now + timedelta(days=offset)
        elif operation == "MONTHDELTA":
            target_date = self._monthdelta(self.now, offset)
        else:
            raise ValueError(f"Unknown date operation: {operation}")
            
        return target_date.strftime(date_format)
    
    def _get_constant(self, match: re.Match, parameters: Dict[str, Any]) -> str:
        """Get constant value from parameters."""
        const_id = match.group(1)
        
        if const_id not in parameters:
            raise ValueError(f"Missing constant for ID: {const_id} in pattern: {match.group(0)}")
        
        value = parameters[const_id]
        
        # Convert to string if needed
        if not isinstance(value, str):
            # For lists/dicts, this might be an error in usage
            if isinstance(value, (list, dict)):
                raise ValueError(
                    f"CONSTANT@{const_id} refers to a {type(value).__name__}, "
                    f"but CONSTANT can only be used with string/int values. "
                    f"Use it as a loop input instead."
                )
            value = str(value)
            
        return value
    
    def _process_inc(self, match: re.Match) -> str:
        """Process INC placeholder."""
        base_value = float(match.group(1))
        increment_value = float(match.group(2))
        key = (base_value, increment_value)
        
        decimal_places = len(str(increment_value).split(".")[1]) if '.' in str(increment_value) else 0
        
        if key not in self.inc_values:
            self.inc_values[key] = base_value
        else:
            self.inc_values[key] += increment_value
            
        self.inc_values[key] = round(self.inc_values[key], decimal_places)
        return str(self.inc_values[key])
    
    def _process_loopinc(self, match: re.Match, loop_state: Dict) -> str:
        """Process LOOPINC placeholder (loop-scoped counter)."""
        base_value = float(match.group(1))
        increment_value = float(match.group(2))
        key = (base_value, increment_value)
        
        if key not in loop_state['LOOPINC']:
            loop_state['LOOPINC'][key] = base_value
        else:
            loop_state['LOOPINC'][key] += increment_value
            
        decimal_places = len(str(increment_value).split(".")[1]) if '.' in str(increment_value) else 0
        loop_state['LOOPINC'][key] = round(loop_state['LOOPINC'][key], decimal_places)
        return str(loop_state['LOOPINC'][key])
    
    def _process_loops(self, text: str, parameters: Dict[str, Any]) -> str:
        """
        Process loop constructs.
        
        Rule: Loop markers produce NO output. If a line contains ONLY a loop marker
        (and whitespace), that entire line disappears from output.
        """
        loop_pattern = re.compile(
            r"%%%LOOP@(.+?)@(.+?)%%%([\s\S]*?)%%%LOOP@END@\2%%%",
            re.MULTILINE
        )
        
        while True:
            match = loop_pattern.search(text)
            if not match:
                break
                
            loop_input_name = match.group(1)
            loop_name = match.group(2)
            loop_body = match.group(3)
            
            # Find boundaries for replacement
            # Check if START marker is alone on its line
            start_pos = match.start()
            line_start = text.rfind('\n', max(0, start_pos - 100), start_pos)
            if line_start == -1:
                line_start = 0
            else:
                line_start += 1
            before_start = text[line_start:start_pos]
            after_start_pos = start_pos + len(f"%%%LOOP@{loop_input_name}@{loop_name}%%%")
            
            # Check what comes after START marker on the same line
            next_char_after_start = text[after_start_pos:after_start_pos+1] if after_start_pos < len(text) else ''
            
            # START is standalone if line has only whitespace before it and newline after it
            start_is_standalone = (before_start.strip() == '' and next_char_after_start in ['\n', '\r'])
            
            # Check if END marker is alone on its line
            end_marker = f"%%%LOOP@END@{loop_name}%%%"
            end_marker_start = match.end() - len(end_marker)
            end_line_start = text.rfind('\n', match.start(), end_marker_start)
            if end_line_start == -1:
                end_line_start = 0
            else:
                end_line_start += 1
            before_end = text[end_line_start:end_marker_start]
            
            # Check what comes after END marker
            after_end_pos = match.end()
            next_char_after_end = text[after_end_pos:after_end_pos+1] if after_end_pos < len(text) else ''
            
            # END is standalone if line has only whitespace before it and newline (or EOF) after it
            end_is_standalone = (before_end.strip() == '' and (next_char_after_end in ['\n', '\r', ''] or after_end_pos >= len(text)))
            
            # Check if there's actually a newline to consume after END marker
            # (different from end_is_standalone which can be True at EOF with no newline)
            has_newline_after_end = (after_end_pos < len(text) and text[after_end_pos:after_end_pos+1] in ['\n', '\r'])
            
            # Extract loop body, removing lines that have ONLY markers
            if start_is_standalone:
                # Remove the START marker line (including its newline)
                if loop_body.startswith('\r\n'):
                    loop_body = loop_body[2:]
                elif loop_body.startswith('\n'):
                    loop_body = loop_body[1:]
                    
            if end_is_standalone:
                # Remove the END marker line (the newline and any whitespace before END marker)
                loop_body = loop_body.rstrip()
            
            # Get INDEXSHIFT if specified
            index_shift = 0
            if 'INDEXSHIFT' in parameters:
                try:
                    index_shift = int(parameters['INDEXSHIFT'])
                except (ValueError, TypeError):
                    raise ValueError(f"INDEXSHIFT must be an integer, but got: {parameters['INDEXSHIFT']}")
            
            # Get loop input
            if loop_input_name not in parameters:
                raise ValueError(f"Missing loop input for ID: {loop_input_name} in pattern: {match.group(0)}")
            
            loop_input = parameters[loop_input_name]
            
            # Convert to loop values
            if isinstance(loop_input, int):
                loop_values = list(range(loop_input))
            elif isinstance(loop_input, list):
                loop_values = loop_input
            else:
                raise ValueError(
                    f"Loop input '{loop_input_name}' should be a list or int, "
                    f"but got {type(loop_input).__name__}"
                )
            
            # Detect LOOPLIST placeholders
            looplist_pattern = re.compile(r"%%%LOOPLIST@([A-Za-z0-9_]+)%%%")
            looplist_ids = list(set(looplist_pattern.findall(loop_body)))
            looplist_data = {}
            
            for list_id in looplist_ids:
                if list_id not in parameters:
                    raise ValueError(f"Missing LOOPLIST constant for ID: {list_id}")
                    
                entry = parameters[list_id]
                
                if not isinstance(entry, list):
                    raise ValueError(f"LOOPLIST '{list_id}' must be a list")
                    
                if len(entry) != len(loop_values):
                    raise ValueError(
                        f"LOOPLIST '{list_id}' length ({len(entry)}) "
                        f"does not match loop size ({len(loop_values)})"
                    )
                    
                looplist_data[list_id] = entry
            
            # Process loop iterations
            expanded = []
            loop_state = {'LOOPINC': {}}
            
            for index, val in enumerate(loop_values):
                loop_instance = loop_body
                
                # Replace loop-specific placeholders, but protect nested loops from interference
                # Strategy: Only protect INDEX, LOOPINC, and LOOPLIST within nested loops
                # Allow outer loop's .INDEX and .VALUE to be accessible everywhere
                
                # First, replace the current loop's named placeholders (accessible everywhere including nested loops)
                loop_instance = loop_instance.replace(f"%%%{loop_name}.INDEX%%%", str(index + index_shift))
                loop_instance = loop_instance.replace(f"%%%{loop_name}.VALUE%%%", str(val))
                
                # Protect nested loops' INDEX, LOOPINC, and LOOPLIST from being replaced
                # by temporarily masking them
                nested_loops_info = []
                nested_loop_pattern = re.compile(
                    r"%%%LOOP@(.+?)@(.+?)%%%([\s\S]*?)%%%LOOP@END@\2%%%",
                    re.MULTILINE
                )
                
                def protect_nested_loop(match):
                    nested_input = match.group(1)
                    nested_name = match.group(2)
                    nested_body = match.group(3)
                    
                    # Protect INDEX, LOOPINC, and LOOPLIST in nested loop body
                    protected_body = nested_body
                    protected_body = protected_body.replace("%%%INDEX%%%", "__NESTED_INDEX__")
                    protected_body = re.sub(
                        r"%%%LOOPINC@([-\d.]+)@([-\d.]+)%%%",
                        r"__NESTED_LOOPINC@\1@\2__",
                        protected_body
                    )
                    protected_body = re.sub(
                        r"%%%LOOPLIST@([A-Za-z0-9_]+)%%%",
                        r"__NESTED_LOOPLIST@\1__",
                        protected_body
                    )
                    
                    placeholder_id = len(nested_loops_info)
                    nested_loops_info.append({
                        'input': nested_input,
                        'name': nested_name,
                        'body': protected_body
                    })
                    return f"__NESTED_LOOP_{placeholder_id}__"
                
                # Temporarily replace nested loops with placeholders
                loop_instance = nested_loop_pattern.sub(protect_nested_loop, loop_instance)
                
                # Now safely replace current loop's placeholders
                loop_instance = loop_instance.replace("%%%INDEX%%%", str(index + index_shift))
                
                # Replace LOOPLIST placeholders (only at current level)
                for list_id, list_values in looplist_data.items():
                    loop_instance = loop_instance.replace(
                        f"%%%LOOPLIST@{list_id}%%%",
                        str(list_values[index])
                    )
                
                # Replace LOOPINC placeholders (only at current level)
                loop_instance = re.sub(
                    r"%%%LOOPINC@([-\d.]+)@([-\d.]+)%%%",
                    lambda m: self._process_loopinc(m, loop_state),
                    loop_instance
                )
                
                # Restore nested loops with their protected placeholders
                for i, nested_info in enumerate(nested_loops_info):
                    # Reconstruct the nested loop with protected placeholders
                    nested_loop_text = (
                        f"%%%LOOP@{nested_info['input']}@{nested_info['name']}%%%"
                        f"{nested_info['body']}"
                        f"%%%LOOP@END@{nested_info['name']}%%%"
                    )
                    # Unprotect the placeholders so they can be processed by the nested loop
                    nested_loop_text = nested_loop_text.replace("__NESTED_INDEX__", "%%%INDEX%%%")
                    nested_loop_text = re.sub(
                        r"__NESTED_LOOPINC@([-\d.]+)@([-\d.]+)__",
                        r"%%%LOOPINC@\1@\2%%%",
                        nested_loop_text
                    )
                    nested_loop_text = re.sub(
                        r"__NESTED_LOOPLIST@([A-Za-z0-9_]+)__",
                        r"%%%LOOPLIST@\1%%%",
                        nested_loop_text
                    )
                    loop_instance = loop_instance.replace(f"__NESTED_LOOP_{i}__", nested_loop_text)
                
                # Recursively process inner placeholders (including nested loops)
                # Create a new processor to handle nested loops with isolated state
                inner_processor = TemplateProcessor()
                inner_processor.now = self.now  # Share timestamp
                inner_processor.inc_values = self.inc_values  # Share global INC state
                processed = inner_processor.process(loop_instance, parameters)
                
                expanded.append(processed)
            
            # Determine how to join iterations based on marker positions
            # Rule: Lines with ONLY markers disappear completely (including their newline)
            if start_is_standalone:
                # START standalone: iterations need newlines between them
                expanded_text = '\n'.join(expanded)
                # Add trailing newline ONLY if there's actually a newline to consume after END marker
                # Don't add if END is at EOF or end of outer loop body (no newline to compensate for)
                if has_newline_after_end:
                    expanded_text += '\n'
            elif end_is_standalone:
                # START inline, END standalone: concatenate
                expanded_text = ''.join(expanded)
                # Add trailing newline only if there's one to consume
                if has_newline_after_end:
                    expanded_text += '\n'
            else:
                # Both inline: just concatenate
                expanded_text = ''.join(expanded)
            
            # Determine replacement boundaries
            replace_start = match.start()
            replace_end = match.end()
            
            # If START is standalone, remove from start of its line
            if start_is_standalone:
                replace_start = line_start
                # Also consume the newline after START marker
                if text[after_start_pos:after_start_pos+2] == '\r\n':
                    # newline already consumed in body processing
                    pass
                elif text[after_start_pos:after_start_pos+1] == '\n':
                    # newline already consumed in body processing
                    pass
                    
            # If END is standalone, consume the newline after it
            if end_is_standalone:
                if text[replace_end:replace_end+2] == '\r\n':
                    replace_end += 2
                elif text[replace_end:replace_end+1] == '\n':
                    replace_end += 1
            
            # Replace loop block with expanded content
            text = text[:replace_start] + expanded_text + text[replace_end:]
        
        return text
    
    def _monthdelta(self, date: datetime.datetime, delta: int) -> datetime.datetime:
        """
        Add or subtract months from a date.
        
        Args:
            date: Starting date
            delta: Number of months to add (positive) or subtract (negative)
            
        Returns:
            New datetime with month delta applied
        """
        m, y = (date.month + delta) % 12, date.year + ((date.month) + delta - 1) // 12
        if not m:
            m = 12
        d = min(date.day, [31, 29 if y % 4 == 0 and not y % 400 == 0 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1])
        return date.replace(day=d, month=m, year=y)
