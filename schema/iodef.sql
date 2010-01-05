CREATE TYPE t_restriction AS ENUM ('public','need-to-know','private','default');

CREATE TABLE Incident (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    purpose VARCHAR(16) CHECK (purpose IN ('traceback','mitigation','reporting','other','ext-value')),
    ext_purpose VARCHAR(255),
    lang VARCHAR(16),
    restriction t_restriction DEFAULT 'private'
);

CREATE TABLE IncidentID (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    incidentid INT8 REFERENCES Incident(id) ON DELETE CASCADE NOT NULL,
    content VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    instance VARCHAR(255),
    restriction t_restriction
);

CREATE TABLE EventData (
    id BIGSERIAL PRIMARY KEY,
    incidentid INT8,
    eventdataid INT8,
    restriction t_restriction,
    StartTime timestamp with time zone,
    EndTime timestamp with time zone,
    DetectTime timestamp with time zone
);

CREATE TABLE Flow (
    id BIGSERIAL PRIMARY KEY,
    eventdataid INT8 REFERENCES EventData(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE System (
    id BIGSERIAL PRIMARY KEY,
    flowid INT8 REFERENCES Flow(id) ON DELETE CASCADE NOT NULL,
    restriction t_restriction DEFAULT 'private',
    category VARCHAR(16) CHECK (category IN ('source','target','intermediate','sensor','infrastructure','ext-value')),
    ext_category VARCHAR(255),
    interface VARCHAR(32),
    spoofed VARCHAR(8) CHECK (spoofed IN ('unknown','yes','no'))
);

CREATE TABLE Service (
    id BIGSERIAL PRIMARY KEY,
    systemid bigint REFERENCES System(id) ON DELETE CASCADE NOT NULL,
    ip_protocol VARCHAR(16),
    Port integer,
    PortList VARCHAR(255),
    ProtoCode VARCHAR(255),
    ProtoType VARCHAR(255),
    ProtoFlags VARCHAR(255)
);

CREATE TABLE Node (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    systemid INT8 REFERENCES System(id) ON DELETE CASCADE NOT NULL,
    Location VARCHAR(255),
    DateTime timestamp with time zone DEFAULT NOW()
);

CREATE TABLE Address (
    id BIGSERIAL primary key NOT NULL,
    nodeid INT8 REFERENCES node(id) ON DELETE CASCADE NOT NULL,
    vlan_num int,
    vlan_name VARCHAR(255),
    category VARCHAR(32) CHECK (category IN ('asn','atm','e-mail','ipv4-addr','ipv4-net','ipv4-net-mask','ipv6-addr','ipv6-net','ipv6-net-mask','mac','ext-value')),
    ext_category VARCHAR(255),
    content VARCHAR(255)
);

CREATE TABLE AdditionalData (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    _parent VARCHAR(30) NOT NULL,
    _parent_id INT8 NOT NULL,
    restriction t_restriction,
    dtype VARCHAR(10) CHECK (dtype IN ('string','boolean','byte','character','date-time','integer','ntpstamp','portlist','real','xml','file','frame','packet','ipv4-packet','ipv6-packet','path','url','csv','winreg','ext-value')) DEFAULT 'string',
    ext_dtype VARCHAR(15),
    meaning VARCHAR(255),
    formatid VARCHAR(255),
    content bytea
);
