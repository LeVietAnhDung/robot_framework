*** Settings ***
Resource    Common.resource
Resource    ../Data/TestData.resource
Library     String
Library     Collections

*** Variables ***
${PRODUCT_ITEM}       xpath=//*[contains(@class, 'product-name') or contains(@class, 'product-title') or contains(@class, 'pro-name')]//a | //div[contains(@class, 'product-detail')]//h3
${PRODUCT_PRICE}      xpath=//div[contains(@class, 'product-price') or contains(@class, 'price')]//span[contains(@class, 'current') or contains(@class, 'price')] | //span[contains(@class, 'price')]

*** Keywords ***
Open Filter Sort Page
    Go To    ${BASE_URL}/collections/all
    Wait For Page Ready
    Visible Product List Should Not Be Empty

Click Filter Exact Text
    [Arguments]    ${text}
    # Đã nâng cấp: Dùng lệnh CONTAINS (Chứa) thay vì bằng tuyệt đối để bỏ qua các con số đếm (VD: "M (15)")
    ${locator}=    Set Variable    xpath=//*[self::label or self::a or self::span or self::button][contains(normalize-space(.), '${text}') or contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), translate('${text}', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))]

    # Đã nâng cấp: Cuộn chuột đến phần tử và dùng Javascript Click để vượt qua lỗi bị che khuất UI
    Wait Until Page Contains Element    ${locator}    timeout=5s
    Scroll Element Into View    ${locator}
    Sleep    0.5s
    ${element}=    Get WebElement    ${locator}
    Run Keyword And Ignore Error    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    Sleep    2s

Apply Filter Option
    [Arguments]    ${section_name}    ${option_text}
    ${option_locator}=    Set Variable    xpath=//*[self::label or self::a or self::span or self::button][contains(normalize-space(.), '${option_text}') or contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), translate('${option_text}', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))]

    ${is_present}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${option_locator}    timeout=2s

    IF    not ${is_present}
        ${section_locator}=    Set Variable    xpath=//*[self::h2 or self::h3 or self::h4 or self::button or self::legend or self::span or contains(@class, 'title')][contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), translate('${section_name}', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))]
        ${section_found}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${section_locator}    timeout=2s
        IF    ${section_found}
            Scroll Element Into View    ${section_locator}
            ${sec_el}=    Get WebElement    ${section_locator}
            Run Keyword And Ignore Error    Execute Javascript    arguments[0].click();    ARGUMENTS    ${sec_el}
            Sleep    1s
        END
    END

    ${is_still_hidden}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${option_locator}    timeout=1s
    IF    not ${is_still_hidden}
        ${view_more_locator}=    Set Variable    xpath=//*[self::button or self::a or self::span][contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'xem thêm')]
        ${has_view_more}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${view_more_locator}    timeout=1s
        IF    ${has_view_more}
            ${elements}=    Get WebElements    ${view_more_locator}
            FOR    ${elem}    IN    @{elements}
                ${is_displayed}=    Run Keyword And Return Status    Element Should Be Visible    ${elem}
                IF    ${is_displayed}
                    Run Keyword And Ignore Error    Execute Javascript    arguments[0].click();    ARGUMENTS    ${elem}
                END
            END
            Sleep    1.5s
        END
    END

    Click Filter Exact Text    ${option_text}
    Wait For Page Ready


# CÁC KEYWORD LỌC VÀ SẮP XẾP
Apply Size Filter
    Apply Filter Option    Kích thước    ${FILTER_SIZE}

Apply Price Filter
    Apply Filter Option    Mức giá    ${FILTER_PRICE_TEXT}

