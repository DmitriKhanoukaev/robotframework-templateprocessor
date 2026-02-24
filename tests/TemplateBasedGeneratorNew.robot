################################################
#
# Unit tests for NEW template based generator (pure Python)
# Tests the refactored TemplateProcessorNew.py implementation
#
################################################

*** Settings ***
Force Tags      disabled  internal  new-impl
Resource        ../TestFileGenerators.robot
Library         ../TemplateProcessorLibrary.py
Library         Collections
Library         String
Library         OperatingSystem
Suite Setup     Initialization
Test Teardown   Teardown
Documentation   Suite provides tests for the new pure Python template generator implementation.

*** Variables ***
${Data}         ${CURDIR}/data/
${Temppath}     ${CURDIR}/temp/new/

*** Test Cases ***

File Can Be Generated With Template
    [Tags]                              gen_file_template_1  dkh
    ${id} =                                 Set Variable  gen_file_template_1
    generate_file                           ${Temppath}FirstFileGenerated.txt
    ...                                     ${Data}First_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     ENV=MyEnvironment
    ...                                     TIMEENV=myTimeEnvironment

File Can Be Generated With Template And ENV Variables
    [Tags]                              gen_file_template_2  dkh
    ${id} =                                 Set Variable  gen_file_template_2
    generate_file                           ${Temppath}SecondFileGenerated.txt
    ...                                     ${Data}Second_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Loops Using Int
    [Tags]                              gen_file_loop  dkh
    ${id} =                                 Set Variable  gen_file_template_3
    ${l1} =  Create List  ABC  DEF  XYZ
    ${l2} =  Create List  333  444  555
    generate_file                           ${Temppath}Looped.txt
    ...                                     ${Data}Loop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     MYLOOPINPUT=${3}
    ...                                     INDEXSHIFT=1
    ...                                     MYLIST1=${l1}
    ...                                     MYLIST2=${l2}
    ...                                     NOTE=Record created for ${id}

File Can Be Generated With Loops Using Variables
    [Tags]                              gen_file_loop_vars  dkh
    ${id} =                                 Set Variable  gen_file_template_3
    ${l1} =  Create List  ABC  DEF  XYZ
    ${l2} =  Create List  333  444  555
    VAR  ${start_value}  ${3}
    VAR  ${inc_value}  ${1}
    generate_file                           ${Temppath}LoopedWithVars.txt
    ...                                     ${Data}LoopWithVars_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     MYLOOPINPUT=${3}
    ...                                     INDEXSHIFT=1
    ...                                     MYLIST1=${l1}
    ...                                     MYLIST2=${l2}
    ...                                     NOTE=Record created for ${id}
    ...                                     start_value=${start_value}
    ...                                     inc_value=${inc_value}

File Can Be Generated With Loops Using List
    [Tags]                              gen_file_looplist  dkh
    ${id} =                                 Set Variable  gen_file_template_4
    ${ml} =  Create List  A  B  C
    ${l1} =  Create List  ABC  DEF  XYZ
    ${l2} =  Create List  333  444  555
    generate_file                           ${Temppath}LoopedList.txt
    ...                                     ${Data}Loop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     MYLOOPINPUT=${ml}
    ...                                     MYLIST1=${l1}
    ...                                     MYLIST2=${l2}
    ...                                     NOTE=Record created for ${id}

File Can Be Generated With Multiple Independent Loops
    [Tags]                              gen_file_multiloop  dkh
    ${id} =                                 Set Variable  gen_file_template_5
    # First loop data
    ${loop1} =  Create List  Alpha  Beta  Gamma
    ${details1} =  Create List  DetailA  DetailB  DetailC
    # Second loop data
    ${loop2} =  Create List  CAT1  CAT2
    ${names2} =  Create List  Category-One  Category-Two
    # Third loop data
    ${status3} =  Create List  Active  Inactive  Pending  Complete
    generate_file                           ${Temppath}MultiLooped.txt
    ...                                     ${Data}MultiLoop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     LOOP1INPUT=${loop1}
    ...                                     DETAILS1=${details1}
    ...                                     LOOP2INPUT=${loop2}
    ...                                     NAMES2=${names2}
    ...                                     LOOP3INPUT=${4}
    ...                                     STATUS3=${status3}

