# Keep the official ERPNext/Frappe versions in sync.
# Only overlay branding — do not replace the whole app with this develop tree.
FROM frappe/erpnext:v16.52.1

USER root
WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe erpnext/public/images/erpnext-logo.png /tmp/erpnext-logo.png
COPY --chown=frappe:frappe erpnext/public/images/ledstackerp-watermark.png /tmp/ledstackerp-watermark.png
COPY --chown=frappe:frappe erpnext/public/css/ledstackerp-watermark.css /tmp/ledstackerp-watermark.css
COPY --chown=frappe:frappe erpnext/public/css/ledstackerp-landing.css /tmp/ledstackerp-landing.css
COPY --chown=frappe:frappe erpnext/www/home.html /tmp/home.html
COPY --chown=frappe:frappe erpnext/www/home.py /tmp/home.py
COPY --chown=frappe:frappe erpnext/public/images/landing-hero.jpg /tmp/landing-hero.jpg
COPY --chown=frappe:frappe erpnext/public/images/landing-finance.jpg /tmp/landing-finance.jpg
COPY --chown=frappe:frappe erpnext/public/images/landing-selling.jpg /tmp/landing-selling.jpg
COPY --chown=frappe:frappe erpnext/public/images/landing-stock.jpg /tmp/landing-stock.jpg

USER frappe

RUN set -eu; \
  dest_app="apps/erpnext/erpnext/public/images/erpnext-logo.png"; \
  dest_assets="assets/erpnext/images/erpnext-logo.png"; \
  wm_app="apps/erpnext/erpnext/public/images/ledstackerp-watermark.png"; \
  wm_assets="assets/erpnext/images/ledstackerp-watermark.png"; \
  css_app="apps/erpnext/erpnext/public/css/ledstackerp-watermark.css"; \
  css_assets="assets/erpnext/css/ledstackerp-watermark.css"; \
  land_app="apps/erpnext/erpnext/public/css/ledstackerp-landing.css"; \
  land_assets="assets/erpnext/css/ledstackerp-landing.css"; \
  www_dir="apps/erpnext/erpnext/www"; \
  mkdir -p "$(dirname "$dest_app")" "$(dirname "$dest_assets")" \
    "$(dirname "$wm_app")" "$(dirname "$wm_assets")" \
    "$(dirname "$css_app")" "$(dirname "$css_assets")" \
    "$(dirname "$land_app")" "$(dirname "$land_assets")" "$www_dir"; \
  cp /tmp/erpnext-logo.png "$dest_app"; \
  cp /tmp/erpnext-logo.png "$dest_assets"; \
  cp /tmp/ledstackerp-watermark.png "$wm_app"; \
  cp /tmp/ledstackerp-watermark.png "$wm_assets"; \
  cp /tmp/ledstackerp-watermark.css "$css_app"; \
  cp /tmp/ledstackerp-watermark.css "$css_assets"; \
  cp /tmp/ledstackerp-landing.css "$land_app"; \
  cp /tmp/ledstackerp-landing.css "$land_assets"; \
  cp /tmp/home.html "$www_dir/home.html"; \
  cp /tmp/home.py "$www_dir/home.py"; \
  cp /tmp/landing-hero.jpg "$(dirname "$dest_app")/landing-hero.jpg"; \
  cp /tmp/landing-hero.jpg "$(dirname "$dest_assets")/landing-hero.jpg"; \
  cp /tmp/landing-finance.jpg "$(dirname "$dest_app")/landing-finance.jpg"; \
  cp /tmp/landing-finance.jpg "$(dirname "$dest_assets")/landing-finance.jpg"; \
  cp /tmp/landing-selling.jpg "$(dirname "$dest_app")/landing-selling.jpg"; \
  cp /tmp/landing-selling.jpg "$(dirname "$dest_assets")/landing-selling.jpg"; \
  cp /tmp/landing-stock.jpg "$(dirname "$dest_app")/landing-stock.jpg"; \
  cp /tmp/landing-stock.jpg "$(dirname "$dest_assets")/landing-stock.jpg"; \
  python3 - <<'PY'
from pathlib import Path
import re

p = Path("apps/erpnext/erpnext/hooks.py")
if not p.exists():
    raise SystemExit(0)
text = p.read_text()
text = text.replace("/assets/erpnext/images/erpnext-logo.svg", "/assets/erpnext/images/erpnext-logo.png")
text = text.replace('app_title = "ERPNext"', 'app_title = "LedstackERP"')
extra = '"/assets/erpnext/css/ledstackerp-watermark.css"'

def inject(text, var, extra):
    if extra in text:
        return text
    if f"{var} =" not in text:
        return text + f"\n{var} = [{extra}]\n"
    rest = text.split(f"{var}", 1)[1][:120]
    if "[" in rest:
        return text.replace(f"{var} = [", f"{var} = [\n\t{extra},", 1)
    text2, n = re.subn(
        rf'{var}\s*=\s*("[^"]+"|\'[^\']+\')',
        rf"{var} = [\1, " + extra + "]",
        text,
        count=1,
    )
    if n:
        return text2
    return text + f"\n{var} = [{extra}]\n"

text = inject(text, "app_include_css", extra)
text = inject(text, "web_include_css", extra)
if 'home_page =' not in text:
    text += '\nhome_page = "home"\n'
p.write_text(text)
PY
