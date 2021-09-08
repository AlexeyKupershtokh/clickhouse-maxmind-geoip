FROM yandex/clickhouse-server

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        unzip \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && apt-get clean

# download MaxMind GeoLite2 databases
#ADD https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip /tmp
#ADD https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country-CSV.zip /tmp
#ADD https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip /tmp
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip -O /tmp/GeoLite2-City-CSV.zip --no-check-certificate
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country-CSV.zip -O /tmp/GeoLite2-Country-CSV.zip --no-check-certificate
RUN wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip -O /tmp/GeoLite2-ASN-CSV.zip --no-check-certificate

RUN unzip /tmp/GeoLite2-City-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-Country-CSV.zip -d /tmp
RUN unzip /tmp/GeoLite2-ASN-CSV.zip -d /tmp

RUN mv /tmp/*/* /etc/clickhouse-server/

ADD clickhouse /etc/clickhouse-server

RUN pwd
RUN ls -la
RUN ls -la /etc/clickhouse-server
RUN ls -la /tmp
