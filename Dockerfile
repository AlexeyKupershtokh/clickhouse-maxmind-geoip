FROM clickhouse/clickhouse-server:22.8

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        unzip \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && apt-get clean

# download MaxMind GeoLite2 databases
ARG GEOIP_LICENSE_KEY

RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-City-CSV.zip
RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-ASN-CSV.zip
RUN wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${GEOIP_LICENSE_KEY}&suffix=zip" -O /tmp/GeoLite2-Country-CSV.zip

RUN unzip /tmp/GeoLite2-City-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-Country-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-ASN-CSV.zip -d /tmp

# to avoid merging with `conf.d` during loading *_dictionary.xml
RUN mkdir -p /etc/clickhouse-server/dictionaries/ && mv -v /tmp/*/*.csv /etc/clickhouse-server/dictionaries/
ADD clickhouse /etc/clickhouse-server/
RUN echo '<clickhouse><dictionaries_config>dictionaries/*.xml</dictionaries_config></clickhouse>' > /etc/clickhouse-server/config.d/dictionaries.xml
