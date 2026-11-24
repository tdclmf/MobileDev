# MobileDev

Учебное Flutter-приложение: авторизация по email/паролю и OAuth, добавление демонстрационных записей, обычная загрузка и Realtime через Supabase и Firebase Realtime Database.

Код приложения находится в `flutter/flutter_application_1`. Без облачных настроек открывается главное меню с подсказкой; настроенные сервисы включаются независимо друг от друга.

Веб-версия: https://tdclmf.github.io/MobileDev/

## Запуск

Нужен Flutter **3.47.4** (Dart 3.13.3). Из корня репозитория:

```powershell
cd flutter/flutter_application_1
flutter pub get
Copy-Item config.example.json config.local.json
# Заполните config.local.json параметрами своего проекта.
flutter run -d chrome --web-port 8080 --dart-define-from-file=config.local.json
```

Для запуска без подключения достаточно `flutter run -d chrome`. `config.local.json` исключён из Git. Публичные клиентские параметры будут видны в собранном приложении: права доступа обеспечиваются RLS и правилами базы, а не скрытием этих параметров.

## Что нужно настроить самому

### Supabase

1. Создайте свой проект. В его настройках скопируйте Project URL и **publishable key** (или старый публичный `anon` key) в `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` файла `config.local.json`. Не используйте `service_role`, `sb_secret`, пароль базы или личный access token.
2. В SQL Editor нового проекта выполните [`supabase/schema.sql`](flutter/flutter_application_1/supabase/schema.sql). Он создаёт таблицу `Users` с `id`, `owner_id`, `username`, `password`, включает RLS и Realtime. Каждый вошедший пользователь видит и добавляет только собственные записи.
3. В Authentication включите Email. При включённом подтверждении email сначала подтвердите регистрацию по письму.
4. В Authentication → URL Configuration укажите Site URL `https://tdclmf.github.io/MobileDev/`, добавьте Redirect URLs `https://tdclmf.github.io/MobileDev/`, `http://localhost:8080/**` и `mobiledev://login-callback`.
5. Для Google/GitHub включите соответствующие провайдеры в Supabase, создайте OAuth-приложения и укажите их Client ID/Secret **в панели Supabase**. Callback URL провайдера берите из панели своего проекта (`https://<project-ref>.supabase.co/auth/v1/callback`). Кнопка Яндекса требует отдельно настроенного custom-провайдера `custom:yandex`; без него вход через Яндекс недоступен.

### Firebase

1. Создайте свой Firebase-проект и зарегистрируйте Web-приложение. В его Firebase configuration возьмите `apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`, `storageBucket`. Перенесите их в соответствующие поля `FIREBASE_*` файла `config.local.json`.
2. Создайте **Realtime Database** и добавьте её URL в `FIREBASE_DATABASE_URL`. Опубликуйте правила из [`firebase/database.rules.json`](flutter/flutter_application_1/firebase/database.rules.json) во вкладке Rules. Данные хранятся в `users/<auth uid>/<record>` и доступны только их владельцу.
3. В Authentication включите Email/Password, а при необходимости Google и GitHub. Добавьте `tdclmf.github.io` и `localhost` в Authorized domains. Для GitHub заполните OAuth Client ID/Secret в Firebase и зарегистрируйте callback из Firebase в настройках GitHub OAuth App.
4. Для Android зарегистрируйте Android-приложение с package name `com.example.flutter_application_1`; используйте его `appId` и `apiKey` при сборке Android. Для Google-входа добавьте SHA-1/SHA-256 сертификата подписи в Firebase. Текущий Android-проект использует явные `FirebaseOptions` и не требует чужого `google-services.json`.

Если нужен только Supabase, оставьте все поля Firebase пустыми. Если нужен только Firebase, оставьте оба поля Supabase пустыми.

### GitHub Pages

В Settings → Secrets and variables → Actions → Repository secrets добавьте заполненные параметры с **точно такими же именами**, как в `config.example.json`:

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`;
- `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_DATABASE_URL`, `FIREBASE_STORAGE_BUCKET`.

Затем запустите Actions → **Deploy Flutter Web** → Run workflow, либо сделайте push в `main`. Workflow устанавливает зависимости, проверяет код и тесты, собирает веб-версию с базовым путём `/MobileDev/` и публикует её в `gh-pages`. Пока параметры отсутствуют, публикуется меню настройки. GitHub Pages уже настроен на ветку `gh-pages`, папку `/`.

## Проверки и Android-сборка

Из `flutter/flutter_application_1`:

```powershell
flutter analyze
flutter test
flutter build web --base-href /MobileDev/ --dart-define-from-file=config.local.json
flutter build apk --release --dart-define-from-file=config.local.json
```

Для APK требуется Android SDK. Release пока использует debug-подпись из исходного шаблона; для публикации настройте собственный signing key. OAuth-ссылка Android — `mobiledev://login-callback`. Для iOS/macOS потребуется отдельно зарегистрировать URL scheme и приложения в Firebase; Windows-проверки авторизации Firebase в исходнике ограничены.

Поле «Пароль» в таблицах — демонстрационные данные лабораторной, хэшируемые SHA-256. Оно не участвует во входе и не должно содержать реальные пароли. Реальная авторизация выполняется Supabase Auth/Firebase Auth. Для собственного хранения паролей нужна серверная схема с Argon2/bcrypt вместо учебного SHA-256.

## Источник и история

Основа: [SimobiStudy/RMP-Flutter](https://github.com/SimobiStudy/RMP-Flutter), автор исходных коммитов **SimobiSirOP**. Коммиты переноса оформлены от tdclmf с сохранением исходных дат; время переноса и адаптации — 25 ноября 2026 года. Предыдущая история MobileDev сохранена.

| Исходный коммит | Дата авторства | Изменение | Коммит импорта |
| --- | --- | --- | --- |
| `517fcf5` | 2026-09-08T14:54:36+03:00 | Hello flutter! | `e4c2d27` |
| `8036b30` | 2026-10-23T14:06:36+03:00 | init | `823c302` |
| `1e16f48` | 2026-10-29T08:49:56+03:00 | adding supabase | `1be9811` |
| `80aae23` | 2026-11-06T17:20:36+03:00 | Massive restructure | `777537b` |
| `89ca720` | 2026-11-06T17:40:00+03:00 | Fixes | `98f7593` |

Адаптация: название и тема MobileDev, конфигурация вместо чужих облачных проектов, работа без ключей, возврат OAuth в собственное приложение, правила доступа к собственным записям, исправленный scrollbar, сохранение ввода при неудачной записи и актуальные тесты. Неиспользуемые Firestore, Google Sign-In и Secure Storage зависимости удалены; OAuth Supabase обслуживает его SDK.

В исходном репозитории не опубликован файл лицензии; указание источника само по себе не предоставляет права на распространение.
