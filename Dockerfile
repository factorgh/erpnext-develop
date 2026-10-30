# Keep the official ERPNext/Frappe versions in sync.
# Only overlay branding — do not replace the whole app with this develop tree.
FROM frappe/erpnext:v16.52.1

USER root
WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe erpnext/public/images/erpnext-logo.png /tmp/erpnext-logo.png
COPY --chown=frappe:frappe erpnext/public/css/ledstackerp-watermark.css /tmp/ledstackerp-watermark.css

USER frappe

RUN set -eu; \
  dest_app="apps/erpnext/erpnext/public/images/erpnext-logo.png"; \
  dest_assets="assets/erpnext/images/erpnext-logo.png"; \
  css_app="apps/erpnext/erpnext/public/css/ledstackerp-watermark.css"; \
  css_assets="assets/erpnext/css/ledstackerp-watermark.css"; \
  mkdir -p "$(dirname "$dest_app")" "$(dirname "$dest_assets")" "$(dirname "$css_app")" "$(dirname "$css_assets")"; \
  cp /tmp/erpnext-logo.png "$dest_app"; \
  cp /tmp/erpnext-logo.png "$dest_assets"; \
  cp /tmp/ledstackerp-watermark.css "$css_app"; \
  cp /tmp/ledstackerp-watermark.css "$css_assets"; \
  python3 - <<'PY'
from pathlib import Path
p = Path("apps/erpnext/erpnext/hooks.py")
if not p.exists():
    raise SystemExit(0)
text = p.read_text()
text = text.replace("/assets/erpnext/images/erpnext-logo.svg", "/assets/erpnext/images/erpnext-logo.png")
text = text.replace('app_title = "ERPNext"', 'app_title = "LedstackERP"')
extra = '"/assets/erpnext/css/ledstackerp-watermark.css"'
if extra not in text:
    if "app_include_css" in text and extra not in text:
        if "app_include_css =" in text and "[" in text.split("app_include_css", 1)[1][:80]:
            text = text.replace("app_include_css = [", "app_include_css = [\n\t" + extra + ",", 1)
        else:
            import re
            text, n = re.subn(
                r'app_include_css\s*=\s*("[^"]+"|\'[^\']+\')',
                r"app_include_css = [\1, " + extra + "]",
                text,
                count=1,
            )
            if n == 0:
                text += "\napp_include_css = [" + extra + "]\n"
p.write_text(text)
PY
