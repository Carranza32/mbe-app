# API App Móvil – Tendencias y Análisis de Factura (Gemini)

Endpoints para la app móvil: **tendencias (Trend Discovery)** y **análisis de PDF/factura con IA** para rellenar el formulario de pre-alerta.

**Base URL:** `https://tu-dominio.com/api/v1` (ej. `https://mbe-orders.test/api/v1`)

---

## 1. GET /trends – Productos en tendencia

Lista los productos en tendencia: un producto destacado (hero) y el resto agrupados por categoría. **No requiere autenticación.**

### Request

| Método | URL | Headers |
|--------|-----|---------|
| `GET` | `/api/v1/trends` | Ninguno |

### Respuesta exitosa (200)

```json
{
  "status": true,
  "message": "Tendencias obtenidas correctamente",
  "data": {
    "hero_product": {
      "id": 1,
      "title": "Nombre del producto destacado",
      "description": "Descripción opcional",
      "category": "Tech & Gadgets",
      "approx_price": "99.99",
      "image_url": "https://...",
      "purchase_link": "https://...",
      "badge": "hot",
      "store_source": "Amazon",
      "synced_at": "2026-02-10T12:00:00.000000Z",
      "created_at": "...",
      "updated_at": "..."
    },
    "trending_by_category": {
      "Tech & Gadgets": [
        {
          "id": 1,
          "title": "...",
          "description": "...",
          "category": "Tech & Gadgets",
          "approx_price": "99.99",
          "image_url": "...",
          "purchase_link": "...",
          "badge": "hot",
          "store_source": "Amazon",
          "synced_at": "...",
          "created_at": "...",
          "updated_at": "..."
        }
      ],
      "Sneakers": [ ... ],
      "Gaming": [ ... ]
    }
  }
}
```

### Campos de cada producto en tendencia

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int | ID del producto |
| `title` | string | Título |
| `description` | string \| null | Descripción |
| `category` | string | Categoría (ej. "Tech & Gadgets", "Sneakers") |
| `approx_price` | string | Precio aproximado (decimal como string) |
| `image_url` | string \| null | URL de la imagen |
| `purchase_link` | string \| null | Enlace a la tienda |
| `badge` | string \| null | Ej. "hot" |
| `store_source` | string \| null | Ej. "Amazon" |
| `synced_at` | string (ISO 8601) | Fecha de sincronización |

### Respuesta sin datos

Si no hay productos, `hero_product` puede ser `null` y `trending_by_category` un objeto vacío `{}`.

---

## 2. POST /pre-alerts/analyze-invoice – Analizar factura/PDF con Gemini

Envía un PDF o imagen de factura/confirmación de pedido; la IA devuelve un JSON con los datos para rellenar el formulario de pre-alerta. **Requiere autenticación Sanctum.**

### Request

| Método | URL | Headers |
|--------|-----|---------|
| `POST` | `/api/v1/pre-alerts/analyze-invoice` | `Authorization: Bearer {token}` |

**Content-Type:** `multipart/form-data`

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `file` | file | Sí | PDF o imagen (jpg, jpeg, png). Máx. 10 MB (10240 KB). |
| `product_categories` | string (JSON) | No | Array de categorías para que la IA asigne mejor cada producto. Ver abajo. |

**Ejemplo de `product_categories`** (string JSON en el form):

```json
[
  { "id": 1, "name": "Electrónica" },
  { "id": 2, "name": "Ropa" },
  { "id": 48, "name": "Otro" }
]
```

Para obtener la lista de categorías disponibles puedes usar: **GET** `/api/v1/product-categories` (mismo formato que en el resto de la API).

### Respuesta exitosa (200)

```json
{
  "status": true,
  "message": "Documento analizado correctamente",
  "data": {
    "extracted": {
      "order_number": "112-9876543-1234567",
      "provider_name": "Amazon",
      "recipient_name": "Juan Pérez",
      "address_line1": "123 Main St",
      "city": "San Salvador",
      "state": "San Salvador",
      "postal_code": "1101",
      "country": "El Salvador",
      "products_subtotal": 45.99,
      "shipping_cost": 5.99,
      "total": 51.98,
      "product_count": 2,
      "products": [
        {
          "description": "Cable USB-C 2m",
          "quantity": 1,
          "price": 12.99,
          "sold_by": "Amazon",
          "product_category_id": 5,
          "product_other": null
        },
        {
          "description": "Funda para laptop",
          "quantity": 1,
          "price": 33.00,
          "sold_by": "Amazon",
          "product_category_id": 48,
          "product_other": "accesorio laptop"
        }
      ]
    },
    "elapsed_ms": 3240
  }
}
```

### Campos de `extracted` (para rellenar el formulario)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `order_number` | string \| null | Número de pedido / tracking |
| `provider_name` | string \| null | Tienda (Amazon, eBay, etc.) |
| `recipient_name` | string \| null | Nombre del destinatario |
| `address_line1` | string \| null | Dirección (calle) |
| `city` | string \| null | Ciudad |
| `state` | string \| null | Estado/Provincia |
| `postal_code` | string \| null | Código postal |
| `country` | string \| null | País |
| `products_subtotal` | number \| null | Subtotal en USD |
| `shipping_cost` | number \| null | Costo de envío en USD |
| `total` | number \| null | Total en USD |
| `product_count` | int \| null | Cantidad de ítems |
| `products` | array | Lista de productos (ver abajo) |

### Campos de cada elemento en `products[]`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `description` | string \| null | Descripción del producto |
| `quantity` | int | Cantidad |
| `price` | number \| null | Precio unitario USD |
| `sold_by` | string \| null | Vendedor/Marca |
| `product_category_id` | int | ID de categoría (0 si la IA no está segura) |
| `product_other` | string \| null | Si la categoría es "Otro" (ej. id 48), texto libre del tipo de producto |

### Uso en el formulario de pre-alerta

- **track_number** del formulario ← `extracted.order_number`
- **provider**: resolver `extracted.provider_name` con la lista de proveedores (GET `/api/v1/providers`); si no hay match, usar proveedor "Otro" y guardar el nombre en `provider_other`
- **total** ← `extracted.total`
- **product_count** ← `extracted.product_count` o `extracted.products.length`
- **products[]**: por cada `extracted.products[i]` → `product_category_id`, `product_name` (nombre de la categoría si tienes el listado), `product_other`, `product_description` (description), `quantity`, `price`

### Respuestas de error

**401 Unauthorized** – Falta o token inválido:

```json
{
  "status": false,
  "message": "Unauthenticated."
}
```

**422 Unprocessable Entity** – Validación (falta archivo, tipo no permitido, etc.) o la IA no pudo extraer datos estructurados:

```json
{
  "status": false,
  "message": "El archivo debe ser un archivo de tipo: pdf, jpg, jpeg, png."
}
```

o:

```json
{
  "status": false,
  "message": "No se pudo extraer información estructurada del documento."
}
```

**500 Internal Server Error** – Error interno o fallo de Gemini:

```json
{
  "status": false,
  "message": "Error al analizar el documento: ..."
}
```

---

## Resumen rápido

| Endpoint | Método | Auth | Uso |
|----------|--------|------|-----|
| `/api/v1/trends` | GET | No | Pantalla de tendencias: hero + listado por categoría. |
| `/api/v1/pre-alerts/analyze-invoice` | POST (multipart) | Bearer token | Subir PDF/imagen de factura y obtener JSON para rellenar el formulario de pre-alerta. |

**Login para obtener token:** `POST /api/v1/login` con `{ "email", "password" }` → en la respuesta usar el `token` en `Authorization: Bearer {token}`.
