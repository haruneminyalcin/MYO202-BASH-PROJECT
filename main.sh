#!/bin/bash

# Harun Emin Yalçın
# 2420171034
# https://www.btkakademi.gov.tr/portal/certificate/view?hashId=vpWcn6g6n7
# https://www.btkakademi.gov.tr/portal/certificate/view?hashId=9XrtzXgX2d
# https://www.techcareer.net/en/courses/linux-bash-script-egitimi/b6746aa8-2168-4daa-9f62-ba5176b4482a

# Log dosyasini baslatip tarihi yaziyoruz
date -u +"%Y-%m-%dT%H:%M:%SZ" > report.log

echo -e "\n--- SISTEM VE DONANIM BILGILERI ---" >> report.log

# isletim sistemine gore donanim verilerini cek
if command -v wmic &> /dev/null; then
    echo "[CPU]" >> report.log
    wmic cpu get name >> report.log 2>&1
    
    echo "[RAM]" >> report.log
    wmic os get TotalVisibleMemorySize >> report.log 2>&1
    
    echo "[Anakart]" >> report.log
    wmic baseboard get product,Manufacturer >> report.log 2>&1
    
    echo "[Disk UUID]" >> report.log
    wmic diskdrive get serialnumber >> report.log 2>&1
    
    echo "[MAC]" >> report.log
    getmac >> report.log 2>&1

elif command -v system_profiler &> /dev/null; then
    echo "[Mac Ozeti]" >> report.log
    system_profiler SPHardwareDataType >> report.log 2>&1
    echo "[Mac Ag]" >> report.log
    ifconfig >> report.log 2>&1
fi

# Kullanicidan gpg parolasini al
read -sp "Sifreleme parolasini giriniz: " PAROLA
echo ""

# GPG ve AES256 ile report.log dosyasini arka planda sifrele
echo "$PAROLA" | gpg --batch --yes --symmetric --cipher-algo AES256 --passphrase-fd 0 -o report.log.gpg report.log

# Dosya olustuysa eskisini sil
if [ -f report.log.gpg ]; then
    rm -f report.log
    echo "Islem basarili. report.log.gpg olusturuldu ve orijinal dosya silindi."
else
    echo "Sifreleme sirasinda bir hata olustu!"
    exit 1
fi