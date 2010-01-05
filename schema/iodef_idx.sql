-- indicies for address table

CREATE TABLE idx_address_inet (
    id BIGSERIAL PRIMARY KEY,
    incidentid INT8 NOT NULL,
    addressid INT8 NOT NULL REFERENCES Address(id) ON DELETE CASCADE NOT NULL,
    address inet NOT NULL,
    category VARCHAR(12) CHECK (category IN ('ipv4-addr','ipv4-net','ipv6-addr','ipv6-net')),
    created timestamp with time zone DEFAULT NOW() NOT NULL
);

CREATE TABLE idx_address_asn (
    id BIGSERIAL PRIMARY KEY,
    incidentid INT8 NOT NULL,
    addressid bigint REFERENCES address(id) ON DELETE CASCADE NOT NULL,
    address int,
    description VARCHAR(255),
    cc VARCHAR(4),
    rir VARCHAR(10),
    updated timestamp with time zone,
    created timestamp with time zone NOT NULL DEFAULT NOW()
);

CREATE TABLE idx_address_dns (
    id BIGSERIAL PRIMARY KEY,
    incidentid INT8 NOT NULL,
    addressid INT8 REFERENCES address(id) ON DELETE CASCADE NOT NULL,
    address VARCHAR(255),
    class VARCHAR(8),
    type VARCHAR(8),
    created timestamp with time zone NOT NULL DEFAULT NOW()
);

CREATE TABLE idx_address_url (
    id BIGSERIAL PRIMARY KEY,
    incidentid INT8 NOT NULL,
    addressid bigint REFERENCES address(id) ON DELETE CASCADE NOT NULL,
    url VARCHAR(512),
    hash VARCHAR(255),
    hashtype VARCHAR(10),
    created timestamp with time zone NOT NULL DEFAULT NOW() NOT NULL
);
