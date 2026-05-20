import re
import unicodedata
from urllib.parse import quote
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


class NhenLibrary:
    """Custom keywords for nhen.vn Robot Framework tests.

    These keywords use SeleniumLibrary's active driver, so SeleniumLibrary must be imported
    before or together with this library.
    """

    def _driver(self):
        return BuiltIn().get_library_instance('SeleniumLibrary').driver

    def _normalize(self, text):
        if text is None:
            return ''
        text = str(text).replace('\xa0', ' ').strip().lower()
        text = unicodedata.normalize('NFD', text)
        text = ''.join(ch for ch in text if unicodedata.category(ch) != 'Mn')
        text = text.replace('đ', 'd')
        return re.sub(r'\s+', ' ', text)

    def _parse_money(self, text):
        if text is None:
            return None
        text = str(text)
        matches = re.findall(r'(\d{1,3}(?:[.,]\d{3})+|\d+)\s*₫', text)
        if not matches:
            matches = re.findall(r'(\d{1,3}(?:[.,]\d{3})+)', text)
        if not matches:
            return None
        value = re.sub(r'[^0-9]', '', matches[0])
        return int(value) if value else None

    @keyword('Url Encode')
    def url_encode(self, text):
        return quote(str(text), safe='')

    @keyword('Normalize Text')
    def normalize_text(self, text):
        return self._normalize(text)

    @keyword('Get Html5 Validation Message')
    def get_html5_validation_message(self, css_selector):
        script = """
            const el = document.querySelector(arguments[0]);
            if (!el) { return null; }
            if (typeof el.reportValidity === 'function') { el.reportValidity(); }
            return el.validationMessage || '';
        """
        return self._driver().execute_script(script, css_selector)

    @keyword('Element Css Should Have Validation Error')
    def element_css_should_have_validation_error(self, css_selector):
        message = self.get_html5_validation_message(css_selector)
        if not message:
            raise AssertionError(f"Expected HTML5 validation error for selector: {css_selector}")
        return message

    @keyword('Click Visible Text')
    def click_visible_text(self, text):
        """Click first visible element whose visible text/value exactly matches or contains text."""
        script = r"""
            const expected = String(arguments[0]).trim().toLowerCase();
            const isVisible = el => {
                const style = window.getComputedStyle(el);
                const rect = el.getBoundingClientRect();
                return style && style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
            };
            const getText = el => (el.innerText || el.textContent || el.value || el.getAttribute('aria-label') || '').trim();
            const candidates = Array.from(document.querySelectorAll('button,a,label,span,div,input,li'))
                .filter(isVisible)
                .filter(el => {
                    const t = getText(el).toLowerCase();
                    return t === expected || t.includes(expected);
                })
                .sort((a,b) => {
                    const ar = a.getBoundingClientRect();
                    const br = b.getBoundingClientRect();
                    return (ar.width * ar.height) - (br.width * br.height);
                });
            if (!candidates.length) { return false; }
            const el = candidates[0];
            el.scrollIntoView({block:'center', inline:'center'});
            el.click();
            return true;
        """
        ok = self._driver().execute_script(script, text)
        if not ok:
            raise AssertionError(f"Could not find visible text to click: {text}")

    @keyword('Get Visible Product Names')
    def get_visible_product_names(self):
        script = r"""
            const isVisible = el => {
                const style = window.getComputedStyle(el);
                const rect = el.getBoundingClientRect();
                return style && style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
            };
            const selectors = [
                '.product-name a', '.product-title a', '.item_product_main h3 a', '.item_product h3 a',
                '.product-item h3 a', '.card-product h3 a', 'h3 a[href*="/products/"]',
                'a[href*="/products/"][title]', 'a[href*="/products/"]'
            ];
            const els = Array.from(document.querySelectorAll(selectors.join(','))).filter(isVisible);
            const seen = new Set();
            const names = [];
            for (const el of els) {
                let text = (el.innerText || el.textContent || el.getAttribute('title') || '').trim().replace(/\s+/g, ' ');
                if (!text || text.length < 8) continue;
                if (/khuyến mãi|ưu đãi|image/i.test(text)) continue;
                const href = el.href || '';
                const key = href + '|' + text;
                if (seen.has(key)) continue;
                seen.add(key);
                names.push(text);
            }
            return names;
        """
        return self._driver().execute_script(script)

    @keyword('Get Visible Product Prices')
    def get_visible_product_prices(self):
        script = r"""
            const isVisible = el => {
                const style = window.getComputedStyle(el);
                const rect = el.getBoundingClientRect();
                return style && style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
            };
            const selectors = [
                '.price', '.special-price', '.product-price', '.price-box', '[class*="price"]'
            ];
            const els = Array.from(document.querySelectorAll(selectors.join(','))).filter(isVisible);
            const prices = [];
            for (const el of els) {
                const text = (el.innerText || el.textContent || '').trim().replace(/\s+/g, ' ');
                const match = text.match(/(\d{1,3}(?:[.,]\d{3})+)\s*₫/);
                if (match) {
                    const value = Number(match[1].replace(/[^0-9]/g, ''));
                    if (value > 0 && value < 100000000) prices.push(value);
                }
            }
            return prices.slice(0, 24);
        """
        return self._driver().execute_script(script)

    @keyword('Visible Product List Should Not Be Empty')
    def visible_product_list_should_not_be_empty(self):
        names = self.get_visible_product_names()
        if len(names) == 0:
            raise AssertionError('Expected at least one visible product, but no product name was found.')
        return names

    @keyword('Visible Product Results Should Contain Keyword')
    def visible_product_results_should_contain_keyword(self, keyword):
        names = self.visible_product_list_should_not_be_empty()
        expected = self._normalize(keyword)
        matched = [name for name in names if expected in self._normalize(name)]
        if not matched:
            raise AssertionError(f"No visible product name contains keyword '{keyword}'. Visible names: {names[:10]}")
        return matched

    @keyword('All Visible Product Results Should Contain Keyword')
    def all_visible_product_results_should_contain_keyword(self, keyword):
        names = self.visible_product_list_should_not_be_empty()
        expected = self._normalize(keyword)
        invalid = [name for name in names if expected not in self._normalize(name)]
        if invalid:
            raise AssertionError(
                f"These products do not contain required keyword '{keyword}': {invalid[:10]}"
            )
        return names

    @keyword('Visible Product Prices Should Be Less Than Or Equal')
    def visible_product_prices_should_be_less_than_or_equal(self, max_price):
        max_price = int(max_price)
        prices = self.get_visible_product_prices()
        if not prices:
            raise AssertionError('Expected visible product prices, but none were found.')
        invalid = [p for p in prices if p > max_price]
        if invalid:
            raise AssertionError(f'Prices above {max_price}: {invalid[:10]}. All visible prices: {prices[:20]}')
        return prices

    @keyword('Visible Product Prices Should Be Sorted Ascending')
    def visible_product_prices_should_be_sorted_ascending(self):
        prices = self.get_visible_product_prices()
        if len(prices) < 2:
            raise AssertionError(f'Need at least 2 visible prices to verify sorting, got {prices}')
        bad = [(prices[i], prices[i+1]) for i in range(len(prices)-1) if prices[i] > prices[i+1]]
        if bad:
            raise AssertionError(f'Prices are not sorted ascending. Bad pairs: {bad[:5]}. Prices: {prices[:20]}')
        return prices

    @keyword('Visible Product Prices Should Be Sorted Descending')
    def visible_product_prices_should_be_sorted_descending(self):
        prices = self.get_visible_product_prices()
        if len(prices) < 2:
            raise AssertionError(f'Need at least 2 visible prices to verify sorting, got {prices}')
        bad = [(prices[i], prices[i+1]) for i in range(len(prices)-1) if prices[i] < prices[i+1]]
        if bad:
            raise AssertionError(f'Prices are not sorted descending. Bad pairs: {bad[:5]}. Prices: {prices[:20]}')
        return prices

    @keyword('Visible Product Names Should Be Sorted Ascending')
    def visible_product_names_should_be_sorted_ascending(self):
        names = self.visible_product_list_should_not_be_empty()
        normalized = [self._normalize(n) for n in names]
        if normalized != sorted(normalized):
            raise AssertionError(f'Product names are not sorted A-Z. Names: {names[:20]}')
        return names

    @keyword('Visible Product Names Should Be Sorted Descending')
    def visible_product_names_should_be_sorted_descending(self):
        names = self.visible_product_list_should_not_be_empty()
        normalized = [self._normalize(n) for n in names]
        if normalized != sorted(normalized, reverse=True):
            raise AssertionError(f'Product names are not sorted Z-A. Names: {names[:20]}')
        return names

    @keyword('Page Should Show No Product Result')
    def page_should_show_no_product_result(self):
        body = self._driver().find_element('tag name', 'body').text
        body_norm = self._normalize(body)
        messages = [
            'khong tim thay', 'khong co san pham', 'khong co ket qua',
            'no results', 'not found', 'hong co gi'
        ]
        if any(m in body_norm for m in messages):
            return True
        names = self.get_visible_product_names()
        if len(names) == 0:
            return True
        raise AssertionError(f'Expected no product result, but found product names: {names[:10]}')

    @keyword('Current Page Should Contain Any Text')
    def current_page_should_contain_any_text(self, *texts):
        body = self._driver().find_element('tag name', 'body').text
        norm_body = self._normalize(body)
        for text in texts:
            if self._normalize(text) in norm_body:
                return text
        raise AssertionError(f'Page does not contain any expected text: {texts}')

    @keyword('Current Url Should Contain Any')
    def current_url_should_contain_any(self, *parts):
        url = self._driver().current_url
        for part in parts:
            if str(part) in url:
                return url
        raise AssertionError(f'Current URL "{url}" does not contain any of: {parts}')

    @keyword('Page Text Should Contain Normalized')
    def page_text_should_contain_normalized(self, expected):
        body = self._driver().find_element('tag name', 'body').text
        if self._normalize(expected) not in self._normalize(body):
            raise AssertionError(f"Page text does not contain '{expected}'.")
