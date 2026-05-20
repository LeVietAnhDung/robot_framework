*** Settings ***
Resource    ../Resources/Common.resource
Resource    ../Resources/CartPage.resource

Suite Setup       Open Nhen Website
Suite Teardown    Close Nhen Website
Test Setup        Delete All Cookies

*** Test Cases ***
TC02_Add_Product_To_Cart
    [Documentation]    Kiểm tra luồng cơ bản nhất: Thêm thành công một sản phẩm cố định vào giỏ hàng.
    [Tags]    cart    smoke    demo
    Add Stable Product To Cart
    Cart Should Have Product

TC09_Remove_Product_From_Cart
    [Documentation]    Kiểm tra tính năng quản lý trạng thái: Xóa sản phẩm ra khỏi giỏ hàng và xác minh giỏ hàng trở về trạng thái trống.
    [Tags]    cart    regression    demo
    Add Stable Product To Cart
    Remove First Item In Cart
    Cart Should Be Empty

TC14_Go_To_Checkout_Page
    [Documentation]    Kiểm tra luồng: Bấm nút Thanh toán và chuyển hướng an toàn sang trang Checkout của hệ thống.
    [Tags]    cart    checkout    demo
    Add Stable Product To Cart
    Go To Checkout Page Without Completing Order