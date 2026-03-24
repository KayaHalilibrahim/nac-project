-- 1. radacct: Accounting (Oturum) kayıtları için ana tablo
CREATE TABLE IF NOT EXISTS radacct (
    radacctid BIGSERIAL PRIMARY KEY,
    acctsessionid VARCHAR(64) NOT NULL DEFAULT '',
    acctuniqueid VARCHAR(32) NOT NULL DEFAULT '',
    username VARCHAR(64) NOT NULL DEFAULT '',
    groupname VARCHAR(64) NOT NULL DEFAULT '',
    realm VARCHAR(64) DEFAULT '',
    nasipaddress VARCHAR(15) NOT NULL DEFAULT '0.0.0.0',
    nasportid VARCHAR(15) DEFAULT NULL,
    nasporttype VARCHAR(32) DEFAULT NULL,
    acctstarttime TIMESTAMP WITH TIME ZONE,
    acctupdatetime TIMESTAMP WITH TIME ZONE,
    acctstoptime TIMESTAMP WITH TIME ZONE,
    acctinterval BIGINT DEFAULT NULL,
    acctsessiontime BIGINT DEFAULT NULL,
    acctauthentic VARCHAR(32) DEFAULT NULL,
    connectinfo_start VARCHAR(50) DEFAULT NULL,
    connectinfo_stop VARCHAR(50) DEFAULT NULL,
    acctinputoctets BIGINT DEFAULT NULL,
    acctoutputoctets BIGINT DEFAULT NULL,
    calledstationid VARCHAR(50) DEFAULT NULL,
    callingstationid VARCHAR(50) DEFAULT NULL,
    acctterminatecause VARCHAR(32) DEFAULT NULL,
    servicetype VARCHAR(32) DEFAULT NULL,
    framedprotocol VARCHAR(32) DEFAULT NULL,
    framedipaddress VARCHAR(15) DEFAULT '0.0.0.0'
);

-- Hızlı sorgulama için indeksler (Ödevde artı puan getirebilir)
CREATE INDEX IF NOT EXISTS radacct_active_session_idx ON radacct (acctsessionid);
CREATE INDEX IF NOT EXISTS radacct_username_idx ON radacct (username);

-- 2. radcheck: Kullanıcı kimlik bilgileri (username, password vb.)
CREATE TABLE IF NOT EXISTS radcheck (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op VARCHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL DEFAULT ''
);

-- 3. radreply: Kullanıcıya özel dönülecek ek öznitelikler
CREATE TABLE IF NOT EXISTS radreply (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op VARCHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL DEFAULT ''
);

-- 4. radusergroup: Kullanıcıların hangi grupta olduğu (admin, employee vb.)
CREATE TABLE IF NOT EXISTS radusergroup (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL DEFAULT '',
    groupname VARCHAR(64) NOT NULL DEFAULT '',
    priority INTEGER NOT NULL DEFAULT 1
);

-- 5. radgroupreply: Gruplara özel VLAN ve diğer politikalar
CREATE TABLE IF NOT EXISTS radgroupreply (
    id SERIAL PRIMARY KEY,
    groupname VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op VARCHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL DEFAULT ''
);

-- Örnek Veri: Ödevi sunarken "Bakın kullanıcılar burada" diyebilmen için:
INSERT INTO radcheck (username, attribute, op, value) 
VALUES ('kaya', 'Cleartext-Password', ':=', '123456')
ON CONFLICT DO NOTHING;

INSERT INTO radusergroup (username, groupname) 
VALUES ('kaya', 'admin')
ON CONFLICT DO NOTHING;

INSERT INTO radgroupreply (groupname, attribute, op, value) 
VALUES ('admin', 'Tunnel-Private-Group-Id', '=', '10')
ON CONFLICT DO NOTHING;
