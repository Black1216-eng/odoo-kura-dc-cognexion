FROM odoo:17.0

USER root

# Dependencias del sistema (para ldap, xml, ssl, pillow, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libffi-dev \
    libzip-dev \
  && rm -rf /var/lib/apt/lists/*

# Pip + wheels
RUN python3 -m pip install --upgrade pip wheel setuptools

# Dependencias Python del proyecto
COPY ./requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

# gevent/setproctitle: en x86_64 normalmente no necesitas hacks.
# Si tus requirements ya lo incluyen, esto sobra.
# Si quieres asegurarlo explícitamente:
# RUN python3 -m pip install --no-cache-dir gevent setproctitle

# (Opcional) GeoIP: mejor por volumen, pero si lo dejas en imagen, ok.
RUN mkdir -p /usr/share/GeoIP
# Copia solo si el archivo existe en el repo
# COPY ./GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb

# Permisos (Odoo ya usa /var/lib/odoo; los volúmenes deben montarse ahí)
RUN mkdir -p /var/lib/odoo /mnt/extra-addons \
  && chown -R odoo:odoo /var/lib/odoo /mnt/extra-addons

USER odoo

EXPOSE 8069
CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
