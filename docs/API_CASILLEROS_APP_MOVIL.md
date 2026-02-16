# API Casilleros Físicos – App Móvil (Flutter)

Documento para el proyecto Flutter: integración con el backend Laravel para el flujo de **retiro en tienda** (escanear QR, buscar por código/DUI, validar PIN y registrar entrega).

---

## 1. Contexto

- **Backend (Laravel)**: ya tiene el módulo de casilleros físicos. El **backoffice (Filament)** se usa para:
  - Gestionar cuentas de casillero, casilleros físicos y crear retiros.
  - Pantalla “Retiro en tienda” para escritorio.

- **App móvil (Flutter)**: solo debe cubrir el flujo de **entrega en tienda**:
  - Escanear el **QR** que el cliente recibe por correo (o pegar el token).
  - O **buscar** por código de casillero o DUI.
  - Ver detalle del retiro, pedir **PIN** al cliente y **registrar la entrega**.

La app **no** crea cuentas, ni casilleros, ni retiros; eso sigue en Filament.

---

## 2. Autenticación

- **Base URL**: la misma que usa el resto de la app (ej. `https://api.tudominio.com`).
- **Prefijo**: `/api/v1`.
- **Auth**: **Bearer token** (Laravel Sanctum). El usuario de la app es **staff** (admin, franchisee, manager, etc.) y ya tiene login en la API.
- **Rutas de casilleros**: todas bajo **`/api/v1/admin/`** y requieren **`auth:sanctum`** (header `Authorization: Bearer {token}`).

Formato estándar de respuestas:

- **Éxito**
  ```json
  {
    "status": true,
    "message": "Success",
    "data": { ... }
  }
  ```
- **Error**
  ```json
  {
    "status": false,
    "message": "Mensaje de error"
  }
  ```
  Códigos HTTP: `400`, `401`, `403`, `404`, `422`, `500`.

---

## 3. Endpoints a usar

### 3.1 Listar tiendas (para elegir tienda antes de escanear/buscar)

El usuario solo puede operar en tiendas a las que tiene acceso (según su rol: admin, franchisee, manager).

| Método | Ruta                   | Descripción                                              |
| ------ | ---------------------- | -------------------------------------------------------- |
| `GET`  | `/api/v1/admin/stores` | Lista de tiendas accesibles para el usuario autenticado. |

**Headers**: `Authorization: Bearer {token}`

**Respuesta 200** – `data` es un array de tiendas:

```json
{
  "status": true,
  "message": "Tiendas obtenidas correctamente",
  "data": [
    {
      "id": 1,
      "name": "MBE Centro San Salvador",
      "code": "SV-SS-001",
      "email": "tienda@ejemplo.com",
      "phone": "2222-2222",
      "address": "Calle X, San Salvador",
      "country": { "id": 1, "name": "El Salvador", "code": "SV" },
      "is_active": true
    }
  ]
}
```

**Uso en Flutter**: al abrir la pantalla de “Retiro en tienda”, llamar este endpoint y mostrar un selector de tienda (o usar la primera si solo hay una). La tienda por defecto se puede guardar en el dispositivo.

---

### 3.2 Contadores para los tabs (Pendientes / Entregados)

Devuelve el **total** de retiros pendientes y el **total** de entregados para una tienda. Sirve para mostrar los badges en los tabs (ej. "Pendientes (10)", "Entregados (100)").

| Método | Ruta                                    | Descripción                                        |
| ------ | --------------------------------------- | -------------------------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/counts` | Totales de pendientes y entregados para la tienda. |

**Headers**: `Authorization: Bearer {token}`

**Query params**:

| Parámetro  | Tipo | Requerido | Descripción                           |
| ---------- | ---- | --------- | ------------------------------------- |
| `store_id` | int  | Sí        | ID de la tienda (de `/admin/stores`). |

Ejemplo: `GET /api/v1/admin/locker-retrieval/counts?store_id=1`

**Respuesta 200** – `data`:

```json
{
  "status": true,
  "message": "Success",
  "data": {
    "pending": 10,
    "delivered": 100
  }
}
```

**Uso en Flutter**: al cargar la pantalla (o al cambiar de tienda), llamar este endpoint una vez y usar `pending` y `delivered` para los textos de los tabs. No es el resumen del día; es el total de registros en cada estado (para infinite scroll y badges).

---

### 3.3 Lista paginada (infinite scroll) – Pendientes o Entregados

Lista de retiros en estado **pending** o **delivered** con paginación, igual que en pre-alertas (infinite scroll).

| Método | Ruta                                     | Descripción                                          |
| ------ | ---------------------------------------- | ---------------------------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/pickups` | Lista paginada de retiros (pendientes o entregados). |