File Can Be Generated With Multiple INC Counters
    [Tags]                              gen_file_multiple_inc  dkh
    [Documentation]                     Tests that multiple INC counters with different base values
    ...                                 and increments maintain separate states throughout the template processing
    ${id} =                                 Set Variable  gen_file_template_6
    generate_file                           ${Temppath}MultipleINC.txt
    ...                                     ${Data}MultipleINC_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Environmental And Robot Variables
    [Tags]                              gen_file_env_vars  dkh
    [Documentation]                     Tests that Robot Framework variables can be passed as parameters.
    ...                                 With the new pure Python implementation, ALL variables must be
    ...                                 passed as parameters - which resolves the variable visibility issue.
    ${id} =                                 Set Variable  gen_file_template_13
    # Set test-level variables (passed as parameters)
    ${TEST_ENV} =                       Set Variable  Production
    ${CONFIG_PATH} =                    Set Variable  /etc/config/app.conf
    ${SERVICE_NAME} =                   Set Variable  MyTestService
    ${items} =  Create List  Item-1  Item-2  Item-3
    # Generate file - all vars passed as parameters
    generate_file                           ${Temppath}EnvironmentalVars.txt
    ...                                     ${Data}EnvironmentalVars_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     TEST_ENV=${TEST_ENV}
    ...                                     CONFIG_PATH=${CONFIG_PATH}
    ...                                     SERVICE_NAME=${SERVICE_NAME}
    ...                                     ITEMS=${items}
    ...                                     DESCRIPTION=Service ${SERVICE_NAME} running in ${TEST_ENV}
    ...                                     Data=${Data}
    ...                                     Temppath=${Temppath}
    # Validate that variables were substituted correctly
    ${content} =                        Get File  ${Temppath}EnvironmentalVars.txt
    Should Contain                      ${content}  Test ID: ${id}
    Should Contain                      ${content}  Data directory: ${Data}
    Should Contain                      ${content}  Temp directory: ${Temppath}
    Should Contain                      ${content}  Environment name: ${TEST_ENV}
    Should Contain                      ${content}  Config path: ${CONFIG_PATH}
    Should Contain                      ${content}  Service name: ${SERVICE_NAME}
    Should Contain                      ${content}  Service ${SERVICE_NAME} in ${TEST_ENV} environment
    Should Contain                      ${content}  Config location: ${CONFIG_PATH}
    Should Contain                      ${content}  Counter value: 1.0
    Should Contain                      ${content}  Item 0 in ${TEST_ENV}: Item-1 (from ${CONFIG_PATH})
    Should Contain                      ${content}  Item 1 in ${TEST_ENV}: Item-2 (from ${CONFIG_PATH})
    Should Contain                      ${content}  Description: Service ${SERVICE_NAME} running in ${TEST_ENV}
    Should Contain                      ${content}  Data path is: ${Data}

File And Content Can Be Generated And Content Returned
    [Tags]                              gen_file_return_content  dkh
    [Documentation]                     Tests "Generate File And Return Content" keyword which:
    ...                                 - Generates file to specified path
    ...                                 - Returns both the generated content and timestamp
    ...                                 Validates that both return values are populated correctly
    ${id} =                                 Set Variable  gen_file_template_12
    ${items} =  Create List  Product-A  Product-B  Product-C
    ${data}  ${now} =                   generate_file_and_return_content
    ...                                     ${Temppath}ReturnContent.txt
    ...                                     ${Data}ReturnContent_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     DESCRIPTION=Testing content return functionality
    ...                                     ITEMS=${items}
    # Validate that content was returned
    Should Not Be Empty                 ${data}
    Should Contain                      ${data}  Test ID: ${id}
    Should Contain                      ${data}  Testing content return functionality
    Should Contain                      ${data}  Item 0: Product-A
    Should Contain                      ${data}  Counter 1: 1.0
    Should Contain                      ${data}  Counter 2: 2.0
    Should Contain                      ${data}  Counter 3: 3.0
    # Validate that timestamp was returned (it's a datetime object)
    Variable Should Exist               ${now}
    Should Not Be Equal                 ${now}  ${None}
    Log                                 Generated at timestamp: ${now}
    # Validate that file was also created
    File Should Exist                   ${Temppath}ReturnContent.txt
    ${file_content} =                   Get File  ${Temppath}ReturnContent.txt
    Should Be Equal                     ${data}  ${file_content}

File Can Be Generated With INC And LOOPINC Edge Cases
    [Tags]                              gen_file_inc_edge  dkh
    [Documentation]                     Tests INC and LOOPINC edge cases including:
    ...                                 zero increments, very small increments (high precision),
    ...                                 negative increments, large base values, negative base values,
    ...                                 and combinations of these in both INC and LOOPINC
    ${id} =                                 Set Variable  gen_file_template_11
    ${zero_list} =  Create List  A  B  C
    ${tiny_list} =  Create List  1  2  3  4  5
    ${neg_list} =  Create List  X  Y  Z  W
    ${large_list} =  Create List  Item1  Item2
    ${mix_list} =  Create List  M1  M2  M3
    generate_file                           ${Temppath}INCEdgeCases.txt
    ...                                     ${Data}INCEdgeCases_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     ZEROLOOP=${zero_list}
    ...                                     TINYLOOP=${tiny_list}
    ...                                     NEGLOOP=${neg_list}
    ...                                     LARGELOOP=${large_list}
    ...                                     MIXLOOP=${mix_list}

