*** Settings ***
Resource    Common.resource

*** Variables ***
${LOGIN_EMAIL}       css=input[type="email"], input[name="customer[email]"]
${LOGIN_PASSWORD}    css=input[type="password"], input[name="customer[password]"]
${LOGIN_BUTTON}      xpath=(//form[contains(@action, '/account/login')]//*[self::button or self::input][@type='submit'])[1]

*** Keywords ***
Ensure Logged Out And Go To Login Page
    Delete All Cookies
    Go To    ${BASE_URL}/account/login
    Wait For Page Ready

Input Login Form
    [Arguments]    ${email}    ${password}
    Wait And Input    ${LOGIN_EMAIL}       ${email}
    Wait And Input    ${LOGIN_PASSWORD}    ${password}

Click Login Button
    Wait And Click    ${LOGIN_BUTTON}
    Wait For Page Ready

Login Should Be Successful
    ${url_ok}=    Run Keyword And Return Status    Location Should Contain    /account
    ${text_ok}=   Run Keyword And Return Status    Page Should Contain    Tài khoản
    Should Be True    ${url_ok} or ${text_ok}    msg=Lỗi: Đăng nhập thất bại.

Login Should Be Rejected
    ${status1}=    Run Keyword And Return Status    Page Should Contain    Thông tin đăng nhập không hợp lệ.
    Should Be True    ${status1}    msg=Lỗi: Hệ thống không hiển thị bất kỳ thông báo cảnh báo nào khi đăng nhập sai!