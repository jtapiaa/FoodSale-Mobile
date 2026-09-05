# 🍔 FoodSale Mobile

FoodSale es una aplicación móvil para la gestión de pedidos de comida, desarrollada como un **Producto Mínimo Viable (MVP)**.

El proyecto permite explorar restaurantes y productos, gestionar un carrito de compra, crear pedidos, realizar seguimiento de sus estados y administrar información básica del usuario.

## 📱 Tecnologías utilizadas

### Frontend
- Flutter
- Dart
- HTTP / JSON
- SharedPreferences

### Backend
- Python
- Flask
- Flask-SQLAlchemy
- API REST

### Base de datos
- SQLite
- SQLAlchemy ORM

### Herramientas
- Git
- GitHub
- Xcode
- Visual Studio Code

## 🏗️ Arquitectura

La aplicación utiliza una arquitectura cliente-servidor:

```text
Flutter (iOS)
     │
 HTTP / JSON
     │
     ▼
API REST (Flask)
     │
 SQLAlchemy
     │
     ▼
   SQLite
```

Flutter se encarga de la interfaz y la interacción con el usuario.  
Flask procesa las solicitudes realizadas mediante la API REST y SQLAlchemy gestiona el acceso a la base de datos SQLite.

## ⚙️ Funcionalidades

El MVP incluye:

- Registro de usuarios
- Inicio y cierre de sesión
- Persistencia de sesión
- Listado de restaurantes
- Categorías y filtros
- Búsqueda de restaurantes
- Consulta de productos
- Carrito de compra
- Cálculo de subtotal, despacho y total
- Creación de pedidos
- Historial y detalle de pedidos
- Seguimiento mediante estados
- Restaurantes favoritos
- Direcciones guardadas
- Perfil de usuario

### Estados de pedido

```text
Pedido confirmado → Preparando → En camino → Entregado
```

## 📂 Estructura general

```text
FoodSale
│
├
│── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   └── main.dart
│── pubspec.yaml
│
└── foodsale_backend/
    ├── app/
    │   ├── __init__.py
    │   ├── models.py
    │   └── routes.py
    ├── instance/
    │   └── foodsale.db
    ├── app.py
    └── requirements.txt
```

## 🚀 Ejecución del proyecto

### Backend

Ingresar al directorio del backend:

```bash
cd foodsale_backend
```

Activar el entorno virtual:

```bash
source venv/bin/activate
```

Instalar las dependencias:

```bash
pip install -r requirements.txt
```

Ejecutar Flask:

```bash
python app.py
```

El servidor de desarrollo utiliza el puerto:

```text
5001
```

### Aplicación Flutter

Instalar las dependencias:

```bash
flutter pub get
```

Comprobar los dispositivos disponibles:

```bash
flutter devices
```

Ejecutar FoodSale:

```bash
flutter run
```

## 📲 Pruebas en iOS

El MVP fue probado utilizando un **iPhone físico** mediante Flutter y Xcode.

Durante las pruebas, el iPhone y el computador que ejecuta Flask deben encontrarse conectados a la misma red local.

La aplicación debe utilizar la dirección IP local del computador para comunicarse con el backend:

```dart
static const String baseUrl =
    'http://IP_DEL_COMPUTADOR:5001/api';
```

> La dirección IP puede cambiar dependiendo de la red utilizada.

## 🔐 Autenticación

FoodSale permite registrar e iniciar sesión con correo electrónico y contraseña.

Las contraseñas son almacenadas mediante **hash** en el backend. La aplicación mantiene localmente los datos básicos de sesión para conservar el acceso después de reiniciarse.

La implementación corresponde al alcance de un MVP y no utiliza actualmente autenticación mediante JWT u otro sistema de tokens.

## ⚠️ Limitaciones actuales

FoodSale corresponde a un prototipo funcional y no a una aplicación preparada para producción.

Actualmente:

- El backend se ejecuta en una red local.
- SQLite se utiliza como base de datos de desarrollo.
- El pago es una simulación.
- No existe integración con una pasarela de pagos.
- El seguimiento utiliza estados y no GPS en tiempo real.
- No se implementaron notificaciones push.
- La autenticación no utiliza tokens.

## 🔮 Trabajo futuro

Entre las mejoras propuestas se encuentran:

- Desplegar el backend en un servidor remoto.
- Implementar autenticación mediante tokens.
- Incorporar HTTPS.
- Asociar los pedidos a cada usuario.
- Integrar una pasarela de pagos.
- Incorporar geolocalización.
- Implementar notificaciones push.
- Mejorar la administración de restaurantes y productos.

## 👨‍💻 Autor

**Juan Pablo Tapia Arancibia**

Proyecto desarrollado como parte del proceso académico de desarrollo de aplicaciones móviles.