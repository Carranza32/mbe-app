# Resumen: Flujo de activación de cuenta (Mobile → Web)

Este documento describe cómo funciona el flujo de activación de cuenta en la app móvil (Flutter) para que puedas replicarlo en la web. Incluye endpoints, condiciones y secuencia de pantallas.

---

## Base URL

- **API:** `{baseUrl}/api/v1`  
  En el código: `ApiEndpoints.baseUrl` (ej: `http://192.168.31.5:8000/api/v1`).

---

## Endpoints usados en el flujo de activación

| Método | Path (endpoint) | Uso |
|--------|------------------|-----|
| POST | `/auth/check-email` | Verificar si el email existe y tipo de usuario (activo, legacy, nuevo). |
| POST | `/auth/send-activation-code` | Enviar código OTP al email (usuarios nuevos). |
| POST | `/auth/verify-otp` | Verificar OTP (usuarios nuevos y legacy, sin estar logueado). |
| POST | `/auth/set-password` | Crear contraseña (legacy sin datos de cliente, tras OTP). |
| POST | `/register` | Registro nuevo o activación legacy (con `password_set_token`). |
| POST | `/verify-code` | Verificar código de 6 dígitos (usuario **ya logueado**, email no verificado). |
| POST | `/resend-verification-code` | Reenviar código de verificación (usuario **ya logueado**). |
| POST | `/login` | Login con email y contraseña. |

---

## 1. Flujo principal: “Portero” (Email Entry)

**Pantalla inicial:** `/auth/email-entry`  
El usuario ingresa **solo email** (opcionalmente en otra pantalla se usa también `locker_code` en check-email).

### Paso 1: Check email

- **Endpoint:** `POST /auth/check-email`
- **Body:**
  ```json
  {
    "email": "usuario@ejemplo.com"
  }
  ```
  Opcional (si aplica en tu backend):
  ```json
  {
    "email": "usuario@ejemplo.com",
    "locker_code": "SAL12345"
  }
  ```
  En el app, `locker_code` se normaliza: se convierte a mayúsculas y si no empieza por `SAL` se le agrega el prefijo.

- **Respuesta esperada (modelo `EmailCheckResponse`):**
  - `exists` (bool)
  - `is_activated` (bool)
  - `has_locker` (bool)
  - `message` (string)
  - `status` (string): **`active_user`** \| **`legacy_user`** \| **`new_user`**
  - `has_web_login` (bool): si el usuario ya tiene login en web (contraseña / web_last_login)

**Condiciones según `status`:**

| status | Condición extra | Acción en mobile |
|--------|------------------|-------------------|
| `active_user` | - | Ir a **Login** (`/auth/login`) con `email` y opcionalmente `hasWebLogin` para mensaje. |
| `legacy_user` | `has_web_login == true` | Ir a **Login** (ya tiene contraseña). |
| `legacy_user` | `has_web_login == false` | Backend ya envió OTP. Ir a **OTP** (`/auth/otp-verification`) con `email`, `isLegacy: true`, mensaje tipo “activar cuenta digital”. |
| `new_user` | - | Llamar **send-activation-code** y luego ir a **OTP** con `email`, `isLegacy: false`. |
| Otro / no reconocido | - | Mostrar `message` si viene; si no, ir a Login. |

---

### Paso 2: Send activation code (solo para `new_user`)

- **Endpoint:** `POST /auth/send-activation-code`
- **Body:**
  ```json
  { "email": "usuario@ejemplo.com" }
  ```
- Se llama **antes** de redirigir a la pantalla de OTP cuando `status === 'new_user'`.

---

### Paso 2 bis: Pantalla OTP

- **Ruta:** `/auth/otp-verification`  
- **Parámetros (extra):** `email`, `isLegacy` (bool), `welcomeMessage` (string opcional).  
- El usuario ingresa código de **6 dígitos**.  
- **Reenvío de código:** mismo endpoint `POST /auth/send-activation-code` con el mismo `email`.

---

### Paso 3: Verify OTP

- **Endpoint:** `POST /auth/verify-otp`
- **Body:**
  ```json
  {
    "email": "usuario@ejemplo.com",
    "otp": "123456"
  }
  ```
- **Respuesta esperada (ejemplos):**
  - Si OK: `{ "status": "otp_verified", "password_set_token": "...", "customer": { ... } }`  
    - `customer` puede venir con `name`, `phone`, `locker_code` para prellenar registro (legacy).
  - Si el backend ya autentica: `{ "token": "...", "user": { ... } }` → guardar sesión e ir al home.

**Condiciones tras `status === 'otp_verified'`:**

| Tipo | Condición | Siguiente pantalla |
|------|-----------|---------------------|
| Legacy **con** `customer` | `isLegacy && customerData != null` | **Register** en modo activación: `email`, `code` = `password_set_token`, `isActivationFlow: true`, `name`, `phone`, `lockerCode` desde `customer`. |
| Legacy **sin** `customer` | `isLegacy` | **Create password**: `email`, `code` = `password_set_token`. |
| Usuario nuevo | `!isLegacy` | **Register** con `email`, `code` = `password_set_token`, `fromOtpFlow: true`. |

