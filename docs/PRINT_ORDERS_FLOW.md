# Flujo de Impresiones (Print Orders) – Resumen para actualización y verificación

Este documento describe qué espera el backend, el flujo completo web y API, y cómo verificar que todo esté actualizado y funcione bien.

---

## 1. Modelo y datos que espera el backend

### Modelo `App\Models\PrintOrder`

- **Tabla:** `print_orders`
- **No tiene** columna `customer_id`. Los datos de contacto se guardan en:
    - `customer_name`, `customer_email`, `customer_phone`
- **Relación `customer()` (obligatoria para pagos):**  
  Definida como `hasOneThrough(Customer::class, User::class, ...)` vía `user_id` → `users` → `customers`.  
  Se usa en el flujo de pago (web) para rellenar nombre/email/teléfono cuando el usuario tiene un Customer. Si no tiene, se usan los campos `customer_*` de la orden. **No eliminar ni renombrar esta relación.**

### Estados relevantes

- **`status`** (flujo del pedido): `pending`, `payment_pending`, `in_queue`, `printing`, `ready`, `shipped`, `delivered`, `cancelled`
- **`payment_status`:** `pending`, `paid`, `failed`  
  Cuando el pago se completa (callback de CyberSource o admin marca pago), se actualiza a `paid` con `PrintOrder::markAsPaid()` (desde `Payment::markAsCompleted()`).

### Listado “Mis Pedidos”

- Si `payment_status === 'paid'` y `status === 'pending'`, en la lista se debe mostrar **“Pagado”** (no “Pendiente”).
- Filtro “Pagado”: en backend se filtra por `payment_status = 'paid'` cuando el usuario elige la opción “Pagado” en el select de estados.

---

## 2. Flujo WEB (Inertia + rutas web)

### Rutas (routes/web.php)

| Método | Ruta                                  | Nombre                       | Auth | Descripción                                         |
| ------ | ------------------------------------- | ---------------------------- | ---- | --------------------------------------------------- |
| GET    | `/print-orders/create`                | print-orders.create          | No   | Formulario crear orden                              |
| POST   | `/print-orders`                       | print-orders.store           | No   | Crear orden (StorePrintOrderRequest)                |
| GET    | `/print-orders/my-orders`             | print-orders.my-orders       | Sí   | Lista “Mis Pedidos” (filtros: status, from, to)     |
| GET    | `/print-orders/search/{orderNumber}`  | print-orders.show            | No   | Ver/rastrear orden por número                       |
| POST   | `/print-orders/{id}/payment`          | print-orders.payment         | Sí   | Iniciar pago (gateway: cybersource, cash, transfer) |
| GET    | `/print-orders/{id}/payment/success`  | print-orders.payment-success | No\* | Página éxito de pago (\*o URL firmada)              |
| GET    | `/print-orders/{id}/payment/cancel`   | print-orders.payment-cancel  | No   | Página cancelación de pago                          |
| GET    | `/print-orders/success/{orderNumber}` | print-orders.success         | No   | Página éxito tras crear (sin pago)                  |
| GET    | `/print-orders/track`                 | print-orders.track           | No   | Página de rastreo                                   |
| GET    | `/print-orders/download/{id}`         | print-orders.download        | Sí   | Descargar archivo de la orden                       |

### Pago (web)

- **Iniciar pago:** `POST /print-orders/{id}/payment`  
  Body (ej.): `{ "gateway": "cybersource" | "cash" | "transfer", "total": 12.50 }`  
  Para `transfer` se requiere `transfer_proof` (archivo) y opcionalmente `transfer_reference`, `transfer_notes`.
- El controlador usa `PrintOrder::with('customer')->findOrFail($id)` y luego `$printOrder->customer` y `$customer?->name` (nullsafe) para rellenar datos del pago. **La relación `customer()` debe existir en el modelo.**
- Respuesta: `{ "success": true, "redirect_url": "..." }`. Para CyberSource el usuario es redirigido a esa URL; al terminar, CyberSource hace POST a `/payment-result`, que llama a `PaymentController::callback('cybersource')`. Si el pago es aceptado, se llama `Payment::markAsCompleted()` → `$payable->markAsPaid()` → actualiza `payment_status` y `paid_at` en `PrintOrder`.

### Páginas front (Inertia)

