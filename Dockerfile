# Keep the official ERPNext/Frappe versions in sync.
# Only overlay branding — do not replace the whole app with this develop tree.
FROM frappe/erpnext:v16.52.1

USER root
WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe erpnext/public/images/erpnext-logo.png /tmp/erpnext-logo.png

USER frappe

RUN set -eu; \
  dest_app="apps/erpnext/erpnext/public/images/erpnext-logo.png"; \
  dest_assets="assets/erpnext/images/erpnext-logo.png"; \
  mkdir -p "$(dirname "$dest_app")" "$(dirname "$dest_assets")"; \
  cp /tmp/erpnext-logo.png "$dest_app"; \
  cp /tmp/erpnext-logo.png "$dest_assets"; \
  if [ -f apps/erpnext/erpnext/hooks.py ]; then \
    sed -i 's|/assets/erpnext/images/erpnext-logo.svg|/assets/erpnext/images/erpnext-logo.png|g' apps/erpnext/erpnext/hooks.py; \
  fi