Si la respuesta trae `token` y `user`, se guarda sesión y se redirige al home (sin pasar por register/create-password).

---

### Paso 4a: Create password (legacy sin datos de cliente)

- **Endpoint:** `POST /auth/set-password`
- **Body:**
  ```json
  {
    "email": "usuario@ejemplo.com",
    "code": "<password_set_token del verify-otp>",
    "password": "...",
    "password_confirmation": "..."
  }
  ```
- **Respuesta:** puede devolver `token` y `user` → hacer login automático e ir al home; si no, mostrar éxito y redirigir a **Login** con el email.

---

### Paso 4b: Register (usuario nuevo o legacy con datos)

- **Endpoint:** `POST /register`
- **Body (registro “normal” sin activación):**
  - `name`, `email`, `locker_code`, `phone`, `password`, `password_confirmation`  
  - `locker_code` se normaliza: mayúsculas y prefijo `SAL` si no lo tiene.

- **Body (activación legacy o tras OTP):**
  - Los mismos campos anteriores **más**  
  - `password_set_token`: valor devuelto por `verify-otp` (o el mismo código OTP si el backend lo acepta).  
  - **No** se envía `verification_code` en este flujo.

- **Respuesta:** `AuthResponse` con `token` y `user`. Si `user.isEmailVerified === false`, en mobile se redirige a **Verify email** (`/auth/verify-email`); si no, al home.

---

## 2. Flujo alternativo: “Activar cuenta” (Email Verification screen)

**Pantalla:** `/auth/email-verification`  
Aquí el usuario puede ingresar **email** y opcionalmente **código de casillero** (`locker_code`). Se usa el mismo **check-email** (con `email` y opcionalmente `locker_code`).

- Si **existe** (`response.exists === true`):  
  - Mostrar diálogo “correo ya registrado” y ofrecer ir a **Login** (y opción tipo “¿Olvidaste contraseña?”).

- Si **no existe** (`response.exists === false`):  
  - Llamar **send-activation-code** con el email.  
  - Mostrar mensaje “código enviado a …”.  
  - Redirigir a **Register** pasando solo el **email** como `extra` (en el app: `context.go('/auth/register', extra: email)`).  
  - En este flujo alternativo el registro puede esperar que el usuario ingrese después el código OTP en la misma pantalla de registro (depende de tu backend); en el flujo principal “portero” el código ya se validó en verify-otp y se pasa `password_set_token` al register.

Resumen de endpoints en este flujo:
- `POST /auth/check-email` (con `email` y opcionalmente `locker_code`).
- `POST /auth/send-activation-code` (con `email`) cuando el correo no existe.

---

## 3. Flujo: Usuario ya logueado, email no verificado

Cuando el usuario **ya tiene sesión** pero `user.isEmailVerified === false`, el app lo manda a **Verify email** (`/auth/verify-email`). Aquí se usa otro par de endpoints (con **token de autorización**):

- **Verificar código de 6 dígitos:**  
  `POST /verify-code`  
  **Body:** `{ "code": "123456" }`  
  **Headers:** Authorization con el token del usuario.  
  **Respuesta:** objeto `user` (actualizado, con email verificado). Se actualiza sesión y se redirige al home.

- **Reenviar código:**  
  `POST /resend-verification-code`  
  **Body:** `{}`  
  **Headers:** Authorization.

Este flujo **no** usa `check-email` ni `verify-otp`; es solo para completar la verificación de email una vez el usuario ya está autenticado.

---

## 4. Resumen de condiciones para la web

Para replicar en web puedes usar esta tabla:

| Paso | Endpoint | Cuándo llamarlo |
|------|----------|------------------|
| 1 | `POST /auth/check-email` | Al ingresar email (y opcional locker_code) en la primera pantalla. |
| 2 | `POST /auth/send-activation-code` | Solo si `status === 'new_user'` (antes de ir a OTP), o en el flujo “activar cuenta” cuando el correo no existe. |
| 3 | `POST /auth/verify-otp` | En la pantalla OTP, con `email` + código de 6 dígitos (`otp`). |
| 4a | `POST /auth/set-password` | Si tras verify-otp es legacy sin datos de cliente: pantalla “crear contraseña” con `email`, `code` (password_set_token), `password`, `password_confirmation`. |
| 4b | `POST /register` | Si es usuario nuevo o legacy con datos: formulario de registro; si vienes de OTP, enviar además `password_set_token` (y no `verification_code`). |
| (alterno) | `POST /verify-code` | Solo cuando el usuario **ya está logueado** y falta verificar el email (pantalla “verifica tu correo”). |
| (alterno) | `POST /resend-verification-code` | Reenviar código en esa misma pantalla (con token de auth). |

**Modelo de respuesta check-email:**

- `status`: `'active_user'` \| `'legacy_user'` \| `'new_user'`
- `exists`, `is_activated`, `has_locker`, `message`, `has_web_login`
- Decisión: active_user → login; legacy_user + has_web_login → login; legacy_user sin has_web_login → OTP (backend ya envió); new_user → send-activation-code + OTP.

Con esto puedes llevar el mismo flujo de activación de cuenta a la web usando los mismos endpoints y condiciones que el mobile.
