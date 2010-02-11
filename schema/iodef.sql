CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    created timestamp with time zone DEFAULT NOW(),
    message xml,
    UNIQUE (uuid)
);
