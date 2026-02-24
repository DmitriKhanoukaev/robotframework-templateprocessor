*** Settings ***
Library         Collections
Library         OperatingSystem
Library         ./TemplateProcessorLibrary.py

*** Keywords ***
Generate Test File
    [Arguments]                     ${file}  ${template}  &{parameters}
    [Documentation]                 Keyword will generate ${file} using direct path in filename
    ...                             based on ${template} using direct path in filename
    ...                             it requires pairs of constant name=value (like MP=my_MP and etc.)
    ...                             \nNOTE: All template variables are passed as direct parameters - no Robot Framework variable scope issues
    ...                             \nNOTE: All constants of template used (such as %%%CONSTANT@MP%%%) MUST be provided as parameter pairs.
    ...                             \nINPUTS:
    ...                             - name (incl path) of file generated
    ...                             - template file (incl path)
    ...                             - set of parameters/keys to be replaced in template
    ...                             \nShort list of options:
    ...                             \nThese tags can be used in template and do not require any inputs to keyword
    ...                             - %%%NOW@0@%Y-%m-%dT%H:%M:%S+01Z%%%  - will be replaced with datetime NOW in %Y-%m-%dT%H:%M:%S+01Z format
    ...                             - %%%NOW@-3@%Y-%m-%dT%H:%M:%S+01Z%%%  - will be replaced with datetime 3 days ago from now in %Y-%m-%dT%H:%M:%S+01Z format
    ...                             - %%%MONTHDELTA@3@%Y-%m-01T%H:%M:%S+00Z%%%  - will be replaced with datetime 3 months in future in %Y-%m-%dT%H:%M:%S+01Z format
    ...                             - %%%MONTHDELTA@-3@%Y-%m-01T%H:%M:%S+00Z%%%  - will be replaced with datetime 3 months ago in %Y-%m-%dT%H:%M:%S+01Z format
    ...                             - Value  %%%INC@6.2@0.01%%% - will be replaced with Value  6.2
    ...                             - Value  %%%INC@6.2@0.01%%% - will be replaced with Value  6.21
    ...                             - Value  %%%INC@6.2@0.01%%% - will be replaced with Value  6.22
    ...                             \nThese tags can be used in template and do require inputs to keyword
    ...                             - %%%CONSTANT@NETWORK001%%% - will be replaced with values assigned to tag NETWORK001=my_value
    ...                             \nLOOP FEATURE:
    ...                             Loops allow repeating template sections multiple times. Loop syntax:
    ...                             - %%%LOOP@MYLOOPINPUT@loopname%%% <content> %%%LOOP@END@loopname%%%
    ...                             - MYLOOPINPUT can be an integer (loop N times) or a list (iterate through values)
    ...                             - loopname is a unique identifier for the loop
    ...                             \nLoop-specific placeholders (used inside loop body):
    ...                             - %%%INDEX%%% - loop iteration index (0-based, can be shifted with INDEXSHIFT parameter)
    ...                             - %%%loopname.INDEX%%% - named loop's index (accessible from nested loops)
    ...                             - %%%loopname.VALUE%%% - current iteration value (index for int, list element for list)
    ...                             - %%%LOOPINC@2.1@0.2%%% - incremental counter within loop (resets per loop)
    ...                             - %%%LOOPLIST@MYLIST%%% - values from another list synchronized with loop iterations
    ...                             \nLoop parameters:
    ...                             - INDEXSHIFT=1 - shifts INDEX to start from 1 instead of 0
    ...                             - Lists for LOOPLIST must match the loop size
    ...                             \nLOOP EXAMPLE:
    ...                             - Generate File  ${OUT}  ${TEMPLATE}  MYLOOP=${3}  MYLIST=${list}  INDEXSHIFT=1
    ...                             \nEXAMPLE:
    ...                             - Generate File  ${TEMPPATH}RESULT.xml  ${DATAPATH}TEMPLATE.xml  NETWORK001=my_value
    ...                             \nRETURN:
    ...                             - Value of "now" (date/time) used in generator
    ...                             Tags: file, generator
    Log                             File ${file} will be created based on template ${template}
    # Call Python function directly with all parameters
    ${now} =                        Generate File  ${file}  ${template}  &{parameters}
    RETURN                          ${now}

Generate Test File And Return Content
    [Arguments]                     ${file}  ${template}  &{parameters}
    [Documentation]                 Keyword will generate ${file} using direct path in filename
    ...                             based on ${template} using direct path in filename
    ...                             it requires pairs of constant name=value like MP=my_MP and etc.
    ...                             All constants of template used (such as %%%CONSTANT@MP%%%) MUST be provided as parameter pairs.
    ...                             \nINPUTS:
    ...                             - name (incl path) of file generated
    ...                             - template file (incl path)
    ...                             - set of parameters/keys to be replaced in template
    ...                             \nSUPPORTED FEATURES:
    ...                             - Date/time placeholders (NOW, MONTHDELTA)
    ...                             - Incremental values (INC, LOOPINC)
    ...                             - Constants replacement (CONSTANT)
    ...                             - Loop constructs (LOOP with INDEX, VALUE, LOOPINC, LOOPLIST)
    ...                             - See "Generate File" keyword documentation for complete feature list including loop syntax
    ...                             \nRETURN
    ...                             - Generated content (data)
    ...                             - Value of now (date/time) used in generator
    ...                             Tags: file, generator
    Log                             File ${file} will be created based on template ${template}
    # Call Python function directly with all parameters
    ${data}  ${now} =               Generate File And Return Content  ${file}  ${template}  &{parameters}
    RETURN                          ${data}  ${now}