Click Sort Variant
    [Arguments]    @{variants}
    ${sort_toggle}=    Set Variable    xpath=//*[contains(@class, 'sort') or contains(@id, 'sort')]//*[self::button or self::span or self::div[contains(@class, 'selected')]] | //*[self::label or self::span or self::button or self::div][contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'sắp xếp')]
    ${toggle_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${sort_toggle}    timeout=2s
    IF    ${toggle_visible}
        Run Keyword And Ignore Error    Click Element    ${sort_toggle}
        Sleep    1s
    END

    FOR    ${text}    IN    @{variants}
        ${is_select}=    Run Keyword And Return Status    Select From List By Label    xpath=//select[contains(@class, 'sort') or contains(@name, 'SortBy') or contains(@id, 'SortBy')]    ${text}
        IF    ${is_select}
            Sleep    2s
            RETURN
        END
    END

    FOR    ${text}    IN    @{variants}
        ${locator}=    Set Variable    xpath=//*[self::label or self::a or self::span or self::button or self::li or self::option][normalize-space(.)='${text}']
        ${status}=    Run Keyword And Return Status    Wait And Click    ${locator}
        IF    ${status}
            Sleep    2s
            RETURN
        END
    END
    Fail    Lỗi: Không tìm thấy nút Sắp xếp nào chứa chữ: @{variants}

Sort By Price Low To High
    Click Sort Variant    Giá tăng dần

Sort By Name A To Z
    Click Sort Variant    Tên A → Z

# ==========================================
# CÁC KEYWORD XÁC MINH (VERIFY)
# ==========================================
Product List Should Be Displayed
    Visible Product List Should Not Be Empty

Visible Product List Should Not Be Empty
    Wait Until Page Contains Element    ${PRODUCT_ITEM}    timeout=${TIMEOUT}
    ${count}=    Get Element Count    ${PRODUCT_ITEM}
    Should Be True    ${count} > 0    msg=Lỗi: Không tìm thấy sản phẩm nào!

Product List Should Match Size Filter
    Page Should Contain    ${FILTER_SIZE}

Get All Product Prices As Numbers
    Wait Until Page Contains Element    ${PRODUCT_PRICE}    timeout=${TIMEOUT}
    ${elements}=    Get WebElements    ${PRODUCT_PRICE}
    ${prices}=    Create List
    FOR    ${elem}    IN    @{elements}
        ${text}=    Get Text    ${elem}
        ${clean_text}=    Replace String    ${text}    ₫    ${EMPTY}
        ${clean_text}=    Replace String    ${clean_text}    đ    ${EMPTY}
        ${clean_text}=    Replace String    ${clean_text}    ,    ${EMPTY}
        ${clean_text}=    Replace String    ${clean_text}    .    ${EMPTY}
        ${clean_text}=    Strip String    ${clean_text}
        ${is_number}=    Evaluate    "${clean_text}".isdigit()
        IF    ${is_number}
            ${price_num}=    Convert To Integer    ${clean_text}
            Append To List    ${prices}    ${price_num}
        END
    END
    RETURN    ${prices}

Product List Should Match Price Filter
    Visible Product Prices Should Be Less Than Or Equal    ${FILTER_PRICE_MAX}

Visible Product Prices Should Be Less Than Or Equal
    [Arguments]    ${max_price}
    ${prices}=    Get All Product Prices As Numbers
    ${max_num}=    Convert To Integer    ${max_price}
    FOR    ${price}    IN    @{prices}
        Should Be True    ${price} <= ${max_num}    msg=Lỗi: Sản phẩm có giá ${price} bị lọt vào bộ lọc bé hơn ${max_price}!
    END

Visible Product Prices Should Be Sorted Ascending
    ${prices}=    Get All Product Prices As Numbers
    ${sorted_prices}=    Copy List    ${prices}
    Sort List    ${sorted_prices}
    Lists Should Be Equal    ${prices}    ${sorted_prices}    msg=Lỗi: Danh sách giá sản phẩm KHÔNG ĐƯỢC sắp xếp Tăng dần!

Get All Product Names
    Wait Until Page Contains Element    ${PRODUCT_ITEM}    timeout=${TIMEOUT}
    ${elements}=    Get WebElements    ${PRODUCT_ITEM}
    ${names}=    Create List
    FOR    ${elem}    IN    @{elements}
        ${text}=    Get Text    ${elem}
        ${clean_text}=    Strip String    ${text}
        Append To List    ${names}    ${clean_text}
    END
    RETURN    ${names}

Visible Product Names Should Be Sorted Ascending
    ${names}=    Get All Product Names
    ${sorted_names}=    Copy List    ${names}
    Sort List    ${sorted_names}
    Lists Should Be Equal    ${names}    ${sorted_names}    msg=Lỗi: Tên sản phẩm KHÔNG ĐƯỢC sắp xếp từ A tới Z!