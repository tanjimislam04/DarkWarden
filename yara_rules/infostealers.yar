/*
 * Safe Dark Web Access — Infostealer Log & Dump YARA Rules
 * Department of Software Engineering, Daffodil International University (DIU)
 * Author: Md. Tanjim Islam (tanjimislam04)
 */

rule LummaStealer_LogFormat {
    meta:
        description = "Lumma Stealer C2 extracted credentials / log directory artifact"
        threat_category = "Infostealer"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $lumma1 = "LummaC2" ascii wide nocase
        $lumma2 = "Lumma Stealer" ascii wide nocase
        $lumma3 = "LummaC2 Build" ascii wide nocase
        $log1 = "System.txt" ascii wide
        $log2 = "Wallets" ascii wide
        $log3 = "Cookies" ascii wide
        $log4 = "Autofill" ascii wide
    condition:
        any of ($lumma*) or (3 of ($log*) and filesize < 50MB)
}

rule RedlineStealer_LogFormat {
    meta:
        description = "RedLine Infostealer victim dump structure"
        threat_category = "Infostealer"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $redline1 = "RedLine" ascii wide
        $redline2 = "User Data.txt" ascii wide
        $redline3 = "Passwords.txt" ascii wide
        $field1 = "HWID:" ascii wide
        $field2 = "OS Version:" ascii wide
        $field3 = "Available Keyboards:" ascii wide
        $field4 = "Display Resolution:" ascii wide
    condition:
        ($redline1 and any of ($field*)) or (3 of ($field*) and any of ($redline*))
}

rule Vidar_Stealer_Dump {
    meta:
        description = "Vidar / Oski stealer credential archive"
        threat_category = "Infostealer"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $vidar1 = "information.txt" ascii wide
        $vidar2 = "passwords.txt" ascii wide
        $vidar3 = "autofill.txt" ascii wide
        $vidar_c2 = "vidar" ascii wide nocase
        $marker1 = "MachineID:" ascii wide
        $marker2 = "GUID:" ascii wide
        $marker3 = "Resolution:" ascii wide
    condition:
        (2 of ($vidar*) and 2 of ($marker*)) or ($vidar_c2 and 2 of ($marker*))
}

rule Raccoon_Stealer_Output {
    meta:
        description = "Raccoon Stealer v2 log archive structure"
        threat_category = "Infostealer"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $raccoon1 = "Raccoon" ascii wide nocase
        $raccoon2 = "System Info.txt" ascii wide
        $raccoon3 = "IP Address:" ascii wide
        $raccoon4 = "Country Code:" ascii wide
        $raccoon5 = "User Name:" ascii wide
    condition:
        $raccoon1 or ($raccoon2 and 2 of ($raccoon3, $raccoon4, $raccoon5))
}

rule Stealc_Data_Archive {
    meta:
        description = "Stealc Infostealer credential dump structure"
        threat_category = "Infostealer"
        severity = "HIGH"
        author = "Md. Tanjim Islam"
    strings:
        $stealc1 = "Stealc" ascii wide nocase
        $stealc2 = "passwords.txt" ascii wide
        $stealc3 = "wallets" ascii wide
        $stealc4 = "browser_extension" ascii wide
    condition:
        $stealc1 or (3 of ($stealc*))
}