- **Crear:** `resources/js/pages/PrintOrders/CreatePrintOrder.jsx`
- **Mis Pedidos:** `resources/js/pages/PrintOrders/MyOrders.jsx`
    - Debe recibir `orders` (paginado con `payment_status` y `status`), `stats`, `filters`.
    - Estado mostrado: si `order.payment_status === 'paid'` y `order.status === 'pending'` → mostrar “Pagado” (verde). Resto por `order.status` (Pendiente, En Cola, etc.).
    - Filtro incluye opción “Pagado” (valor `status=paid` en query).
- **Éxito pago:** `resources/js/pages/PrintOrders/PaymentSuccess.jsx`
- **Rastreo:** `resources/js/pages/PrintOrders/OrderTracking.jsx`
- **Éxito creación:** `resources/js/pages/PrintOrders/Success.jsx`

### Datos que envía la web al crear (StorePrintOrderRequest)

- `files[]`, `config.printType`, `config.paperSize`, `config.paperType`, `config.orientation`, `config.copies`, `config.binding`, `config.doubleSided`, `config.pageRange`
- `delivery.method` (pickup | delivery), `delivery.store_id`, `delivery.customerAddressId`, `delivery.address`, `delivery.phone`, `delivery.notes`
- `customer.name`, `customer.email`, `customer.phone`, `customer.notes`
- Opcional: `promotion_id`, `coupon_code`, etc.

El servicio compartido es `PrintOrderService::createPrintOrder($data, $request, $promotion)`.

---

## 3. Flujo API (Sanctum, prefijo /api/v1)

### Rutas API (routes/api.php)

- **Sin auth (v1):**
    - `POST /api/v1/print-config/analyze-files` – analizar archivos
    - `GET /api/v1/print-config/prices` – precios
    - `GET /api/v1/print-config` – configuración (pickup_locations, config printing)
    - `POST /api/v1/print-order/create` – **crear orden** (store)

- **Con auth:sanctum (v1):**
    - `GET /api/v1/print-orders/my-orders` – lista “Mis Pedidos” (mismos filtros que web)
    - `GET /api/v1/print-orders/{orderNumber}` – detalle orden

No hay en la API ruta específica de “iniciar pago” para print orders; el pago se hace por web o por otro flujo.

### Crear orden por API – qué espera el backend

- **Endpoint:** `POST /api/v1/print-order/create`
- **Body (multipart o JSON según archivos):**
    - `files`: array de archivos (requerido), máx 5, pdf/doc/docx/jpg/jpeg/png, 50MB cada uno
    - `config.printType`: bw | color
    - `config.paperSize`: letter | legal | double_letter
    - `config.paperType`: bond | photo_glossy (opcional)
    - `config.orientation`: portrait | landscape
    - `config.copies`: 1–100
    - `config.binding`, `config.doubleSided`: boolean (nullable); si la app envía "true"/"false" o 1/0, el controlador los normaliza a boolean
    - `config.pageRange`: opcional
    - `delivery.method`: pickup | delivery
    - `delivery.pickupLocation`: id en `pickup_locations` (required_if method=pickup)
    - `delivery.address`, `delivery.phone`: required_if method=delivery; `delivery.notes` opcional
    - `customer.name`, `customer.email` requeridos; `customer.phone`, `customer.notes` opcionales

- **Respuesta 201:**  
  `{ "success": true, "message": "...", "data": { "order_number", "total", "delivery_method", "status" } }`

- **Nota:** La tabla `print_orders` no tiene `pickup_location_id`; tiene `store_id` y `customer_address_id`. Si la API envía `delivery.pickupLocation`, la orden se crea igual pero ese id no se persiste en la tabla (solo se valida que exista en `pickup_locations`).

### Historial al crear (web y API)

- Se crea un registro en `print_order_history` con `status: 'pending'`, `comment: 'Pedido recibido'`, `created_by: auth('sanctum')->id() ?: auth()->id()` para que funcione tanto con sesión web como con token API.

---

## 4. Cambios ya aplicados (no revertir)

1. **Modelo PrintOrder:** relación `customer()` definida como `hasOneThrough(Customer::class, User::class, ...)` para poder usar `$printOrder->customer` en el pago sin error “Call to undefined relationship [customer]”.
2. **PrintOrderController::initiatePayment:** uso de `$customer?->name`, `$customer?->email`, `$customer?->phone` por si el usuario no tiene Customer.
3. **Lista Mis Pedidos:**
    - Backend: filtro `status=paid` se traduce a `where('payment_status', 'paid')` en `PrintOrderService::getOrdersByUser`.
    - Front: en cada fila, si `payment_status === 'paid'` y `status === 'pending'` se muestra estado “Pagado” (verde); filtro con opción “Pagado”.
