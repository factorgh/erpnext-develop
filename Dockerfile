FROM frappe/erpnext:v16.52.1

USER root
WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe . apps/erpnext

USER frappe

# Refresh the installed app from this repo. --no-deps keeps the image's
# existing Frappe/Python stack; extra deps are best-effort.
# Public files (logos, images) are already served from apps/erpnext/erpnext/public
# via the image asset symlink, so a copy into assets/erpnext is not needed.
RUN ./env/bin/pip install --no-cache-dir -e apps/erpnext --no-deps \
 && ./env/bin/pip install --no-cache-dir -e apps/erpnext || true

# Rebuild production asset bundles when bench/node are available.
RUN bench build --app erpnext || true