**Headers**: `Authorization: Bearer {token}`

**Query params**:

| Parámetro  | Tipo   | Requerido | Descripción                                 |
| ---------- | ------ | --------- | ------------------------------------------- |
| `store_id` | int    | Sí        | ID de la tienda.                            |
| `status`   | string | Sí        | `pending` o `delivered`.                    |
| `page`     | int    | No        | Página (por defecto 1).                     |
| `per_page` | int    | No        | Tamaño de página (por defecto 15, máx. 50). |

Ejemplos:

- `GET /api/v1/admin/locker-retrieval/pickups?store_id=1&status=pending&page=1&per_page=15`
- `GET /api/v1/admin/locker-retrieval/pickups?store_id=1&status=delivered&page=2&per_page=15`

**Respuesta 200** – `data` contiene `data` (array de ítems) y `meta` (paginación):

```json
{
  "status": true,
  "message": "Success",
  "data": {
    "data": [
      {
        "id": 42,
        "pickup_token": "abc123...",
        "store_name": "MBE Centro San Salvador",
        "physical_locker_code": "A-12",
        "customer_name_masked": "María G.***",
        "locker_code": "MBE-12345",
        "type": "package",
        "type_label": "Paquete",
        "piece_count": 1,
        "created_at": "2026-02-07T20:00:00.000000Z",
        "pin_expires_at": "2026-02-07T20:30:00.000000Z"
      }
    ],
    "meta": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 15,
      "total": 35
    }
  }
}
```

Para **entregados** (`status=delivered`), cada ítem incluye además `delivered_at` (ISO 8601) y no incluye `pin_expires_at`.

**Uso en Flutter**: igual que pre-alertas. Tab "Pendientes": cargar página 1 al abrir el tab; al llegar al final de la lista, cargar `page=2`, etc. Tab "Entregados": mismo patrón con `status=delivered`. Al tocar un ítem **pendiente** se puede usar `pickup_token` para ir al flujo de detalle + PIN + entregar.

---

### 3.4 Obtener retiro por token (después de escanear QR)

Cuando el cliente muestra el QR del correo, la app escanea y obtiene un **token**. Con ese token se consulta el retiro.

| Método | Ruta                                              | Descripción                                                                              |
| ------ | ------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/by-token/{token}` | Devuelve el retiro pendiente asociado al token (para mostrar detalle y luego pedir PIN). |

**Headers**: `Authorization: Bearer {token}`

**Parámetros de ruta**:

- `token` (string): valor leído del QR o del enlace del correo. **Solo el token**, sin URL ni query params.

**Respuesta 200** – `data`:

```json
{
  "status": true,
  "message": "Success",
  "data": {
    "id": 42,
    "store_name": "MBE Centro San Salvador",
    "physical_locker_code": "A-12",
    "customer_name_masked": "María G.***",
    "locker_code_last4": "2345",
    "type": "package",
    "type_label": "Paquete",
    "piece_count": 1,
    "pin_expires_at": "2026-02-07T21:30:00.000000Z"
  }
}
```

**Errores**:

- **404**: Token no existe, retiro ya entregado o no está pendiente. `message`: "Retiro no encontrado o ya fue entregado".
- **403**: El retiro es de otra tienda a la que el usuario no tiene acceso. Mensaje tipo "No tienes acceso a esta tienda".

**Uso en Flutter**: tras escanear el QR (o pegar el token), llamar este endpoint; si va bien, mostrar pantalla de detalle (cliente enmascarado, casillero, tipo, piezas) y campo para ingresar PIN.

---

### 3.5 Registrar entrega (validar PIN y marcar entregado)

Cuando el trabajador ingresa el PIN que el cliente recibió por correo, se valida y se marca el retiro como entregado.

| Método | Ruta                                     | Descripción                                                             |
| ------ | ---------------------------------------- | ----------------------------------------------------------------------- |
| `POST` | `/api/v1/admin/locker-retrieval/deliver` | Valida el PIN, marca el retiro como entregado y registra quién entregó. |

**Headers**: `Authorization: Bearer {token}`  
**Content-Type**: `application/json`

**Body** (JSON):

| Campo   | Tipo   | Requerido | Descripción                                                |
| ------- | ------ | --------- | ---------------------------------------------------------- |
| `token` | string | Sí        | Mismo token usado en `by-token` (del QR o de la búsqueda). |
| `pin`   | string | Sí        | Exactamente 6 dígitos.                                     |

Ejemplo:

```json
{
  "token": "abc123...",
  "pin": "123456"
}
```

**Respuesta 200**:

```json
{
  "status": true,
  "message": "Success",
  "data": {
    "message": "Entrega registrada correctamente"
  }
}
```

**Errores**:

- **404**: Mismo que en `by-token` (retiro no encontrado o ya entregado).
- **403**: Sin acceso a la tienda del retiro.
- **422**:
  - "El PIN ha expirado"
  - "PIN incorrecto o intentos agotados" (límite de intentos en backend).

**Uso en Flutter**: en la pantalla de detalle del retiro, el usuario escribe el PIN y envía este POST; si es 200, mostrar éxito y volver al inicio (escanear/buscar de nuevo).

---

### 3.6 Buscar retiros por código de casillero o DUI

Cuando el cliente **no** tiene QR y dice su código de casillero (ej. MBE-12345) o su DUI, se buscan sus retiros pendientes en la tienda seleccionada.

| Método | Ruta                                    | Descripción                                                                   |
| ------ | --------------------------------------- | ----------------------------------------------------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/search` | Lista retiros pendientes por tienda y por código de cuenta o DUI del cliente. |