4. **API store:** normalización de `config.binding` y `config.doubleSided` a boolean antes de llamar a `createPrintOrder`.
5. **PrintOrderService::createPrintOrder:** `created_by` del historial con `auth('sanctum')->id() ?: auth()->id()`.

---

## 5. Checklist de verificación del flujo

Usar esto para comprobar que todo está actualizado y funciona.

### Web

- [ ] **Crear orden:** Ir a `/print-orders/create`, subir archivos, configurar impresión, entrega y datos de cliente; enviar. Debe crear la orden y redirigir o mostrar éxito.
- [ ] **Mis Pedidos (lista):** Con usuario logueado, ir a `/print-orders/my-orders`. Ver órdenes con estado correcto (Pendiente, Pagado, En cola, etc.). Filtrar por “Pagado” y comprobar que solo se muestran órdenes con `payment_status = paid`.
- [ ] **Iniciar pago:** Desde una orden no pagada, ir al pago (tarjeta / efectivo / transferencia). No debe aparecer error de relación `customer`. Debe redirigir a la URL de pago o mostrar mensaje según gateway.
- [ ] **Después de pagar (CyberSource):** Tras completar pago con tarjeta, volver a “Mis Pedidos” y comprobar que esa orden aparece como **“Pagado”** (no “Pendiente”).
- [ ] **Ver orden:** Buscar por número en `/print-orders/search/{orderNumber}` o desde “Mis Pedidos” → Ver. Debe cargar sin error.

### API

- [ ] **Config:** `GET /api/v1/print-config` devuelve pickup_locations y config de impresión.
- [ ] **Analizar archivos:** `POST /api/v1/print-config/analyze-files` con `files[]` devuelve análisis (páginas, etc.).
- [ ] **Crear orden:** `POST /api/v1/print-order/create` con `files`, `config`, `delivery`, `customer` en el body. Debe responder 201 con `order_number`, `total`, `status`. No error 500 ni “undefined relationship”.
- [ ] **Mis Pedidos (API):** Con `Authorization: Bearer {token}`, `GET /api/v1/print-orders/my-orders` devuelve lista paginada; cada ítem debe incluir `payment_status` y `status`.
- [ ] **Detalle orden:** `GET /api/v1/print-orders/{orderNumber}` con auth devuelve la orden (con relaciones que use el controlador, sin acceder a relación inexistente).

### Pagos

- [ ] Callback CyberSource: la URL configurada en CyberSource debe ser la que recibe POST (p. ej. `/payment-result`). Al marcar el pago como completado, se debe llamar a `Payment::markAsCompleted()` y por tanto `PrintOrder::markAsPaid()` para órdenes de impresión.

---

## 6. Archivos clave a no romper

- `app/Models/PrintOrder.php` – relación `customer()`, trait `Payable`
- `app/Http/Controllers/PrintOrderController.php` – `initiatePayment` (usa `customer` y nullsafe), `myOrders`, `paymentSuccess`
- `app/Http/Controllers/Api/PrintOrderApiController.php` – `store` (normalización de booleanos)
- `app/Services/PrintOrderService.php` – `createPrintOrder`, `getOrdersByUser` (filtro `status=paid` → `payment_status`), historial con `auth('sanctum')->id() ?: auth()->id()`
- `resources/js/pages/PrintOrders/MyOrders.jsx` – lógica de `displayStatus` (Pagado cuando paid + pending) y opción de filtro “Pagado”
- `app/Models/Payment.php` – `markAsCompleted()` llama a `$payable->markAsPaid()`
- Rutas en `routes/web.php` (print-orders.\*) y `routes/api.php` (v1 print-order/create, print-orders/my-orders, print-orders/{orderNumber})

Si la app (móvil u otra cliente) no está actualizada, asegurarse de que:

- Al crear por API envíe los campos indicados y, si envía booleanos como string, el backend ya los normaliza.
- Si consume “Mis Pedidos” por API, use `payment_status` además de `status` para mostrar “Pagado” cuando corresponda.
- No asuma que existe `customer_id` en `PrintOrder`; los datos de contacto están en `customer_name`, `customer_email`, `customer_phone` y opcionalmente en la relación `customer` vía usuario.
