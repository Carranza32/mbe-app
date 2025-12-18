# 📋 PLAN: Módulo de Administración - Pre-Alerts

## 🎯 OBJETIVO

Crear un módulo de administración separado del módulo de customer, donde el admin puede:

- Ver lista de paquetes (pre-alerts) con filtros por estado
- Escanear/seleccionar paquetes
- Cambiar estado de paquetes seleccionados (por ahora estático)

---

## 📁 ESTRUCTURA DE CARPETAS

```
lib/features/
├── admin/
│   └── pre_alert/                    # Módulo de pre-alerts para admin
│       ├── data/
│       │   ├── models/
│       │   │   ├── admin_pre_alert_model.dart      # Modelo extendido para admin
│       │   │   └── package_status.dart              # Enum de estados
│       │   └── repositories/
│       │       └── admin_pre_alert_repository.dart  # Repository (estático por ahora)
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── admin_pre_alerts_list_screen.dart    # Lista principal
│       │   │   └── scan_packages_modal.dart              # Modal de escaneo
│       │   └── widgets/
│       │       ├── package_list_item.dart               # Item de lista
│       │       ├── status_filter_chips.dart              # Chips de filtro
│       │       ├── package_selection_badge.dart           # Badge de selección
│       │       └── scan_input_field.dart                 # Campo de escaneo
│       └── providers/
│           ├── admin_pre_alerts_provider.dart             # Lista y filtros
│           ├── package_selection_provider.dart           # Selección de paquetes
│           └── package_status_provider.dart              # Cambio de estado
```

---

## 🏗️ ARQUITECTURA

### 1. **Sistema de Roles**

#### Extender User Model

```dart
// lib/features/auth/data/models/user_model.dart
class User {
  final int id;
  final String email;
  final String name;
  final String role; // 'admin' | 'customer' | 'user'

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
}
```

#### Provider para verificar rol

```dart
// lib/core/providers/user_role_provider.dart
@riverpod
bool isAdmin(Ref ref) {
  final user = ref.watch(authProvider).value;
  return user?.isAdmin ?? false;
}
```

---

### 2. **Modelos de Datos**

#### PackageStatus (Enum)

```dart
enum PackageStatus {
  pendingConfirmation,  // Pendiente confirmación
  readyToExport,        // Enviar/Recoger
  delivery,             // Delivery
  pickup,               // Pickup
  exported,             // Exportado
}

extension PackageStatusExtension on PackageStatus {
  String get label {
    switch (this) {
      case PackageStatus.pendingConfirmation:
        return 'Pendiente confirmación';
      case PackageStatus.readyToExport:
        return 'Enviar/Recoger';
      case PackageStatus.delivery:
        return 'Delivery';
      case PackageStatus.pickup:
        return 'Pickup';
      case PackageStatus.exported:
        return 'Exportado';
    }
  }

  int get count {
    // Por ahora estático, luego vendrá del backend
    switch (this) {
      case PackageStatus.pendingConfirmation: return 1;
      case PackageStatus.readyToExport: return 177;
      case PackageStatus.delivery: return 95;
      case PackageStatus.pickup: return 82;
      case PackageStatus.exported: return 0;
    }
  }
}
```

#### AdminPreAlert (Modelo extendido)

```dart
class AdminPreAlert {
  final String id;
  final String trackingNumber;
  final String eboxCode;           // Código eBox
  final String clientName;          // Cliente
  final String provider;            // Proveedor
  final double total;                // Total
  final int productCount;           // Cantidad de productos
  final String store;                // Tienda
  final String? deliveryMethod;      // Método de entrega
  final PackageStatus status;       // Estado
  final DateTime createdAt;
  final DateTime? exportedAt;
  final bool isSelected;            // Para selección múltiple

  // ... constructors, fromJson, toJson, copyWith
}
```

---

### 3. **Providers**

#### AdminPreAlertsProvider (Lista y Filtros)

```dart
@riverpod
class AdminPreAlerts extends _$AdminPreAlerts {
  @override
  Future<List<AdminPreAlert>> build() async {
    // Por ahora retorna datos estáticos
    return _getMockData();
  }

  // Filtrar por estado
  void filterByStatus(PackageStatus? status) { ... }

  // Buscar por texto
  void search(String query) { ... }

  // Recargar lista
  Future<void> refresh() async { ... }
}
```

#### PackageSelectionProvider (Selección)

```dart
@riverpod
class PackageSelection extends _$PackageSelection {
  @override
  Set<String> build() => {}; // IDs de paquetes seleccionados

  void toggleSelection(String packageId) { ... }
  void selectAll(List<String> packageIds) { ... }
  void clearSelection() { ... }
  bool isSelected(String packageId) { ... }
  int get selectedCount => state.length;
}
```

