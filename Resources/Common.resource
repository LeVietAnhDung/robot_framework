*** Settings ***
Library     SeleniumLibrary
Library     ../Resources/NhenLibrary.py
Resource    ../Data/TestData.resource

*** Keywords ***
Open Nhen Website
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --no-sandbox

    Open Browser    ${BASE_URL}    ${BROWSER}    options=${options}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Wait For Page Ready

Close Nhen Website
    Close Browser

Wait For Page Ready
    Sleep    1.5s
    Wait Until Keyword Succeeds    10x    1s    Execute Javascript    return document.readyState == 'complete'

Go To Home Page
    Go To    ${BASE_URL}
    Wait For Page Ready

Wait And Click
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    timeout=${TIMEOUT}
    Click Element    ${locator}

Wait And Input
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=${TIMEOUT}
    Input Text    ${locator}    ${text}