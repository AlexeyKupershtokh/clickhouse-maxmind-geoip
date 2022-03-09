FROM yandex/clickhouse-server:latest

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        unzip \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && apt-get clean

# download MaxMind GeoLite2 databases
ENV GEOIP_LICENSE_KEY 5wu5GCDQm0fDB49B

RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-City-CSV.zip
RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-ASN-CSV.zip
RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-Country-CSV.zip

RUN unzip /tmp/GeoLite2-City-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-Country-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-ASN-CSV.zip -d /tmp

RUN mv /tmp/*/*.csv /etc/clickhouse-server/

ADD clickhouse /etc/clickhouse-server

RUN pwd
RUN ls -la
RUN ls -la /etc/clickhouse-server
RUN ls -la /tmp
