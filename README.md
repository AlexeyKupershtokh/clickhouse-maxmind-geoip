Example of ClickHouse integration with MaxMind GeoLite2 database for geolocation.
=================================================================================

This project contains:
 - Dictionary definitions for integrating [GeoLite2](https://dev.maxmind.com/geoip/geoip2/geolite2/) or [GeoIp2](https://dev.maxmind.com/geoip/geoip2/downloadable/) dictionaries into [ClickHouse](https://clickhouse.yandex/) database.
 - Query examples of how you can use them with example results.
 - Dockerfile / docker-compose.yml files for deploying clickhouse with the GeoLite2 dictionaries inside for fast experimenting.
 - A workaround to load GeoLite2-City-Locations-en.csv which ClickHouse considers corrupted because of apostrophe symbols.

More on GeoLite2/GeoIp2 dictionaries structure and content can be found here: https://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases/

After loading dictionaries they have such statistics:

```sql
SELECT *
FROM dictionaries 
```
```
┌─name───────────────────────┬─origin───────────────────────────────────────────────────────────┬─type───┬─key──────┬─attribute.names─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─attribute.types────────────────────────────────────────────────────────────────────────────────────────────────────────┬─bytes_allocated─┬─query_count─┬─hit_rate─┬─element_count─┬─────────load_factor─┬───────creation_time─┬─source─────────────────────────────────────────────────────────────────────────┬─last_exception─┐
│ geoip_country_locations_en │ /etc/clickhouse-server/geoip_country_locations_en_dictionary.xml │ Hashed │ UInt64   │ ['locale_code','continent_code','continent_name','country_iso_code','country_name','is_in_european_union']                                                                                                                                  │ ['String','String','String','String','String','String']                                                                │          173136 │           0 │        1 │           252 │          0.24609375 │ 2019-04-09 16:53:22 │ File: /etc/clickhouse-server/GeoLite2-Country-Locations-en.csv CSVWithNames    │                │
│ geoip_country_blocks_ipv6  │ /etc/clickhouse-server/geoip_country_blocks_ipv6_dictionary.xml  │ Trie   │ (String) │ ['geoname_id','registered_country_geoname_id','represented_country_geoname_id','is_anonymous_proxy','is_satellite_provider']                                                                                                                │ ['UInt32','UInt32','String','UInt32','UInt32']                                                                         │        16102088 │           0 │        1 │         92570 │                   1 │ 2019-04-09 16:53:22 │ File: /etc/clickhouse-server/GeoLite2-Country-Blocks-IPv6.csv CSVWithNames     │                │
│ geoip_asn_blocks_ipv4      │ /etc/clickhouse-server/geoip_asn_blocks_ipv4_dictionary.xml      │ Trie   │ (String) │ ['autonomous_system_number','autonomous_system_organization']                                                                                                                                                                               │ ['UInt32','String']                                                                                                    │        57925936 │           0 │        1 │        428088 │                   1 │ 2019-04-09 16:53:11 │ File: /etc/clickhouse-server/GeoLite2-ASN-Blocks-IPv4.csv CSVWithNames         │                │
│ geoip_city_blocks_ipv6     │ /etc/clickhouse-server/geoip_city_blocks_ipv6_dictionary.xml     │ Trie   │ (String) │ ['geoname_id','registered_country_geoname_id','represented_country_geoname_id','is_anonymous_proxy','is_satellite_provider','postal_code','latitude','longitude','accuracy_radius']                                                         │ ['UInt32','UInt32','String','UInt32','UInt32','String','Float32','Float32','UInt32']                                   │        66663688 │           0 │        1 │        440302 │                   1 │ 2019-04-09 16:53:21 │ File: /etc/clickhouse-server/GeoLite2-City-Blocks-IPv6.csv CSVWithNames        │                │
│ geoip_asn_blocks_ipv6      │ /etc/clickhouse-server/geoip_asn_blocks_ipv6_dictionary.xml      │ Trie   │ (String) │ ['autonomous_system_number','autonomous_system_organization']                                                                                                                                                                               │ ['UInt32','String']                                                                                                    │        11903280 │           0 │        1 │         55741 │                   1 │ 2019-04-09 16:53:11 │ File: /etc/clickhouse-server/GeoLite2-ASN-Blocks-IPv6.csv CSVWithNames         │                │
│ geoip_city_blocks_ipv4     │ /etc/clickhouse-server/geoip_city_blocks_ipv4_dictionary.xml     │ Trie   │ (String) │ ['geoname_id','registered_country_geoname_id','represented_country_geoname_id','is_anonymous_proxy','is_satellite_provider','postal_code','latitude','longitude','accuracy_radius']                                                         │ ['UInt32','UInt32','String','UInt32','UInt32','String','Float32','Float32','UInt32']                                   │       474850568 │           0 │        1 │       3223012 │                   1 │ 2019-04-09 16:53:19 │ File: /etc/clickhouse-server/GeoLite2-City-Blocks-IPv4.csv CSVWithNames        │                │
│ geoip_city_locations_en    │ /etc/clickhouse-server/geoip_city_locations_en_dictionary.xml    │ Hashed │ UInt64   │ ['locale_code','continent_code','continent_name','country_iso_code','country_name','subdivision_1_iso_code','subdivision_1_name','subdivision_2_iso_code','subdivision_2_name','city_name','metro_code','time_zone','is_in_european_union'] │ ['String','String','String','String','String','String','String','String','String','String','String','String','String'] │        92092760 │           0 │        1 │        111302 │ 0.42458343505859375 │ 2019-04-09 16:53:21 │ File: /etc/clickhouse-server/GeoLite2-City-Locations-en-fixed.csv CSVWithNames │                │
│ geoip_country_blocks_ipv4  │ /etc/clickhouse-server/geoip_country_blocks_ipv4_dictionary.xml  │ Trie   │ (String) │ ['geoname_id','registered_country_geoname_id','represented_country_geoname_id','is_anonymous_proxy','is_satellite_provider']                                                                                                                │ ['UInt32','UInt32','String','UInt32','UInt32']                                                                         │        38044360 │           0 │        1 │        330017 │                   1 │ 2019-04-09 16:53:22 │ File: /etc/clickhouse-server/GeoLite2-Country-Blocks-IPv4.csv CSVWithNames     │                │
└────────────────────────────┴──────────────────────────────────────────────────────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────┴─────────────┴──────────┴───────────────┴─────────────────────┴─────────────────────┴────────────────────────────────────────────────────────────────────────────────┴────────────────┘
```

GeoLite2-City-CSV queries
=========================
 
```sql
SELECT 
    ip,
    -- geoip_city_blocks_ipv4 dictionary
    dictGetUInt32('geoip_city_blocks_ipv4', 'geoname_id', tuple(IPv4StringToNum(ip))) AS geoname_id, 
    dictGetString('geoip_city_blocks_ipv4', 'postal_code', tuple(IPv4StringToNum(ip))) AS postcode, 
    dictGetFloat32('geoip_city_blocks_ipv4', 'latitude', tuple(IPv4StringToNum(ip))) AS latitude, 
    dictGetFloat32('geoip_city_blocks_ipv4', 'longitude', tuple(IPv4StringToNum(ip))) AS longitude, 
    dictGetUInt32('geoip_city_blocks_ipv4', 'accuracy_radius', tuple(IPv4StringToNum(ip))) AS accuracy_radius,
    -- geoip_city_locations_en dictionary       
    dictGetString('geoip_city_locations_en', 'locale_code', toUInt64(geoname_id)) AS locale_code, 
    dictGetString('geoip_city_locations_en', 'continent_code', toUInt64(geoname_id)) AS continent_code, 
    dictGetString('geoip_city_locations_en', 'continent_name', toUInt64(geoname_id)) AS continent_name, 
    dictGetString('geoip_city_locations_en', 'country_iso_code', toUInt64(geoname_id)) AS country_iso_code, 
    dictGetString('geoip_city_locations_en', 'country_name', toUInt64(geoname_id)) AS country_name, 
    dictGetString('geoip_city_locations_en', 'subdivision_1_iso_code', toUInt64(geoname_id)) AS subdivision_1_iso_code, 
    dictGetString('geoip_city_locations_en', 'subdivision_1_name', toUInt64(geoname_id)) AS subdivision_1_name, 
    dictGetString('geoip_city_locations_en', 'subdivision_2_iso_code', toUInt64(geoname_id)) AS subdivision_2_iso_code, 
    dictGetString('geoip_city_locations_en', 'subdivision_2_name', toUInt64(geoname_id)) AS subdivision_2_name, 
    dictGetString('geoip_city_locations_en', 'city_name', toUInt64(geoname_id)) AS city_name, 
    dictGetString('geoip_city_locations_en', 'metro_code', toUInt64(geoname_id)) AS metro_code, 
    dictGetString('geoip_city_locations_en', 'time_zone', toUInt64(geoname_id)) AS time_zone, 
    dictGetString('geoip_city_locations_en', 'is_in_european_union', toUInt64(geoname_id)) AS is_in_european_union
FROM 
(
    SELECT arrayJoin(['129.45.17.12', '173.194.112.139', '77.88.55.66', '2.28.228.0', '95.47.254.1', '62.35.172.0']) AS ip
) 
```
```
┌─ip──────────────┬─geoname_id─┬─postcode─┬─latitude─┬─longitude─┬─accuracy_radius─┬─locale_code─┬─continent_code─┬─continent_name─┬─country_iso_code─┬─country_name───┬─subdivision_1_iso_code─┬─subdivision_1_name─┬─subdivision_2_iso_code─┬─subdivision_2_name─┬─city_name─────────────┬─metro_code─┬─time_zone──────┬─is_in_european_union─┐
│ 129.45.17.12    │    2507480 │ 16100    │  36.7405 │    3.0096 │              10 │ en          │ AF             │ Africa         │ DZ               │ Algeria        │ 16                     │ Algiers            │                        │                    │ Algiers               │            │ Africa/Algiers │ 0                    │
│ 173.194.112.139 │    6252001 │          │   37.751 │   -97.822 │            1000 │ en          │ NA             │ North America  │ US               │ United States  │                        │                    │                        │                    │                       │            │                │ 0                    │
│ 77.88.55.66     │    2017370 │          │  55.7386 │   37.6068 │            1000 │ en          │ EU             │ Europe         │ RU               │ Russia         │                        │                    │                        │                    │                       │            │                │ 0                    │
│ 2.28.228.0      │    2640910 │ EH35     │   55.913 │   -2.9398 │               5 │ en          │ EU             │ Europe         │ GB               │ United Kingdom │ SCT                    │ Scotland           │ ELN                    │ East Lothian       │ Ormiston              │            │ Europe/London  │ 1                    │
│ 95.47.254.1     │    3077311 │          │  50.0848 │   14.4112 │             100 │ en          │ EU             │ Europe         │ CZ               │ Czechia        │                        │                    │                        │                    │                       │            │ Europe/Prague  │ 1                    │
│ 62.35.172.0     │    2983987 │ 53110    │  48.4833 │   -0.4833 │             100 │ en          │ EU             │ Europe         │ FR               │ France         │ PDL                    │ Pays de la Loire   │ 53                     │ Mayenne            │ Rennes-en-Grenouilles │            │ Europe/Paris   │ 1                    │
└─────────────────┴────────────┴──────────┴──────────┴───────────┴─────────────────┴─────────────┴────────────────┴────────────────┴──────────────────┴────────────────┴────────────────────────┴────────────────────┴────────────────────────┴────────────────────┴───────────────────────┴────────────┴────────────────┴──────────────────────┘
```

GeoLite2-Country-CSV queries
============================

```sql
SELECT 
    ip, 
    -- geoip_country_blocks_ipv4 dictionary
    dictGetUInt32('geoip_country_blocks_ipv4', 'geoname_id', tuple(IPv4StringToNum(ip))) AS geoname_id,
    -- geoip_country_locations_en dictionary
    dictGetString('geoip_country_locations_en', 'locale_code', toUInt64(geoname_id)) AS locale_code, 
    dictGetString('geoip_country_locations_en', 'continent_code', toUInt64(geoname_id)) AS continent_code, 
    dictGetString('geoip_country_locations_en', 'continent_name', toUInt64(geoname_id)) AS continent_name, 
    dictGetString('geoip_country_locations_en', 'country_iso_code', toUInt64(geoname_id)) AS country_iso_code, 
    dictGetString('geoip_country_locations_en', 'country_name', toUInt64(geoname_id)) AS country_name, 
    dictGetString('geoip_country_locations_en', 'is_in_european_union', toUInt64(geoname_id)) AS is_in_european_union

FROM 
(
    SELECT arrayJoin(['129.45.17.12', '173.194.112.139', '77.88.55.66', '2.28.228.0', '95.47.254.1', '62.35.172.0']) AS ip
) 
```
```
┌─ip──────────────┬─geoname_id─┬─locale_code─┬─continent_code─┬─continent_name─┬─country_iso_code─┬─country_name───┬─is_in_european_union─┐
│ 129.45.17.12    │    2589581 │ en          │ AF             │ Africa         │ DZ               │ Algeria        │ 0                    │
│ 173.194.112.139 │    6252001 │ en          │ NA             │ North America  │ US               │ United States  │ 0                    │
│ 77.88.55.66     │    2017370 │ en          │ EU             │ Europe         │ RU               │ Russia         │ 0                    │
│ 2.28.228.0      │    2635167 │ en          │ EU             │ Europe         │ GB               │ United Kingdom │ 1                    │
│ 95.47.254.1     │    3077311 │ en          │ EU             │ Europe         │ CZ               │ Czechia        │ 1                    │
│ 62.35.172.0     │    3017382 │ en          │ EU             │ Europe         │ FR               │ France         │ 1                    │
└─────────────────┴────────────┴─────────────┴────────────────┴────────────────┴──────────────────┴────────────────┴──────────────────────┘
```

GeoLite2-ASN-CSV queries
========================

```sql
SELECT
    ip,
    -- geoip_asn_blocks_ipv4 dictionary
    dictGetUInt32('geoip_asn_blocks_ipv4', 'autonomous_system_number', tuple(IPv4StringToNum(ip))) AS autonomous_system_number, 
    dictGetString('geoip_asn_blocks_ipv4', 'autonomous_system_organization', tuple(IPv4StringToNum(ip))) AS autonomous_system_organization 
FROM 
(
    SELECT arrayJoin(['129.45.17.12', '173.194.112.139', '77.88.55.66', '2.28.228.0', '95.47.254.1', '62.35.172.0']) AS ip
) 
```
```
┌─ip──────────────┬─autonomous_system_number─┬─autonomous_system_organization─┐
│ 129.45.17.12    │                   327931 │ Optimum-Telecom-Algeria        │
│ 173.194.112.139 │                    15169 │ Google LLC                     │
│ 77.88.55.66     │                    13238 │ YANDEX LLC                     │
│ 2.28.228.0      │                    12576 │ EE Limited                     │
│ 95.47.254.1     │                    47552 │ Vezet-Kirov Ltd.               │
│ 62.35.172.0     │                     5410 │ Bouygues Telecom SA            │
└─────────────────┴──────────────────────────┴────────────────────────────────┘

```

Note on IPv6
============

* Use dictionaries postfixed with `..._ipv6` instead of `..._ipv4`
* Use `IPv6StringToNum()` instead of `IPv4StringToNum()`

An example:
```sql
SELECT
    ip,
    dictGetString('geoip_asn_blocks_ipv6', 'autonomous_system_organization', tuple(IPv6StringToNum(ip))) AS autonomous_system_organization, 
    dictGetFloat32('geoip_city_blocks_ipv6', 'latitude', tuple(IPv6StringToNum(ip))) AS latitude, 
    dictGetFloat32('geoip_city_blocks_ipv6', 'longitude', tuple(IPv6StringToNum(ip))) AS longitude
FROM 
(
    SELECT arrayJoin(['2001:4860:4860::8888', '2a02:6b8::feed:bad']) AS ip
) 
```
```
┌─ip───────────────────┬─autonomous_system_organization─┬─latitude─┬─longitude─┐
│ 2001:4860:4860::8888 │ Google LLC                     │   37.751 │   -97.822 │
│ 2a02:6b8::feed:bad   │ YANDEX LLC                     │  55.7527 │   37.6172 │
└──────────────────────┴────────────────────────────────┴──────────┴───────────┘
```
