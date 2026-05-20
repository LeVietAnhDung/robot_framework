*** Settings ***
Resource    ../Resources/Common.resource
Resource    ../Resources/FilterSortPage.resource

Suite Setup       Open Nhen Website
Suite Teardown    Close Nhen Website
Test Setup        Open Filter Sort Page

*** Test Cases ***
TC03_Filter_By_Price_Range
    [Documentation]    Kiểm tra thuật toán lọc sản phẩm theo khoảng giá. Kịch bản yêu cầu hệ thống bóc tách chuỗi tiền tệ (VNĐ), ép kiểu sang số nguyên và đối chiếu với điều kiện lọc (<= 1.000.000đ).
    [Tags]    filter    known_bug    demo
    Apply Price Filter
    Product List Should Be Displayed
    Product List Should Match Price Filter

TC09_Sort_Price_Low_To_High
    [Documentation]    Kiểm tra thuật toán sắp xếp mảng dữ liệu. Kịch bản tự động cào (crawl) toàn bộ giá trị hiển thị, lưu vào mảng (Array), thực hiện thuật toán sắp xếp tăng dần và đối chiếu với kết quả trả về từ UI.
    [Tags]    sort    known_bug    demo
    Sort By Price Low To High
    Product List Should Be Displayed
    Visible Product Prices Should Be Sorted Ascending

TC14_Filter_And_Sort_Together
    [Documentation]    Kiểm thử luồng thao tác chéo: Kết hợp đa điều kiện vừa Lọc theo kích thước (Size) vừa Sắp xếp tên từ A-Z để đảm bảo hệ thống không bị xung đột hoặc mất trạng thái.
    [Tags]    filter    sort    regression    demo
    Apply Size Filter
    Sort By Name A To Z
    Product List Should Be Displayed
    Product List Should Match Size Filter
    Visible Product Names Should Be Sorted Ascending