ARG NAUTOBOT_VERSION=2.4.4
ARG PYTHON_VER=3.12
FROM ghcr.io/nautobot/nautobot:${NAUTOBOT_VERSION}-py${PYTHON_VER} AS nautobot-base

USER 0

RUN apt-get update && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    pip --no-cache-dir install --upgrade pip wheel

FROM ghcr.io/nautobot/nautobot-dev:${NAUTOBOT_VERSION}-py${PYTHON_VER} AS builder

CMD ["nautobot-server", "runserver", "0.0.0.0:8080", "--insecure"]

COPY ./pyproject.toml ../poetry.lock /source/
COPY ./plugins /source/plugins
# COPY ../packages /source/packages


# -------------------------------------------------------------------------------------
# Instalacion de dependencias custom HCB
# -------------------------------------------------------------------------------------

# SNMP
RUN apt-get update && \
    apt-get install -y build-essential libsnmp-dev
# Install the nautobot project to include Nautobot
RUN cd /source && \
    poetry install --no-interaction --no-ansi && \
    mkdir /tmp/dist && \
    poetry export --without-hashes -o /tmp/dist/requirements.txt

# pip install for custom Fortinet support packages
RUN pip install --no-cache-dir --upgrade pip wheel \
    git+https://github.com/glennake/napalm-fortinet \
    /source/plugins/nautobot-nornir-fortinet
# /plugins se copia bajo /source/plugins en linea 25

# -------------------------------------------------------------------------------------
# Fin - Instalacion de dependencias custom HCB
# -------------------------------------------------------------------------------------

COPY ./jobs /opt/nautobot/jobs
# COPY ../metrics /opt/nautobot/metrics
COPY ./config/nautobot_config.py /opt/nautobot/nautobot_config.py

WORKDIR /source

###################################

# -------------------------------------------------------------------------------------
# Final Image
# -------------------------------------------------------------------------------------
FROM nautobot-base AS nautobot

ARG PYTHON_VER
# Copy from base the required python libraries and binaries
COPY --from=builder /tmp/dist /tmp/dist
COPY --from=builder /opt/nautobot /opt/nautobot
COPY --from=builder /usr/local/lib/python${PYTHON_VER}/site-packages /usr/local/lib/python${PYTHON_VER}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
# COPY ../packages /source/packages

# Verify that pyuwsgi was installed correctly, i.e. with SSL support
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN pyuwsgi --cflags | sed 's/ /\n/g' | grep -e "^-DUWSGI_SSL$"

USER nautobot
