# HealthHarmony Frontend (Flutter App)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Framework](https://img.shields.io/badge/Framework-Flutter-blue)](https://flutter.dev)
[![Language](https://img.shields.io/badge/Language-Dart-cyan)](https://dart.dev)

**[English](#-english) | [Türkçe](#-türkçe)**

---

## 🇬🇧 English

<a name="english"></a>

This is the frontend application for the **HealthHarmony** project, developed with Flutter. It provides a cross-platform user interface for iOS, Android, Web, and Desktop, allowing users to interact with the HealthHarmony backend services.

### ✨ Features

-   **Secure Authentication:** Register and log in to your account securely.
-   **Daily Dashboard:** Track your daily nutrition (calories consumed/burned) and physical activity (step count).
-   **Activity Management:** Browse, add, and manage physical and mental activities in your personal schedule.
-   **Food Logging:** Easily log your meals by searching from a food database or entering them manually.
-   **Coach Interaction:** Find and connect with professional coaches for personalized guidance.
-   **In-App Messaging:** Securely chat with your friends and assigned coaches.



### 💻 Tech Stack

-   **Framework:** Flutter
-   **Language:** Dart
-   **Backend:** [C#](https://github.com/ibrahimErbilen/HealthHarmony_Backend)

### 🛠️ Prerequisites

Before you begin, ensure you have the following installed:
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x or higher)
-   An IDE like [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
-   A configured emulator (Android/iOS) or a connected physical device.

### 🚀 Installation and Setup

Follow these steps to run the project on your local machine:

1.  **Clone the Repository:**
    ```sh
    git clone https://github.com/IbrahimErbilen/healthharmony.git
    cd healthharmony
    ```

2.  **Install Dependencies:**
    Run the following command to download all the necessary packages defined in `pubspec.yaml`.
    ```sh
    flutter pub get
    ```

3.  **Connect to the Backend:**
    You need to update the backend API endpoint in the application's configuration files. Look for a file like `lib/core/constants/api_constants.dart` or a configuration service and change the `baseUrl` to the address where your backend is running (e.g., `http://localhost:5000`).

4.  **Run the Application:**
    Execute the following command to build and run the app on your selected device.
    ```sh
    flutter run
    ```

### 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## 🇹🇷 Türkçe

<a name="turkce"></a>

Bu proje, **HealthHarmony** uygulamasının Flutter ile geliştirilmiş frontend (istemci) tarafıdır. iOS, Android, Web ve Masaüstü için çapraz platformlu bir kullanıcı arayüzü sunarak kullanıcıların HealthHarmony backend servisleriyle etkileşim kurmasını sağlar.

### ✨ Özellikler

-   **Güvenli Kimlik Doğrulama:** Hesabınıza güvenli bir şekilde kaydolun ve giriş yapın.
-   **Günlük Panel:** Günlük beslenmenizi (alınan/yakılan kalori) ve fiziksel aktivitenizi (adım sayısı) takip edin.
-   **Aktivite Yönetimi:** Fiziksel ve mental aktivitelere göz atın, kişisel planınıza ekleyin ve yönetin.
-   **Yemek Kaydı:** Veritabanından arayarak veya manuel olarak girerek öğünlerinizi kolayca kaydedin.
-   **Koç Etkileşimi:** Kişiselleştirilmiş rehberlik için profesyonel koçları bulun ve onlarla bağlantı kurun.
-   **Uygulama İçi Mesajlaşma:** Arkadaşlarınızla ve size atanmış koçlarla güvenli bir şekilde sohbet edin.



### 💻 Teknoloji Yığını

-   **Framework:** Flutter
-   **Dil:** Dart
-   **Backend:** [C#](https://github.com/ibrahimErbilen/HealthHarmony_Backend)

### 🛠️ Gereksinimler

Başlamadan önce, sisteminizde aşağıdakilerin kurulu olduğundan emin olun:
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (sürüm 3.x veya üstü)
-   [Visual Studio Code](https://code.visualstudio.com/) veya [Android Studio](https://developer.android.com/studio) gibi bir IDE
-   Yapılandırılmış bir emülatör (Android/iOS) veya bağlı bir fiziksel cihaz.

### 🚀 Kurulum ve Çalıştırma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

1.  **Depoyu Klonlayın:**
    ```sh
    git clone https://github.com/IbrahimErbilen/healthharmony.git
    cd healthharmony
    ```

2.  **Bağımlılıkları Yükleyin:**
    `pubspec.yaml` dosyasında tanımlanan tüm gerekli paketleri indirmek için aşağıdaki komutu çalıştırın.
    ```sh
    flutter pub get
    ```

3.  **Backend'e Bağlanma:**
    Uygulamanın yapılandırma dosyalarında backend API adresini güncellemeniz gerekmektedir. `lib/core/constants/api_constants.dart` gibi bir dosyayı veya bir yapılandırma servisini bulun ve `baseUrl` değerini, backend'inizin çalıştığı adresle (örneğin, `http://localhost:5000`) değiştirin.

4.  **Uygulamayı Çalıştırın:**
    Uygulamayı seçtiğiniz cihazda derlemek ve çalıştırmak için aşağıdaki komutu yürütün.
    ```sh
    flutter run
    ```

### 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakınız.