**Headers**: `Authorization: Bearer {token}`

**Query params**:

| Parámetro  | Tipo   | Requerido | Descripción                                                                  |
| ---------- | ------ | --------- | ---------------------------------------------------------------------------- |
| `store_id` | int    | Sí        | ID de la tienda (de la lista de `/admin/stores`).                            |
| `search`   | string | Sí        | Mínimo 2 caracteres: código de casillero (ej. MBE-12345) o DUI (cedula_rnc). |

Ejemplo: `GET /api/v1/admin/locker-retrieval/search?store_id=1&search=MBE-12345`

**Respuesta 200** – `data` es un array (puede ser vacío):

```json
{
  "status": true,
  "message": "Success",
  "data": [
    {
      "id": 42,
      "pickup_token": "abc123...",
      "store_name": "MBE Centro San Salvador",
      "physical_locker_code": "A-12",
      "customer_name_masked": "María G.***",
      "locker_code": "MBE-12345",
      "type": "package",
      "piece_count": 1
    }
  ]
}
```

**Errores**:

- **403**: Sin acceso a esa tienda.
- **422**: Validación (falta `store_id` o `search`, o `search` muy corto).

**Uso en Flutter**:

- Si `data.length == 0`: mostrar “Sin resultados”.
- Si `data.length == 1`: ir directo a la pantalla de detalle con ese retiro (usar `pickup_token` para el flujo de PIN y para `deliver`).
- Si `data.length > 1`: mostrar lista (nombre enmascarado, código, casillero, piezas); al elegir uno, usar su `pickup_token` para la pantalla de detalle y para `deliver`.

---

### 3.7 Crear retiro (desde la app)

Registra un retiro manual: se asigna casillero y cuenta, se genera token y PIN, y se envía el PIN por email al cliente. El flujo es el mismo que en Filament.

| Método | Ruta                           | Descripción      |
| ------ | ------------------------------ | ---------------- |
| `POST` | `/api/v1/admin/locker-pickups` | Crear un retiro. |

**Headers**: `Authorization: Bearer {token}`  
**Content-Type**: `application/json`

**Body (JSON)** – lo que debe enviar la app:

| Campo                | Tipo   | Requerido | Descripción                                                          |
| -------------------- | ------ | --------- | -------------------------------------------------------------------- |
| `store_id`           | int    | Sí        | ID de la tienda (de `/admin/stores`).                                |
| `physical_locker_id` | int    | Sí        | ID del casillero físico (de `GET .../stores/{id}/physical-lockers`). |
| `locker_account_id`  | int    | Sí        | ID de la cuenta de casillero (de `GET .../locker-accounts`).         |
| `type`               | string | No        | `package` o `correspondence`. Por defecto `package`.                 |
| `piece_count`        | int    | No        | Cantidad de piezas (1–99). Por defecto 1.                            |
| `notes`              | string | No        | Notas opcionales (máx. 500 caracteres).                              |

Ejemplo de body:

