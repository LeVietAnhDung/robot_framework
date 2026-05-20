*** Variables ***
${BASE_URL}                https://nhen.vn
${BROWSER}                 chrome
${TIMEOUT}                 10s

# Dữ liệu Test Đăng nhập
${EXISTING_EMAIL}          anhdung@yopmail.com
${VALID_PASSWORD}          Anhlaso1
${WRONG_PASSWORD}          SaiMatKhau123
${NOT_REGISTERED_EMAIL}    anhtrai@yopmail.com

# Dữ liệu Test Lọc / Sắp xếp
${FILTER_SIZE}             M
${FILTER_PRICE_TEXT}       Dưới 1,000,000₫
${FILTER_PRICE_MAX}        1000000

# Thông tin một sản phẩm
${STABLE_PRODUCT_URL}       https://nhen.vn/products/ao-bong-da-manchester-united-san-nha-2026-2027-fan-ka6871
${STABLE_PRODUCT_NAME}      ÁO BÓNG ĐÁ MANCHESTER UNITED SÂN NHÀ 2026/27 CHÍNH HÃNG FAN KA6871
${STABLE_PRODUCT_PRICE}     1,980,000
${STABLE_PRODUCT_SIZE}      S(UK)
${ORDER_NOTE_TEXT}          Giao hàng giờ hành chính giúp em.