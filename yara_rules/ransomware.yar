/*
 * DarkWarden — Ransomware & Extortion Notes YARA Rules
 * Department of Software Engineering, Daffodil International University (DIU)
 * Author: Md. Tanjim Islam (tanjimislam04)
 */

rule LockBit_Ransom_Note {
    meta:
        description = "LockBit 2.0 / 3.0 (LockBit Black) ransom demand note"
        threat_category = "Ransomware"
        severity = "CRITICAL"
        author = "Md. Tanjim Islam"
    strings:
        $lb1 = "LockBit" ascii wide nocase
        $lb2 = "Restore-My-Files.txt" ascii wide nocase
        $lb3 = "lockbitapt" ascii wide nocase
        $lb4 = "Your data are stolen and encrypted" ascii wide nocase
        $lb5 = "decryption key" ascii wide nocase
    condition:
        ($lb1 and ($lb4 or $lb5)) or ($lb2 and $lb5) or $lb3
}

rule BlackCat_ALPHV_Note {
    meta:
        description = "BlackCat / ALPHV Ransomware negotiation note"
        threat_category = "Ransomware"
        severity = "CRITICAL"
        author = "Md. Tanjim Islam"
    strings:
        $alphv1 = "ALPHV" ascii wide nocase
        $alphv2 = "BlackCat" ascii wide nocase
        $alphv3 = "RECOVER-" ascii wide
        $alphv4 = "tor browser" ascii wide nocase
        $alphv5 = "leak data" ascii wide nocase
    condition:
        ($alphv1 or $alphv2) or ($alphv3 and $alphv4 and $alphv5)
}

rule Akira_Ransom_Note {
    meta:
        description = "Akira Ransomware victim instruction note"
        threat_category = "Ransomware"
        severity = "CRITICAL"
        author = "Md. Tanjim Islam"
    strings:
        $akira1 = "akira_readme.txt" ascii wide nocase
        $akira2 = "akira" ascii wide nocase
        $akira3 = "onion" ascii wide nocase
        $akira4 = "military grade encryption" ascii wide nocase
    condition:
        $akira1 or ($akira2 and $akira3 and $akira4)
}

rule Generic_DarkWeb_Extortion_Note {
    meta:
        description = "Generic Dark Web Ransomware / Double Extortion Demand"
        threat_category = "Ransomware"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $extort1 = "your files are encrypted" ascii wide nocase
        $extort2 = "all your data has been encrypted" ascii wide nocase
        $extort3 = "we downloaded your sensitive data" ascii wide nocase
        $extort4 = "pay the ransom" ascii wide nocase
        $contact1 = ".onion" ascii wide nocase
        $contact2 = "qtox" ascii wide nocase
        $contact3 = "session" ascii wide nocase
    condition:
        (1 of ($extort*)) and (1 of ($contact*))
}
