*** Settings ***
Resource    ../Resources/Common.resource
Resource    ../Resources/LoginPage.resource

Suite Setup       Open Nhen Website
Suite Teardown    Close Nhen Website
Test Setup        Ensure Logged Out And Go To Login Page

*** Test Cases ***
TC01_Login_With_Valid_Account
    [Documentation]    Kiểm tra người dùng đăng nhập thành công với tài khoản đúng.
    [Tags]    login    positive    smoke
    Input Login Form    ${EXISTING_EMAIL}    ${VALID_PASSWORD}
    Click Login Button
    Login Should Be Successful

TC02_Login_With_Wrong_Password
    [Documentation]    Kiểm tra hệ thống từ chối khi nhập sai mật khẩu.
    [Tags]    login    negative
    Input Login Form    ${EXISTING_EMAIL}    ${WRONG_PASSWORD}
    Click Login Button
    Login Should Be Rejected

TC03_Login_With_Unregistered_Email
    [Documentation]    Kiểm tra hệ thống báo lỗi khi dùng email chưa đăng ký.
    [Tags]    login    negative
    Input Login Form    ${NOT_REGISTERED_EMAIL}    ${VALID_PASSWORD}
    Click Login Button
    Login Should Be Rejected