# Railway Deployment – Adım Adım Rehber

Bu rehber, sıfırdan hiçbir şey yapmamış biri için yazılmıştır. Sırayla takip et.

---

## Adım 1: MySQL Veritabanı Oluştur

1. Railway projesinde (vania_dart_api) sol üstte **+ New** butonuna tıkla
2. **Database** seçeneğini seç
3. **MySQL** seç
4. Birkaç saniye sonra MySQL servisi oluşacak
5. Oluşan **MySQL** kartına tıkla (web servisinin yanında görünecek)

---

## Adım 2: MySQL Bağlantı Bilgilerini Kopyala

1. MySQL servisinin içindeyken **Variables** sekmesine tıkla
2. Şu değişkenleri göreceksin (isimler biraz farklı olabilir):
   - `MYSQLHOST` veya `MYSQL_HOST` → Bu **DB_HOST** olacak
   - `MYSQLPORT` veya `MYSQL_PORT` → Bu **DB_PORT** (genelde 3306)
   - `MYSQLDATABASE` veya `MYSQL_DATABASE` → Bu **DB_NAME** olacak
   - `MYSQLUSER` veya `MYSQL_USER` → Bu **DB_USERNAME** olacak
   - `MYSQLPASSWORD` veya `MYSQL_PASSWORD` → Bu **DB_PASSWORD** olacak

3. Bu değerleri bir yere not et veya kopyala (sonraki adımda kullanacaksın)

---

## Adım 3: Web Servisine MySQL’i Bağla (Referans Olarak)

1. Sol menüden **vania_dart_api** web servisine tıkla (MySQL değil!)
2. **Variables** sekmesine git
3. **+ New Variable** veya **Add Variable** butonuna tıkla
4. **"Add Reference"** veya **"Reference"** seçeneğini ara – MySQL’deki değişkenleri buraya referans olarak ekleyebilirsin

   **Eğer "Reference" varsa:**
   - `DB_HOST` → MySQL servisinden `MYSQLHOST` referansı
   - `DB_PORT` → MySQL servisinden `MYSQLPORT` referansı (veya direkt `3306` yaz)
   - `DB_NAME` → MySQL servisinden `MYSQLDATABASE` referansı
   - `DB_USERNAME` → MySQL servisinden `MYSQLUSER` referansı
   - `DB_PASSWORD` → MySQL servisinden `MYSQLPASSWORD` referansı

   **Eğer "Reference" yoksa:** Adım 2’de not ettiğin değerleri elle yaz:

   | Değişken | Değer |
   |----------|-------|
   | DB_HOST | (MySQL Variables’taki MYSQLHOST değeri) |
   | DB_PORT | 3306 |
   | DB_NAME | (MySQL Variables’taki MYSQLDATABASE değeri) |
   | DB_USERNAME | (MySQL Variables’taki MYSQLUSER değeri) |
   | DB_PASSWORD | (MySQL Variables’taki MYSQLPASSWORD değeri) |

---

## Adım 4: Domain Oluştur

1. **vania_dart_api** web servisindeyken **Settings** sekmesine git
2. **Networking** bölümünü bul
3. **Generate Domain** butonuna tıkla
4. Örnek: `vania-dart-api-production-xxxx.up.railway.app` gibi bir URL çıkacak
5. Bu URL’i kopyala

---

## Adım 5: Tüm Variables’ları Doldur

1. **vania_dart_api** → **Variables** sekmesine git
2. Aşağıdaki değişkenleri ekle veya güncelle (her satır için **+ New Variable** ile ekle):

| Değişken | Değer |
|----------|-------|
| APP_NAME | vania_dart_api |
| APP_ENV | production |
| APP_KEY | (aşağıda nasıl üretileceği var) |
| APP_HOST | 0.0.0.0 |
| APP_DEBUG | false |
| APP_URL | https://Adım4te-kopyaladığın-domain |
| APP_WEBSOCKET | false |
| APP_SECURE | false |
| APP_SHARED | true |
| DB_CONNECTION | mysql |
| DB_SECURE | true |
| DB_POOL | true |
| DB_POOL_SIZE | 2 |
| CACHE_DRIVER | file |
| SESSION_LIFETIME | 86400 |
| STORAGE | local |

**APP_KEY üretmek için:** Bilgisayarında Terminal (Mac) veya CMD (Windows) aç ve şunu yaz:

```bash
openssl rand -base64 32
```

Çıkan metni (örn: `TB7UPjNo2X-8XkCVNOxVT5-Kfu7Rn2CLxunr5uxS6UQ=`) kopyala ve `APP_KEY` değeri olarak yapıştır.

**DB_HOST, DB_PORT, DB_NAME, DB_USERNAME, DB_PASSWORD** → Adım 3’te eklediğin değerler (zaten varsa dokunma).

---

## Adım 6: Deploy’u Tetikle

Variables değiştiğinde Railway genelde otomatik yeniden deploy eder. Deploy’u görmek için:

1. **Deployments** sekmesine git
2. Yeni bir deployment’ın başladığını veya tamamlandığını kontrol et
3. Beklemezse: **Settings** → **Redeploy** veya benzeri bir butonla manuel tetikle

---

## Adım 7: Migration (Tabloları Oluştur)

Veritabanı tabloları henüz yok. Railway MySQL sadece kendi ağından erişilebilir, bu yüzden migration’ı **Railway CLI** ile çalıştıracaksın.

**Railway CLI ile migration:**

1. [Railway CLI](https://docs.railway.com/develop/cli) kur:
   ```bash
   npm install -g @railway/cli
   ```
2. Proje klasöründe terminal aç
3. Railway’e giriş yap:
   ```bash
   railway login
   railway link
   ```
4. `railway link` ile projeyi ve servisi seç (vania_dart_api)
5. Migration çalıştır:
   ```bash
   railway run dart run vania migrate
   ```

Bu komut Railway ortamında çalışır, bu yüzden DB_HOST gibi değişkenler otomatik kullanılır.

---

## Özet Kontrol Listesi

- [ ] MySQL servisi eklendi
- [ ] MySQL Variables’dan DB_HOST, DB_NAME, DB_USER, DB_PASSWORD değerleri alındı
- [ ] Web servisine DB_* değişkenleri eklendi
- [ ] Domain oluşturuldu
- [ ] APP_URL = https://domain-adresi olarak ayarlandı
- [ ] APP_ENV=production, APP_DEBUG=false olarak ayarlandı
- [ ] APP_KEY üretildi ve eklendi
- [ ] Deploy tamamlandı
- [ ] Migration çalıştırıldı (tablolar oluşturuldu)
- [ ] Tarayıcıda domain’e gidip API test edildi

---

## Sorun mu var?

- **502 Bad Gateway:** Uygulama henüz ayağa kalkmamış veya PORT’a bağlanmıyor olabilir. Variables’ı kontrol et.
- **Database connection error:** DB_HOST, DB_USERNAME, DB_PASSWORD doğru mu kontrol et.
- **Deploy başarısız:** Build Logs’a bak, hata mesajını oku.