Error Handling Missing CONSTANT Should Fail
    [Tags]                              gen_file_error_missing_constant  dkh
    [Documentation]                     Tests that generator fails appropriately when a CONSTANT
    ...                                 referenced in template is not provided as parameter
    ${id} =                                 Set Variable  gen_file_template_error_1
    Run Keyword And Expect Error        *Missing constant for ID: MISSING_CONSTANT*
    ...                                 generate_file
    ...                                     ${Temppath}ErrorMissingConstant.txt
    ...                                     ${Data}ErrorMissingConstant_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Nested Loops
    [Tags]                              gen_file_nested_loops  dkh
    [Documentation]                     Tests nested loop functionality with FIXED behavior:
    ...                                 - Outer loop containing inner loop
    ...                                 - ✅ FIXED: INDEX in inner loop now correctly resets [0], [1] for each outer iteration
    ...                                 - ✅ FIXED: LOOPINC state now correctly resets for each outer loop iteration
    ...                                 - Outer loop VALUE is accessible from inner loop (works correctly)
    ${id} =                                 Set Variable  gen_file_template_15
    ${outer} =  Create List  A  B
    ${inner} =  Create List  1  2
    generate_file                           ${Temppath}NestedLoops.txt
    ...                                     ${Data}NestedLoops_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     OUTERLOOP=${outer}
    ...                                     INNERLOOP=${inner}
    # Validate basic structure works
    ${content} =                        Get File  ${Temppath}NestedLoops.txt
    Should Contain                      ${content}  ID: ${id}
    # Validate outer loop works
    Should Contain                      ${content}  Outer[0]: A
    Should Contain                      ${content}  Outer[1]: B
    # Validate inner loop INDEX correctly resets for each outer iteration
    Should Contain                      ${content}  Inner[0]: 1 in A
    Should Contain                      ${content}  Inner[1]: 2 in A
    Should Contain                      ${content}  Inner[0]: 1 in B
    Should Contain                      ${content}  Inner[1]: 2 in B
    # Validate outer loop VALUE is accessible in inner loop
    Should Contain                      ${content}  1 in A
    Should Contain                      ${content}  2 in A
    Should Contain                      ${content}  1 in B
    Should Contain                      ${content}  2 in B
    # Validate LOOPINC correctly resets for each outer iteration
    ${count1a} =                        Get Lines Containing String  ${content}  Inner[0]: 1 in A - Count:
    Should Contain                      ${count1a}  Count: 1.0
    ${count2a} =                        Get Lines Containing String  ${content}  Inner[1]: 2 in A - Count:
    Should Contain                      ${count2a}  Count: 2.0
    ${count1b} =                        Get Lines Containing String  ${content}  Inner[0]: 1 in B - Count:
    Should Contain                      ${count1b}  Count: 1.0
    ${count2b} =                        Get Lines Containing String  ${content}  Inner[1]: 2 in B - Count:
    Should Contain                      ${count2b}  Count: 2.0

File Can Be Generated With Named Loop Index Feature
    [Tags]                              gen_file_named_loop_index  dkh
    [Documentation]                     Tests the new %%%loopname.INDEX%%% feature:
    ...                                 - %%%INDEX%%% works as before (backward compatible)
    ...                                 - %%%loopname.INDEX%%% provides named access to loop index
    ...                                 - Named indices are accessible from nested loops (solving the outer loop access problem)
    ...                                 - Both INDEX and loopname.INDEX return the same value for current loop
    ${id} =                                 Set Variable  gen_file_template_16
    ${items} =  Create List  Alpha  Beta  Gamma
    ${outer} =  Create List  X  Y
    ${inner} =  Create List  1  2  3
    generate_file                           ${Temppath}NamedLoopIndex.txt
    ...                                     ${Data}NamedLoopIndex_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     ITEMS=${items}
    ...                                     OUTER=${outer}
    ...                                     INNER=${inner}
    # Validate file was generated
    ${content} =                        Get File  ${Temppath}NamedLoopIndex.txt
    Should Contain                      ${content}  Test ID: ${id}
    # Validate single loop: INDEX and loopname.INDEX are equivalent
    Should Contain                      ${content}  Item 0 (also 0): Alpha
    Should Contain                      ${content}  Item 1 (also 1): Beta
    Should Contain                      ${content}  Item 2 (also 2): Gamma
    # Validate nested loops: inner INDEX resets
    Should Contain                      ${content}  Inner 0 (named: 0)
    Should Contain                      ${content}  Inner 1 (named: 1)
    Should Contain                      ${content}  Inner 2 (named: 2)
    # Validate nested loops: outer loop index is accessible via outerloop.INDEX
    Should Contain                      ${content}  Inner 0 (named: 0) with outer 0 (X): 1
    Should Contain                      ${content}  Inner 1 (named: 1) with outer 0 (X): 2
    Should Contain                      ${content}  Inner 2 (named: 2) with outer 0 (X): 3
    Should Contain                      ${content}  Inner 0 (named: 0) with outer 1 (Y): 1
    Should Contain                      ${content}  Inner 1 (named: 1) with outer 1 (Y): 2
    Should Contain                      ${content}  Inner 2 (named: 2) with outer 1 (Y): 3

*** Keywords ***
Initialization
    Create Directory                    ${Temppath}

Teardown
    # Optional cleanup
    No Operation