```json
{
  "store_id": 1,
  "physical_locker_id": 5,
  "locker_account_id": 12,
  "type": "package",
  "piece_count": 1,
  "notes": ""
}
```

**Respuesta 201** – retiro creado y PIN enviado por email al cliente:

```json
{
  "status": true,
  "message": "Retiro creado. Se envió el PIN por email al cliente.",
  "data": {
    "id": 42,
    "pickup_token": "abc123def456...",
    "store_id": 1,
    "physical_locker_code": "A-12",
    "locker_account_code": "MBE-12345",
    "type": "package",
    "piece_count": 1,
    "status": "pending",
    "pin_expires_at": "2026-02-07T21:30:00.000000Z"
  }
}
```

**Errores**:

- **403**: Sin acceso a la tienda.
- **422**: Validación (campos requeridos, `physical_locker_id` o `locker_account_id` inexistentes, etc.). El cuerpo de error incluye `message` y puede incluir `errors` con detalle por campo.

**Uso en Flutter**: pantalla "Crear retiro" con formulario. Cargar tienda (selector o por defecto), casilleros de la tienda y cuentas de casillero con los endpoints 3.8 y 3.9; enviar POST con los IDs elegidos; si 201, mostrar éxito y opcionalmente refrescar la lista de pendientes o el contador.

---

### 3.8 Casilleros físicos de una tienda (para formulario crear retiro)

Lista de casilleros activos de una tienda, para el dropdown al crear retiro.

