################################################
#
# Unit tests for template based generator
# Naming Generation 2
#
################################################

*** Settings ***
Force Tags      disabled  internal
Resource        ../TestFileGenerators.robot
Library         Collections
Library         String
Library         OperatingSystem
Suite Setup     Initialization
Test Teardown   Teardown
Documentation   Suite provides tests for "Timeseries Group keywords" keyword. To make sure it works correctly in different scenarios.

*** Variables ***
${Data}         ${CURDIR}/data/
${Temppath}     ${CURDIR}/temp/

*** Test Cases ***

File Can Be Generated With Template
    [Tags]                              gen_file_template_1  dkh
    ${id} =                                 Set Variable  gen_file_template_1
    Generate File                           ${Temppath}FirstFileGenerated.txt
    ...                                     ${Data}First_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     ENV=MyEnvironment
    ...                                     TIMEENV=myTimeEnvironment

File Can Be Generated With Template And ENV Variables
    [Tags]                              gen_file_template_2  dkh
    ${id} =                                 Set Variable  gen_file_template_2
    Generate File                           ${Temppath}SecondFileGenerated.txt
    ...                                     ${Data}Second_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Loops Using Int
    [Tags]                              gen_file_loop  dkh
    ${id} =                                 Set Variable  gen_file_template_3
    ${l1} =  Create List  ABC  DEF  XYZ
    ${l2} =  Create List  333  444  555
    Generate File                           ${Temppath}Looped.txt
    ...                                     ${Data}Loop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     MYLOOPINPUT=${3}
    ...                                     INDEXSHIFT=1
    ...                                     MYLIST1=${l1}
    ...                                     MYLIST2=${l2}
    ...                                     NOTE=Record created for ${id}

File Can Be Generated With Loops Using List
    [Tags]                              gen_file_looplist  dkh
    ${id} =                                 Set Variable  gen_file_template_4
    ${ml} =  Create List  A  B  C
    ${l1} =  Create List  ABC  DEF  XYZ
    ${l2} =  Create List  333  444  555
    Generate File                           ${Temppath}LoopedList.txt
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
    Generate File                           ${Temppath}MultiLooped.txt
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
    Generate File                           ${Temppath}MultipleINC.txt
    ...                                     ${Data}MultipleINC_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Multiple LOOPINC Counters In Same Loop
    [Tags]                              gen_file_multiple_loopinc  dkh
    [Documentation]                     Tests that multiple LOOPINC counters within the same loop
    ...                                 maintain separate states and increment independently for each iteration
    ${id} =                                 Set Variable  gen_file_template_7
    ${loop_data} =  Create List  Item-A  Item-B  Item-C  Item-D  Item-E
    ${items} =  Create List  Product1  Product2  Product3  Product4  Product5
    Generate File                           ${Temppath}MultipleLOOPINC.txt
    ...                                     ${Data}MultipleLOOPINC_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     MYLOOPINPUT=${loop_data}
    ...                                     ITEMS=${items}
    ...                                     RECORDCOUNT=5

File Can Be Generated With DateTime Edge Cases
    [Tags]                              gen_file_datetime_edge  dkh
    [Documentation]                     Tests edge cases for date/time placeholders including:
    ...                                 zero offsets, large positive/negative offsets,
    ...                                 various date format strings, and boundary conditions
    ${id} =                                 Set Variable  gen_file_template_8
    Generate File                           ${Temppath}DateTimeEdgeCases.txt
    ...                                     ${Data}DateTimeEdgeCases_TEMPLATE.txt
    ...                                     ID=${id}

File Can Be Generated With Loop Edge Cases
    [Tags]                              gen_file_loop_edge  dkh
    [Documentation]                     Tests loop edge cases including:
    ...                                 empty loop (0 iterations), single iteration,
    ...                                 large loop (100 iterations), INDEXSHIFT with positive value,
    ...                                 and multiple synchronized LOOPLISTs
    ${id} =                                 Set Variable  gen_file_template_9
    # Edge case data
    ${shift_list} =  Create List  Alpha  Beta  Gamma
    ${list_data} =  Create List  ID1  ID2
    ${tags} =  Create List  TAG-A  TAG-B
    ${status} =  Create List  Active  Pending
    Generate File                           ${Temppath}LoopEdgeCases.txt
    ...                                     ${Data}LoopEdgeCases_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     EMPTYLOOP=${0}
    ...                                     SINGLELOOP=${1}
    ...                                     LARGELOOP=${100}
    ...                                     INDEXSHIFT=10
    ...                                     SHIFTLOOP=${shift_list}
    ...                                     LISTLOOP=${list_data}
    ...                                     TAGS=${tags}
    ...                                     STATUS=${status}

