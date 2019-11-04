# FROM python:3.7.5-stretch
# FROM debian:stretch
# FROM ubuntu:18.04
FROM debian:buster

# LABEL maintainer="Odoo S.A. <info@odoo.com>"
LABEL maintainer="Asher Syed <ashersyed@hotmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

ARG ARTIFACTS_URL
# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

RUN set -x; \
        apt-get update \
        && apt-get install -y apt-utils \
                xfonts-base \
                xfonts-75dpi

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            python3 \
            python3-pip \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-vobject \
            python3-watchdog \
            xz-utils \
            zip \
            unzip \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        # && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
        # && echo 'f1689a1b302ff102160f2693129f789410a1708a wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb\
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN set -x; \
        # echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        # echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --armor --export "${repokey}" | apt-key add - \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install -y postgresql-client \
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss
RUN set -x;\
    # echo "deb http://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    echo "deb http://deb.nodesource.com/node_10.x buster main" > /etc/apt/sources.list.d/nodesource.list \
    # echo "deb http://deb.nodesource.com/node_10.x bionic main" > /etc/apt/sources.list.d/nodesource.list \
    && export GNUPGHOME="$(mktemp -d)" \
    && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --armor --export "${repokey}" | apt-key add - \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

# install odoo python3 packages
RUN apt-get update && apt-get -y install python3-babel python3-crypto python3-decorator python3-docutils python3-feedparser python3-gevent python3-html2text python3-itsdangerous python3-jinja2 python3-libsass python3-lxml python3-mako python3-mock python3-ofxparse python3-paramiko python3-passlib python3-psutil python3-psycopg2 python3-pydot python3-pyparsing python3-pypdf2 python3-reportlab python3-requests python3-serial python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-xmltodict python3-chardet

# install odoo dependencies
RUN pip3 install setuptools wheel num2words xlwt pycrypto wechatpy xmltodict itsdangerous fedex paramiko elasticsearch werobot weixin phonenumbers

# change timezone to China Shanghai
RUN echo "Asia/Shanghai" | tee /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Install Odoo
# ENV ODOO_VERSION 12.0
# ARG ODOO_RELEASE=20190409
# ARG ODOO_SHA=9e34aaed2eb1e7697aaf36767247dbf335e9fe7a

# RUN set -x; \
#         curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
#         && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
#         && dpkg --force-depends -i odoo.deb \
#         && apt-get update \
#         && apt-get -y install -f --no-install-recommends \
#         && rm -rf /var/lib/apt/lists/* odoo.deb

RUN set -x; \
        curl -sSL --header 'PRIVATE-TOKEN: RRB-5Wesw99zMd3sjpxm' "${ARTIFACTS_URL}" -o artifacts.zip \
	&& unzip artifacts.zip -d artifacts \
	&& dpkg --force-depends -i artifacts/pub/deb/odoo_12.0.20*.deb \
        # && apt-get update && apt-get -y install -f --no-install-recommends \
        && apt-get update && apt-get -y install -f \
        && rm -rf /var/lib/apt/lists/* odoo*.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

RUN chown odoo /etc/odoo/odoo.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

EXPOSE 8069 8071

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
# CMD ["/bin/bash", "-c", "odoo", "--db_host=${POSTGRESQL_HOST}", "--db_port=${POSTGRESQL_PORT_NUMBER}", "--db_user=${POSTGRESQL_USER}", "--db_password=${POSTGRESQL_PASSWORD}", "--database=${POSTGRESQL_DB}"]
