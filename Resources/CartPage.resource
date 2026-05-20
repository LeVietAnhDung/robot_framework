*** Settings ***
Resource    Common.resource
Resource    ../Data/TestData.resource

*** Variables ***
${PRODUCT_SIZE_LOCATOR}    xpath=(//label[contains(normalize-space(.),'${STABLE_PRODUCT_SIZE}')])[1]
${ADD_TO_CART_BUTTON}      xpath=(//button[contains(translate(normalize-space(.),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),'THÊM VÀO GIỎ') or contains(@class,'add-to-cart') or @name='add'])[1]
${CHECKOUT_BUTTON}         xpath=(//button[contains(normalize-space(.),'Tiến hành thanh toán') or contains(normalize-space(.),'Thanh toán') or contains(@class,'checkout')])[1]
${REMOVE_BUTTON}           xpath=(//a[contains(@title,'Xóa') or contains(@class,'remove') or contains(@href,'change')])[1]
${EMPTY_CART_TEXT}         xpath=//*[contains(normalize-space(.),'Hổng') or contains(normalize-space(.),'giỏ hết') or contains(normalize-space(.),'Mua sắm ngay')]

*** Keywords ***
Open Stable Product Page
    Go To    ${STABLE_PRODUCT_URL}
    Wait For Page Ready
    Page Should Contain    ${STABLE_PRODUCT_NAME}
    Page Should Contain    ${STABLE_PRODUCT_PRICE}
    Wait Until Page Contains Element    ${ADD_TO_CART_BUTTON}    timeout=${TIMEOUT}

Select Product Size If Visible
    ${size_visible}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${PRODUCT_SIZE_LOCATOR}    timeout=3s
    IF    ${size_visible}
        Scroll Element Into View    ${PRODUCT_SIZE_LOCATOR}
        Sleep    0.3s
        Wait And Click    ${PRODUCT_SIZE_LOCATOR}
        Sleep    0.3s
    END

Add Stable Product To Cart
    Open Stable Product Page
    Select Product Size If Visible
    Wait And Click    ${ADD_TO_CART_BUTTON}
    Sleep    1.5s
    Wait For Page Ready
    Go To    ${BASE_URL}/cart
    Wait For Page Ready

Cart Should Have Product
    Go To    ${BASE_URL}/cart
    Wait For Page Ready
    Page Should Contain    ${STABLE_PRODUCT_NAME}
    Page Should Contain    ${STABLE_PRODUCT_PRICE}

Remove First Item In Cart
    Go To    ${BASE_URL}/cart
    Wait For Page Ready
    ${remove_visible}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${REMOVE_BUTTON}    timeout=5s
    IF    ${remove_visible}
        Wait And Click    ${REMOVE_BUTTON}
    ELSE
        Delete All Cookies
        Reload Page
    END
    Wait For Page Ready

Cart Should Be Empty
    Go To    ${BASE_URL}/cart
    Wait For Page Ready
    Wait Until Page Contains Element    ${EMPTY_CART_TEXT}    timeout=${TIMEOUT}
    Page Should Contain    Hổng

Go To Checkout Page Without Completing Order
    Go To    ${BASE_URL}/cart
    Wait For Page Ready
    Wait And Click    ${CHECKOUT_BUTTON}
    Wait For Page Ready
    Location Should Contain    /checkout