| Método | Ruta                                                               | Descripción                       |
| ------ | ------------------------------------------------------------------ | --------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/stores/{storeId}/physical-lockers` | Lista de casilleros de la tienda. |

**Headers**: `Authorization: Bearer {token}`

**Parámetros de ruta**: `storeId` (int) – ID de la tienda.

**Respuesta 200** – `data` es un array:

```json
{
  "status": true,
  "message": "Success",
  "data": [
    { "id": 5, "code": "A-12", "order": 1 },
    { "id": 6, "code": "A-13", "order": 2 }
  ]
}
```

**Uso en Flutter**: al elegir tienda en el formulario de crear retiro, llamar este endpoint y llenar el selector de casillero con `id` y mostrar `code`.

---

### 3.9 Cuentas de casillero (para formulario crear retiro)

Lista de cuentas de casillero activas, opcionalmente filtradas por tienda, para el dropdown al crear retiro.

| Método | Ruta                                             | Descripción                             |
| ------ | ------------------------------------------------ | --------------------------------------- |
| `GET`  | `/api/v1/admin/locker-retrieval/locker-accounts` | Lista de cuentas (opcional `store_id`). |

**Headers**: `Authorization: Bearer {token}`

**Query params**:

| Parámetro  | Tipo | Requerido | Descripción                                                                                    |
| ---------- | ---- | --------- | ---------------------------------------------------------------------------------------------- |
| `store_id` | int  | No        | Si se envía, solo cuentas de esa tienda o sin tienda asignada. Recomendado para el formulario. |

Ejemplo: `GET /api/v1/admin/locker-retrieval/locker-accounts?store_id=1`

**Respuesta 200** – `data` es un array:

```json
{
  "status": true,
  "message": "Success",
  "data": [
    { "id": 12, "code": "MBE-12345", "customer_name": "María García" },
    { "id": 13, "code": "MBE-67890", "customer_name": "Juan Pérez" }
  ]
}
```

**Uso en Flutter**: en el formulario de crear retiro, llamar con `store_id` seleccionado y llenar el selector de cuenta con `id`, mostrando `code` y `customer_name`.

---

## 4. Flujo en la app (resumen)

1. **Login**  
   Usar el login existente de la API (email + contraseña). Guardar el Bearer token para todas las peticiones siguientes.

2. **Pantalla “Retiro en tienda”**
   - Llamar `GET /api/v1/admin/stores` y guardar la lista.
   - Si hay varias tiendas, mostrar selector y recordar `store_id` seleccionado (tienda por defecto se puede guardar en el dispositivo).
   - Llamar `GET /api/v1/admin/locker-retrieval/counts?store_id={id}` para obtener totales y mostrar los tabs: **Pendientes (N)** y **Entregados (N)**.
   - **Tab Pendientes**: lista con infinite scroll. `GET /api/v1/admin/locker-retrieval/pickups?store_id={id}&status=pending&page=1&per_page=15`; al llegar al final, cargar `page=2`, etc. (igual que pre-alertas).
   - **Tab Entregados**: misma idea con `status=delivered`. Orden por `delivered_at` descendente.
   - Al tocar un ítem **pendiente** de la lista, usar su `pickup_token` para ir al flujo de detalle + PIN + entregar.
   - **Crear retiro**: botón o entrada que abre formulario. Cargar casilleros con `GET .../stores/{storeId}/physical-lockers` y cuentas con `GET .../locker-accounts?store_id=`. Enviar `POST /api/v1/admin/locker-pickups` con los datos del formulario. Tras 201, refrescar counts y lista de pendientes.

3. **Opción A – Escanear QR**
   - Escanear el QR del correo del cliente (o permitir pegar el token manualmente).
   - El QR puede ser:
     - Solo el token en texto, o
     - Una URL con query param `token=...`; en ese caso, la app debe extraer el valor de `token` y usarlo en las llamadas.
   - Llamar `GET /api/v1/admin/locker-retrieval/by-token/{token}`.
   - Si 200: mostrar detalle (store_name, physical_locker_code, customer_name_masked, type_label, piece_count) y campo de PIN.
   - Si 404/403: mostrar mensaje de error (`message`).

4. **Opción B – Buscar por código o DUI**
   - Campo de búsqueda + botón “Buscar”.
   - Llamar `GET /api/v1/admin/locker-retrieval/search?store_id={id}&search={texto}`.
   - Si hay resultados, mostrar lista; al seleccionar un retiro, usar su `pickup_token` y mostrar la misma pantalla de detalle que en A (con campo de PIN).

5. **Entregar**
   - En la pantalla de detalle, el usuario ingresa el PIN de 6 dígitos.
   - Llamar `POST /api/v1/admin/locker-retrieval/deliver` con `{ "token": "<pickup_token>", "pin": "123456" }`.
   - Si 200: mostrar “Entrega registrada” y volver al paso 3 (escanear/buscar otro).
   - Si 422: mostrar el `message` (PIN expirado o incorrecto/intentos agotados).

---

## 5. Resumen de endpoints (checklist Flutter)

| #   | Método | Ruta                                                                                         | Uso                                                                                             |
| --- | ------ | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| 1   | `GET`  | `/api/v1/admin/stores`                                                                       | Listar tiendas para el selector.                                                                |
| 2   | `GET`  | `/api/v1/admin/locker-retrieval/counts?store_id=`                                            | Totales pendientes y entregados (badges de tabs).                                               |
| 3   | `GET`  | `/api/v1/admin/locker-retrieval/pickups?store_id=&status=pending\|delivered&page=&per_page=` | Lista paginada (infinite scroll) por tab.                                                       |
| 4   | `GET`  | `/api/v1/admin/locker-retrieval/by-token/{token}`                                            | Después de escanear QR / pegar token.                                                           |
| 5   | `POST` | `/api/v1/admin/locker-retrieval/deliver`                                                     | Body: `token`, `pin` – registrar entrega.                                                       |
| 6   | `GET`  | `/api/v1/admin/locker-retrieval/search?store_id=&search=`                                    | Búsqueda por código de casillero o DUI.                                                         |
| 7   | `POST` | `/api/v1/admin/locker-pickups`                                                               | Crear retiro (body: store_id, physical_locker_id, locker_account_id, type, piece_count, notes). |
| 8   | `GET`  | `/api/v1/admin/locker-retrieval/stores/{storeId}/physical-lockers`                           | Casilleros de la tienda (formulario crear retiro).                                              |
| 9   | `GET`  | `/api/v1/admin/locker-retrieval/locker-accounts?store_id=`                                   | Cuentas de casillero (formulario crear retiro).                                                 |

Todos con header: `Authorization: Bearer {token}` (token de Sanctum del login).

---

## 6. Notas para el correo / QR (backend)

Para que el cliente pueda mostrar un QR que la app escanee:

- El correo puede incluir un **enlace** tipo:  
  `https://app.mbe.com/locker/retrieve?token={pickup_token}`  
  y/o un **QR que codifique** ese mismo enlace o solo el `pickup_token`.
- La app Flutter debe:
  - Si escanea una URL: extraer el query param `token` y usarlo en `by-token` y `deliver`.
  - Si escanea texto plano: asumir que es el token y usarlo tal cual.

Con esto la app móvil puede implementar el mismo flujo que el backoffice (Filament) pero enfocado solo en entrega y búsqueda en tienda.
