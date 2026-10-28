FROM frappe/erpnext:v16.52.1

USER root
WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe . apps/erpnext

USER frappe

# Refresh the installed app from this repo. --no-deps keeps the image's
# existing Frappe/Python stack; extra deps are best-effort.
RUN ./env/bin/pip install --no-cache-dir -e apps/erpnext --no-deps \
 && ./env/bin/pip install --no-cache-dir -e apps/erpnext || true

# Bake public files (logos, images, js/css source) into the asset tree
# that the image entrypoint symlinks onto the sites volume on boot.
RUN mkdir -p assets/erpnext \
 && cp -a apps/erpnext/erpnext/public/. assets/erpnext/

# Rebuild production asset bundles when bench/node are available.
RUN bench build --app erpnext \
 && if [ -d sites/assets ]; then rm -rf assets && cp -a sites/assets assets; fi \
 || true