#### PackageStatusProvider (Cambio de Estado)

```dart
@riverpod
class PackageStatusManager extends _$PackageStatusManager {
  @override
  FutureOr<void> build() {}

  // Cambiar estado de paquetes seleccionados
  Future<bool> updateStatus({
    required List<String> packageIds,
    required PackageStatus newStatus,
  }) async {
    // Por ahora simulado, luego llamará al backend
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
```

---

### 4. **Pantallas**

#### AdminPreAlertsListScreen

**Estructura:**

```
┌─────────────────────────────────────┐
│ AppBar: "Paquetes Para Envío"      │
│ Botón: "Importar Pre-Alertas"      │
├─────────────────────────────────────┤
│ Status Filters (Chips)             │
│ [Pendiente(1)] [Enviar(177)] ...   │
├─────────────────────────────────────┤
│ Action Buttons                      │
│ [Escanear Paquetes] [Exportar]     │
├─────────────────────────────────────┤
│ Table Controls                      │
│ [Agrupar] [Fecha] [Buscar] [Filtro]│
├─────────────────────────────────────┤
│ Package List                        │
│ ┌───────────────────────────────┐   │
│ │ ☐ #0340309409439043          │   │
│ │   eeeeeeee | Mario Carranza  │   │
│ │   ABERCROMBIE | $300.00      │   │
│ └───────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Funcionalidades:**

- Mostrar lista de paquetes
- Filtros por estado (chips con contadores)
- Búsqueda por texto
- Botón "Escanear Paquetes" → abre modal
- Botón "Exportar Deliveries" → exporta seleccionados
- Selección múltiple (checkboxes)
- Agrupación por estado (opcional)

#### ScanPackagesModal

**Estructura:**

```
┌─────────────────────────────────────┐
│ Modal: "Escanear Paquetes..."      │
├─────────────────────────────────────┤
│ Input Field + Botón Escanear        │
│ [Escanea código...] [Escanear]     │
├─────────────────────────────────────┤
│ "X paquete(s) seleccionado(s)"     │
├─────────────────────────────────────┤
│ Tabla de Paquetes Seleccionados    │
│ ┌───────────────────────────────┐   │
│ │ # RASTREO | CÓDIGO | CLIENTE  │   │
│ │ 034030... | eeeeeeee | Mario  │   │
│ │ [X] Quitar                     │   │
│ └───────────────────────────────┘   │
├─────────────────────────────────────┤
│ [Limpiar Selección] [Exportar (X)] │
└─────────────────────────────────────┘
```

**Funcionalidades:**

- Input para escanear/ingresar código
- Botón para abrir cámara (QR/Barcode)
- Agregar paquetes a selección
- Mostrar lista de seleccionados
- Quitar paquetes de selección
- Botón "Exportar Seleccionados" → cambia estado

---

### 5. **Widgets Reutilizables**

#### StatusFilterChips

- Chips con contadores por estado
- Estado activo destacado
- Tap para filtrar

#### PackageListItem

- Card con información del paquete
- Checkbox para selección
- Badge de estado
- Tap para ver detalles (opcional)

#### ScanInputField

- Input con validación
- Botón de escaneo
- Feedback visual al escanear

---

### 6. **Router - Rutas de Admin**

```dart
// Agregar en app_router.dart
GoRoute(
  path: '/admin/pre-alerts',
  name: 'admin-pre-alerts',
  builder: (context, state) => const AdminPreAlertsListScreen(),
),
```

**Protección de rutas:**

```dart
redirect: (context, state) async {
  final isAdminRoute = state.matchedLocation.startsWith('/admin');

  if (isAdminRoute) {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      return '/print-orders/my-orders'; // Redirigir a customer
    }
  }

  // ... resto de lógica
}
```

---

### 7. **Navegación - Menú Admin**

#### Modificar AppDrawer

```dart
// Mostrar opciones diferentes según rol
if (isAdmin) {
  _DrawerItem(
    icon: Iconsax.box,
    title: 'Admin - Pre-Alerts',
    onTap: () => context.go('/admin/pre-alerts'),
  ),
}
```

---

## 📊 FLUJO DE USUARIO

### Flujo 1: Ver y Filtrar Paquetes

1. Admin entra a `/admin/pre-alerts`
2. Ve lista de todos los paquetes
3. Toca chip de estado → filtra lista
4. Usa búsqueda → filtra por texto

### Flujo 2: Escanear y Seleccionar

1. Admin toca "Escanear Paquetes"
2. Se abre modal
3. Escanea código o lo ingresa manualmente
4. Paquete se agrega a selección
5. Repite para más paquetes
6. Toca "Exportar Seleccionados"
7. Paquetes cambian de estado (simulado)

### Flujo 3: Selección Manual

1. Admin marca checkboxes en lista
2. Toca "Exportar Deliveries"
3. Paquetes seleccionados cambian de estado

---

## 🎨 DISEÑO UI/UX

### Principios

- **Consistencia**: Usar Design System existente (DSButton, DSInput, etc.)
- **Claridad**: Estados visibles, feedback inmediato
- **Eficiencia**: Acciones rápidas, menos taps
- **Feedback**: Toasts, loading states, confirmaciones

### Componentes del Design System a Usar

- `DSButton` - Botones de acción
- `DSInput` - Campos de búsqueda/escaneo
- `DSBadge` - Estados y contadores
- `DSInfoCards` - Cards de paquetes
- `DSSelectionCards` - Selección de estados

---

## 🔄 ESTADOS Y TRANSICIONES

### Estados de Paquete

```
Pendiente confirmación → Enviar/Recoger → Delivery/Pickup → Exportado
```

### Estados de UI

- **Loading**: Cargando lista
- **Empty**: Sin paquetes
- **Error**: Error al cargar
- **Success**: Lista cargada
- **Scanning**: Escaneando código
- **Updating**: Cambiando estado

---

## 📝 DATOS ESTÁTICOS (Mock Data)

### Generar datos de prueba

```dart
List<AdminPreAlert> _getMockData() {
  return [
    AdminPreAlert(
      id: '1',
      trackingNumber: '0340309409439043',
      eboxCode: 'eeeeeeee',
      clientName: 'Mario Carranza',
      provider: 'ABERCROMBIE AND FITCH',
      total: 300.00,
      productCount: 1,
      store: 'Imprenta Central San Salvador',
      deliveryMethod: null,
      status: PackageStatus.pendingConfirmation,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    // ... más datos
  ];
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Estructura Base

- [ ] Crear estructura de carpetas
- [ ] Extender User model con rol
- [ ] Crear isAdminProvider
- [ ] Crear PackageStatus enum
- [ ] Crear AdminPreAlert model

### Fase 2: Providers

- [ ] AdminPreAlertsProvider (lista y filtros)
- [ ] PackageSelectionProvider (selección)
- [ ] PackageStatusProvider (cambio de estado)

### Fase 3: Pantallas

- [ ] AdminPreAlertsListScreen (lista principal)
- [ ] ScanPackagesModal (modal de escaneo)

### Fase 4: Widgets

- [ ] StatusFilterChips
- [ ] PackageListItem
- [ ] ScanInputField

### Fase 5: Integración

- [ ] Agregar rutas al router
- [ ] Proteger rutas de admin
- [ ] Modificar AppDrawer para mostrar opciones admin
- [ ] Agregar datos mock

### Fase 6: Testing

- [ ] Probar filtros
- [ ] Probar selección
- [ ] Probar escaneo (simulado)
- [ ] Probar cambio de estado

---

## 🚀 PRÓXIMOS PASOS (Cuando se conecte API)

1. **Repository Real**

   - Reemplazar mock data con llamadas API
   - Endpoints: `/admin/pre-alerts`, `/admin/pre-alerts/scan`, `/admin/pre-alerts/export`

2. **Escaneo Real**

   - Integrar `mobile_scanner` o `qr_code_scanner`
   - Validar códigos con backend

3. **Notificaciones**

   - Push notifications cuando cambien estados
   - Toast notifications para acciones

4. **Optimizaciones**
   - Paginación infinita
   - Cache de datos
   - Sincronización offline

---

## 📌 NOTAS IMPORTANTES

1. **Separación de Concerns**

   - Admin completamente separado de Customer
   - No compartir providers entre admin y customer
   - Modelos pueden extenderse pero mantener separados

2. **Escalabilidad**

   - Estructura preparada para agregar más módulos admin
   - Fácil agregar nuevos estados de paquete
   - Fácil agregar nuevos filtros

3. **Mantenibilidad**

   - Código limpio y bien documentado
   - Uso consistente del Design System
   - Providers pequeños y enfocados

4. **Performance**
   - Lazy loading de lista
   - Debounce en búsqueda
   - Memoización de cálculos

---

## 🎯 RESULTADO ESPERADO

Un módulo de administración completo, limpio y fácil de mantener que:

- ✅ Separa claramente admin de customer
- ✅ Usa el Design System consistentemente
- ✅ Es fácil de extender y modificar
- ✅ Está preparado para conectar con API
- ✅ Tiene buena UX y feedback visual

---

¿Listo para empezar la implementación? 🚀
