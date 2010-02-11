-- indicies for address table

CREATE TABLE idx_address_inet (
    id BIGSERIAL PRIMARY KEY,
    messageid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    address inet NOT NULL,
    created timestamp with time zone DEFAULT NOW() NOT NULL
);

CREATE TABLE idx_address_asn (
    id BIGSERIAL PRIMARY KEY,
    messageid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    address int NOT NULL,
    description VARCHAR(255),
    cc VARCHAR(2),
    rir VARCHAR(15),
    last_updated timestamp with time zone,
    created timestamp with time zone DEFAULT NOW() NOT NULL
);

CREATE TABLE idx_incidentid (
    id BIGSERIAL PRIMARY KEY,
    messageid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255),
    instance VARCHAR(255),
    content VARCHAR(255),
    created timestamp with time zone DEFAULT NOW() NOT NULL
);

CREATE TABLE idx_address_dns (
    id BIGSERIAL PRIMARY KEY,
    message_id uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    address VARCHAR(255),
    class VARCHAR(8),
    type VARCHAR(8),
    created timestamp with time zone NOT NULL DEFAULT NOW()
);

CREATE TABLE idx_address_url (
    id BIGSERIAL PRIMARY KEY,
    message_id uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    url VARCHAR(512),
    hash VARCHAR(255),
    hashtype VARCHAR(10),
    created timestamp with time zone NOT NULL DEFAULT NOW() NOT NULL
);

CREATE TABLE idx_confidence (
    id BIGSERIAL PRIMARY KEY,
    message_id uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    content real NOT NULL,
    rating VARCHAR(6) CHECK (rating IN ('low','medium','high','numeric')),
    created timestamp with time zone DEFAULT NOW() NOT NULL
);