File Can Be Generated With Negative INDEXSHIFT
    [Tags]                              gen_file_negative_indexshift  dkh
    [Documentation]                     Tests loop with negative INDEXSHIFT value
    ${id} =                                 Set Variable  gen_file_template_10
    ${test_list} =  Create List  Item1  Item2  Item3  Item4
    Generate File                           ${Temppath}NegativeIndexShift.txt
    ...                                     ${Data}NegativeIndexShift_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     INDEXSHIFT=-5
    ...                                     TESTLOOP=${test_list}

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
    Generate File                           ${Temppath}INCEdgeCases.txt
    ...                                     ${Data}INCEdgeCases_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     ZEROLOOP=${zero_list}
    ...                                     TINYLOOP=${tiny_list}
    ...                                     NEGLOOP=${neg_list}
    ...                                     LARGELOOP=${large_list}
    ...                                     MIXLOOP=${mix_list}

File And Content Can Be Generated And Content Returned
    [Tags]                              gen_file_return_content  dkh
    [Documentation]                     Tests "Generate File And Return Content" keyword which:
    ...                                 - Generates file to specified path
    ...                                 - Returns both the generated content and timestamp
    ...                                 Validates that both return values are populated correctly
    ${id} =                                 Set Variable  gen_file_template_12
    ${items} =  Create List  Product-A  Product-B  Product-C
    ${data}  ${now} =                   Generate File And Return Content
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

Error Handling Missing CONSTANT Should Fail
    [Tags]                              gen_file_error_missing_constant  dkh
    [Documentation]                     Tests that generator fails appropriately when a CONSTANT
    ...                                 referenced in template is not provided as parameter
    ${id} =                                 Set Variable  gen_file_template_error_1
    Run Keyword And Expect Error        *Missing constant for ID: MISSING_CONSTANT*
    ...                                 Generate File
    ...                                     ${Temppath}ErrorMissingConstant.txt
    ...                                     ${Data}ErrorMissingConstant_TEMPLATE.txt
    ...                                     ID=${id}

Error Handling Mismatched LOOPLIST Length Should Fail
    [Tags]                              gen_file_error_mismatched_list  dkh
    [Documentation]                     Tests that generator fails when LOOPLIST length
    ...                                 doesn't match the loop size
    ${id} =                                 Set Variable  gen_file_template_error_2
    ${loop_data} =  Create List  A  B  C
    ${list1} =  Create List  X  Y
    ${list2} =  Create List  1  2  3
    Run Keyword And Expect Error        *LOOPLIST 'LIST1' length*does not match loop size*
    ...                                 Generate File
    ...                                     ${Temppath}ErrorMismatchedList.txt
    ...                                     ${Data}ErrorMismatchedList_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     LOOPINPUT=${loop_data}
    ...                                     LIST1=${list1}
    ...                                     LIST2=${list2}

Error Handling Invalid Loop Input Should Fail
    [Tags]                              gen_file_error_invalid_loop  dkh
    [Documentation]                     Tests that generator fails when loop input is neither int nor list
    ${id} =                                 Set Variable  gen_file_template_error_3
    Run Keyword And Expect Error        *Loop input 'INVALIDLOOP' should be a list or int*
    ...                                 Generate File
    ...                                     ${Temppath}ErrorInvalidLoop.txt
    ...                                     ${Data}ErrorInvalidLoop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     INVALIDLOOP=NotAnIntOrList

Error Handling Invalid INDEXSHIFT Should Fail
    [Tags]                              gen_file_error_invalid_indexshift  dkh
    [Documentation]                     Tests that generator fails when INDEXSHIFT is not an integer
    ${id} =                                 Set Variable  gen_file_template_error_4
    ${loop_data} =  Create List  A  B  C
    Run Keyword And Expect Error        *INDEXSHIFT must be an integer*
    ...                                 Generate File
    ...                                     ${Temppath}ErrorInvalidIndexShift.txt
    ...                                     ${Data}ErrorInvalidLoop_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     INDEXSHIFT=NotAnInteger
    ...                                     INVALIDLOOP=${loop_data}

Error Handling LOOPLIST Not A List Should Fail
    [Tags]                              gen_file_error_looplist_not_list  dkh
    [Documentation]                     Tests that generator fails when LOOPLIST parameter
    ...                                 is provided but is not a list type
    ${id} =                                 Set Variable  gen_file_template_error_5
    ${loop_data} =  Create List  A  B  C
    Run Keyword And Expect Error        *LOOPLIST 'BADLIST' must be a list*
    ...                                 Generate File
    ...                                     ${Temppath}ErrorBadListType.txt
    ...                                     ${Data}ErrorBadListType_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     LOOPINPUT=${loop_data}
    ...                                     BADLIST=NotAList

