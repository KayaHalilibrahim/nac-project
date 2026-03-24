-- Kullanıcı şifreleri ve kontrolleri
CREATE TABLE radcheck (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op VARCHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL DEFAULT ''
);

-- Kullanıcıya dönecek yanıtlar (VLAN vb.)
CREATE TABLE radreply (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op VARCHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL DEFAULT ''
);

-- Accounting (Oturum Kayıtları)
CREATE TABLE radacct (
    radacctid BIGSERIAL PRIMARY KEY,
    acctsessionid VARCHAR(64) NOT NULL DEFAULT '',
    acctuniqueid VARCHAR(32) NOT NULL DEFAULT '',
    username VARCHAR(64) NOT NULL DEFAULT '',
    groupname VARCHAR(64) NOT NULL DEFAULT '',
    nasipaddress inet NOT NULL,
    nasportid VARCHAR(32) DEFAULT NULL,
    acctstarttime TIMESTAMP WITH TIME ZONE,
    acctupdatetime TIMESTAMP WITH TIME ZONE,
    acctstoptime TIMESTAMP WITH TIME ZONE,
    acctinterval INTEGER DEFAULT NULL,
    acctsessiontime INTEGER DEFAULT NULL,
    acctinputoctets BIGINT DEFAULT NULL,
    acctoutputoctets BIGINT DEFAULT NULL,
    calledstationid VARCHAR(30) NOT NULL DEFAULT '',
    callingstationid VARCHAR(30) NOT NULL DEFAULT ''
);

-- Test kullanıcısı ekleyelim (Kullanıcı: kaya, Şifre: 123456)
INSERT INTO radcheck (username, attribute, op, value) 
VALUES ('kaya', 'Cleartext-Password', ':=', '123456');
