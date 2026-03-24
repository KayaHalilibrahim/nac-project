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


CREATE TABLE IF NOT EXISTS radacct (
    radacctid bigserial PRIMARY KEY,
    acctsessionid text NOT NULL,
    username text,
    nasipaddress inet,
    acctstarttime timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    acctupdatetime timestamp with time zone,
    acctstoptime timestamp with time zone,
    acctsessiontime bigint DEFAULT 0,
    acctinputoctets bigint DEFAULT 0,
    acctoutputoctets bigint DEFAULT 0,
    calledstationid text,
    callingstationid text,
    acctterminatecause text
);

-- Örnek bir index (Hızlı sorgulama için ödevde artı puan kazandırır)
CREATE INDEX IF NOT EXISTS idx_radacct_username ON radacct(username);
CREATE INDEX IF NOT EXISTS idx_radacct_active ON radacct(acctstoptime) WHERE acctstoptime IS NULL;
