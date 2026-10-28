/*
 * Safe Dark Web Access — Credential & Database Leak YARA Rules
 * Department of Software Engineering, Daffodil International University (DIU)
 * Author: Md. Tanjim Islam (tanjimislam04)
 */

rule Exposed_Private_RSA_Key {
    meta:
        description = "Unencrypted Private RSA / SSH / EC Cryptographic Key"
        threat_category = "Credential_Leak"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $k1 = "-----BEGIN RSA PRIVATE KEY-----" ascii
        $k2 = "-----BEGIN OPENSSH PRIVATE KEY-----" ascii
        $k3 = "-----BEGIN EC PRIVATE KEY-----" ascii
        $k4 = "-----BEGIN PRIVATE KEY-----" ascii
    condition:
        any of them
}

rule Database_SQL_Dump_Format {
    meta:
        description = "Database structure dump (MySQL, PostgreSQL, Oracle, MSSQL)"
        threat_category = "Database_Leak"
        severity = "MEDIUM"
        author = "Md. Tanjim Islam"
    strings:
        $mysql = "-- MySQL dump" ascii wide
        $pg = "-- PostgreSQL database dump" ascii wide
        $insert = "INSERT INTO " ascii wide nocase
        $create = "CREATE TABLE " ascii wide nocase
    condition:
        ($mysql or $pg) or ($create and $insert)
}

rule Environment_Secrets_Leak {
    meta:
        description = "Exposed environment configuration file (.env) with secrets"
        threat_category = "Credential_Leak"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $db_pass = /DB_PASSWORD\s*=\s*[^\s]+/ ascii
        $api_key = /API_KEY\s*=\s*[^\s]+/ ascii
        $secret = /SECRET_KEY\s*=\s*[^\s]+/ ascii
        $aws = /AWS_SECRET_ACCESS_KEY\s*=\s*[^\s]+/ ascii
    condition:
        2 of them
}
