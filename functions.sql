DROP FUNCTION IF EXISTS maxmind_asn;
CREATE FUNCTION maxmind_asn AS (ip) -> 
    multiIf(
        isIPv4String(ip), dictGetUInt32('geoip_asn_blocks_ipv4', 
                                        'autonomous_system_number', 
                                        tuple(IPv4StringToNumOrDefault(toString(ip)))),
        isIPv6String(ip), dictGetUInt32('geoip_asn_blocks_ipv6', 
                                        'autonomous_system_number', 
                                        tuple(IPv6StringToNumOrDefault(toString(ip)))),
        NULL
    )
;
DROP FUNCTION IF EXISTS maxmind_org;
CREATE FUNCTION maxmind_org AS (ip) -> 
    multiIf(
        isIPv4String(ip), dictGetString('geoip_asn_blocks_ipv4', 
                                        'autonomous_system_organization', 
                                        tuple(IPv4StringToNumOrDefault(toString(ip)))),
        isIPv6String(ip), dictGetString('geoip_asn_blocks_ipv6', 
                                        'autonomous_system_organization', 
                                        tuple(IPv6StringToNumOrDefault(toString(ip)))),
        NULL
    )
;
DROP FUNCTION IF EXISTS maxmind_geoname_id;
CREATE FUNCTION maxmind_geoname_id AS (ip) -> 
    toUInt64(multiIf(
        isIPv4String(ip), dictGetUInt32('geoip_city_blocks_ipv4', 
                                        'geoname_id', 
                                         tuple(IPv4StringToNumOrDefault(toString(ip)))),
        isIPv6String(ip), dictGetUInt32('geoip_city_blocks_ipv6', 
                                        'geoname_id', 
                                        tuple(IPv6StringToNumOrDefault(toString(ip)))),
        0
    ))
;
DROP FUNCTION IF EXISTS maxmind_country;
CREATE FUNCTION maxmind_country AS (ip) -> 
    dictGetString('geoip_city_locations_en', 
                  'country_name', 
                  maxmind_geoname_id(ip)
    )
;
DROP FUNCTION IF EXISTS maxmind_subdivision1;
CREATE FUNCTION maxmind_subdivision1 AS (ip) -> 
    dictGetString('geoip_city_locations_en', 
                  'subdivision_1_name', 
                  maxmind_geoname_id(ip)
    )
;
DROP FUNCTION IF EXISTS maxmind_subdivision2;
CREATE FUNCTION maxmind_subdivision2 AS (ip) -> 
    dictGetString('geoip_city_locations_en', 
                  'subdivision_2_name', 
                  maxmind_geoname_id(ip)
    )
;
DROP FUNCTION IF EXISTS maxmind_city;
CREATE FUNCTION maxmind_city AS (ip) -> 
    dictGetString('geoip_city_locations_en', 
                  'city_name', 
                  maxmind_geoname_id(ip)
    )
;
DROP FUNCTION IF EXISTS maxmind;
CREATE FUNCTION maxmind AS (type, ip) -> 
    multiIf(
        type = 'asn', toString(maxmind_asn(ip)),
        type = 'org', maxmind_org(ip),
        type = 'country', maxmind_country(ip),
        type = 'subdivision1', maxmind_subdivision1(ip),
        type = 'state', maxmind_subdivision1(ip),
        type = 'subdivision2', maxmind_subdivision2(ip),
        type = 'city', maxmind_city(ip),
        NULL        
    )
;