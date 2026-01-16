# Overthink Dump 🧠📓

Overthink Dump, kullanıcıların günlük düşüncelerini yazı ve fotoğraf desteğiyle kaydedebildiği, kişisel farkındalık ve zihinsel rahatlama odaklı bir mobil uygulamadır. Uygulama, kullanıcıların aşırı düşünme (overthinking) durumlarını yönetmelerine yardımcı olmayı amaçlar.

# Projenin Amacı

Bu projenin temel amacı, kullanıcıların gün içerisinde biriken düşüncelerini güvenli bir ortamda dışa vurabilmelerini, duygusal farkındalık kazanmalarını ve kişisel verilerini gizli ve kalıcı şekilde saklamalarını sağlayan bir mobil uygulama geliştirmektir.

# Hedef Kitle

- Günlük tutmayı seven kullanıcılar  
- Aşırı düşünme (overthink) problemi yaşayan bireyler  
- Dijital ortamda kişisel notlarını saklamak isteyen kişiler  

# Uygulama Özellikleri

- 📝 Düşünce (Dump) ekleme  
- 📸 Dump’a kamera veya galeriden fotoğraf ekleme  
- 🙂 Duygu seçimi (emoji destekli)  
- 🔒 Dump kilitleme (PIN ile koruma)  
- 🗑️ Dump silme  
- 📂 Dump listeleme  
- 📄 Dump detay görüntüleme  
- 💾 Yerel veritabanında kalıcı veri saklama  
- 🌙 Karanlık tema (Dark Mode)  

# Kullanılan Teknolojiler

- Flutter  
- Dart  
- Hive (Local Database)  
- image_picker  
- path_provider  

# Uygulama Ekranları

- Ana Liste Ekranı (Dump List Screen)  
- Dump Ekleme Ekranı  
- Dump Detay Ekranı  
- PIN Oluşturma / Kilit Açma Ekranı  
- Profil ve İçgörüler Ekranı  

# Veritabanı Yapısı

Uygulamada yerel veri saklama için Hive kullanılmıştır. Her dump için aşağıdaki bilgiler tutulmaktadır:

- id  
- text  
- tag  
- mood  
- createdAt  
- isLocked  
- imagePath  

# Projenin Çalışma Mantığı

Kullanıcı dump eklediğinde veriler Hive veritabanına kaydedilir. Eklenen dump’lar anında liste ekranında görüntülenir. Kilitli dump’lara erişim PIN doğrulaması ile sağlanır. Fotoğraflar uygulama dizinine kaydedilir ve dosya yolu bilgisi veritabanında tutulur.

# Kurulum ve Çalıştırma

Projeyi klonlayın:

---bash
git clone https://github.com/kullaniciadi/overthink_dump.git

## Gerekli paketleri yükleyin:

flutter pub get


## Uygulamayı çalıştırın:

flutter run

# YouTube Tanıtım Videosu

🎥 Projenin tanıtım videosu:
Buraya YouTube video linki eklenecektir.

# Geliştirici

Nazar Baştug
Yönetim Bilişim Sistemleri (YBS)
Flutter Mobil Uygulama Geliştirme – Final Projesi