File Can Be Generated With Environmental And Robot Variables
    [Tags]                              gen_file_env_vars  dkh
    [Documentation]                     Tests that Robot Framework suite-level variables
    ...                                 are correctly substituted via Replace Variables, and
    ...                                 test-level variables can be passed as CONSTANT parameters.
    ...                                 Both work alongside template placeholders (NOW, INC, LOOP).
    ${id} =                                 Set Variable  gen_file_template_13
    # Set test-level variables (will be passed as CONSTANT parameters)
    ${TEST_ENV} =                       Set Variable  Production
    ${CONFIG_PATH} =                    Set Variable  /etc/config/app.conf
    ${SERVICE_NAME} =                   Set Variable  MyTestService
    ${items} =  Create List  Item-1  Item-2  Item-3
    # Generate file - test-level vars must be passed as parameters
    Generate File                           ${Temppath}EnvironmentalVars.txt
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

File Can Be Generated With Complex Feature Combinations
    [Tags]                              gen_file_complex_combinations  dkh
    [Documentation]                     Tests complex combinations of features:
    ...                                 - INC counters both inside and outside loops
    ...                                 - CONSTANT, NOW, and LOOPINC all used together inside loops
    ...                                 - Multiple independent loops with different features
    ...                                 - Multiple different INC counters with different parameters
    ...                                 NOTE: Global INC inside loops currently resets due to recursive process_text calls
    ${id} =                                 Set Variable  gen_file_template_14
    ${loop1} =  Create List  Alpha  Beta
    ${loop2} =  Create List  X  Y  Z
    ${tags} =  Create List  TAG-1  TAG-2  TAG-3
    Generate File                           ${Temppath}ComplexCombinations.txt
    ...                                     ${Data}ComplexCombinations_TEMPLATE.txt
    ...                                     ID=${id}
    ...                                     CATEGORY=TestCategory
    ...                                     LOOP1=${loop1}
    ...                                     LOOP2=${loop2}
    ...                                     TAGS=${tags}
    # Validate combinations work correctly
    ${content} =                        Get File  ${Temppath}ComplexCombinations.txt
    Should Contain                      ${content}  ID: ${id}
    # Validate global INC counters progress correctly
    Should Contain                      ${content}  Global-A: 10.0
    Should Contain                      ${content}  Global-A: 15.0
    Should Contain                      ${content}  Global-A: 20.0
    Should Contain                      ${content}  Global-B: 100.0
    Should Contain                      ${content}  Global-B: 150.0
    Should Contain                      ${content}  Global-B: 200.0
    Should Contain                      ${content}  Global-C: 1.0
    # Validate loop 1: CONSTANT + NOW + LOOPINC
    Should Contain                      ${content}  [0] TestCategory at
    Should Contain                      ${content}  Count: 1.0
    Should Contain                      ${content}  Value: Alpha
    Should Contain                      ${content}  [1] TestCategory at
    Should Contain                      ${content}  Count: 2.0
    Should Contain                      ${content}  Value: Beta
    # Validate loop 2: LOOPLIST + LOOPINC + CONSTANT
    Should Contain                      ${content}  Item 0: TAG-1
    Should Contain                      ${content}  Inc: 0.5
    Should Contain                      ${content}  Cat: TestCategory
    Should Contain                      ${content}  Item 1: TAG-2
    Should Contain                      ${content}  Inc: 0.6
    Should Contain                      ${content}  Item 2: TAG-3
    Should Contain                      ${content}  Inc: 0.7

File Can Be Generated With Nested Loops
    [Tags]                              gen_file_nested_loops  dkh  known-issue
    [Documentation]                     Tests nested loop functionality:
    ...                                 - Outer loop containing inner loop
    ...                                 - **KNOWN ISSUE**: INDEX in inner loop incorrectly uses outer loop index
    ...                                 - **KNOWN ISSUE**: LOOPINC state carries across outer iterations instead of resetting
    ...                                 - Outer loop VALUE is accessible from inner loop (works correctly)
    ...                                 These issues need to be fixed during refactoring
    ${id} =                                 Set Variable  gen_file_template_15
    ${outer} =  Create List  A  B
    ${inner} =  Create List  1  2
    Generate File                           ${Temppath}NestedLoops.txt
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
    # Validate inner loop executes (with known issues)
    Should Contain                      ${content}  Inner[0]: 1 in A
    Should Contain                      ${content}  Inner[0]: 2 in A
    Should Contain                      ${content}  Inner[1]: 1 in B
    Should Contain                      ${content}  Inner[1]: 2 in B
    # Validate outer loop VALUE is accessible (this works correctly)
    Should Contain                      ${content}  1 in A
    Should Contain                      ${content}  2 in A
    Should Contain                      ${content}  1 in B
    Should Contain                      ${content}  2 in B
    # Document current LOOPINC behavior (incorrect - doesn't reset)
    Should Contain                      ${content}  Count: 1.0
    Should Contain                      ${content}  Count: 2.0

*** Keywords ***
Initialization
    No Operation

Teardown
    No Operation

