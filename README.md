## Proyecto Base MAD 2026 - Flutter

## Workspace

**Github:**
* **Repository:** (https://github.com/miguelrdelahuerga/mad2026Flutter)
* **Releases:** (https://github.com/miguelrdelahuerga/mad2026Flutter/releases)
* **Workspace:** (https://upm365.sharepoint.com/:u:/r/sites/mad2026Flutter/SitePages/Tracking.aspx?csf=1&web=1&share=IQAwzHxBsJYiQ4kDyDDOq3bAATEu24qRqQiveXjvy8y1CQE&e=LA344Q)

## Description

Esta aplicación sirve como base estructural para el proyecto de la asignatura Mobile App Development (MAD) en la Universidad Politécnica de Madrid (UPM). Actualmente, el proyecto implementa la arquitectura inicial de navegación de la interfaz de usuario. 

El objetivo en esta fase ha sido asentar una base limpia y escalable utilizando un menú de navegación inferior, permitiendo al usuario moverse de forma fluida entre diferentes vistas. A medida que avance el desarrollo, esta estructura servirá para integrar la temática final y las funcionalidades avanzadas requeridas por la asignatura.

## Screenshots and navigation


<div align="center">
  <img width="449" height="963" alt="image" src="https://github.com/user-attachments/assets/ae6ab739-14e1-4484-96e3-f04c3b2b56c3" />
  <img width="452" height="951" alt="image" src="https://github.com/user-attachments/assets/02141a95-1f2c-4fbd-8bde-fb4a862793ca" />
  <img width="454" height="958" alt="image" src="https://github.com/user-attachments/assets/8afe0cef-fc65-4a45-86ae-153b26f32910" />



</div>
<p align="center">
  <i>Vistas actuales de la aplicación: Inicio, Búsqueda y Notificaciones.</i>
</p>


## Features

Lista de características funcionales de la aplicación en su estado actual:
* **Autenticación segura en la nube:** Pantalla de Login integrada con Firebase Authentication que restringe el acceso a la aplicación únicamente a usuarios registrados.
* **Navegación e integridad de estado:** Menú inferior dinámico que utiliza `IndexedStack` para garantizar que el estado de los componentes (como el interruptor de activación del GPS) no se reinicie al alternar entre pestañas.
* **Persistencia Relacional Local (SQLite):** Almacenamiento estructurado en base de datos local para la gestión de coordenadas, permitiendo visualizar los registros en una lista con soporte completo para operaciones CRUD (añadir, editar y borrar datos en tiempo real).
* **Mapas interactivos y trazado de rutas:** Integración con OpenStreetMap que renderiza marcadores dinámicos leyendo las coordenadas guardadas en SQLite y dibuja líneas de ruta estáticas (`Polyline`) sobre el mapa.
* **Flujo de cierre de sesión controlado:** Botón de Logout respaldado por un cuadro de diálogo emergente de confirmación (`AlertDialog`) para invalidar de forma segura el token de sesión.
* **Logs y ciclo de vida:** Trazabilidad en la consola de depuración de los cambios de estado y eventos del ciclo de vida de los widgets.

Lista de características técnicas de la aplicación:
* **Desarrollo Multiplataforma:** Proyecto desarrollado íntegramente con el SDK de Flutter y el lenguaje Dart.
* **Modularidad y Arquitectura Clean:** Separación estricta de responsabilidades dividida en capas de interfaz (vistas independientes dentro de la carpeta `screens`), lógica de control de acceso (`app.dart`) y persistencia de datos relacionales (`DatabaseHelper`).
* **Gestión de Estado Reactiva:** Uso de `StatefulWidget` para el control de flujos locales, combinado con `StreamBuilder` para escuchar en tiempo real los cambios del estado de autenticación globales de Firebase.
* **Integración de Servicios Externos:** Conexión nativa con Google Cloud mediante Firebase Core y Firebase Auth a través de la compilación automatizada de `firebase_options.dart`.
* **Ecosistema de Dependencias:** Incorporación de los paquetes `flutter_map` y `latlong2` para la gestión geoespacial, junto con `sqflite` para el motor de base de datos local.

## How to Use

Al iniciar la aplicación, el flujo de seguridad intercepta la ruta inicial y dirige al usuario directamente a la pantalla de **Firebase Login**. Para acceder a los módulos de la aplicación, el usuario debe autenticarse introduciendo un correo electrónico y una contraseña válidos previamente registrados en la consola del proyecto. Una vez validado correctamente por los servidores de Firebase, el sistema redirige de forma automática al entorno principal.

Dentro de la aplicación, el usuario interactúa a través del menú de navegación inferior (`BottomNavigationBar`) para alternar entre los siguientes módulos:
1. **Inicio / Sensorización:** Contiene los interruptores de control para simular o capturar la ubicación. Gracias al almacenamiento de estado en la UI, las selecciones permanecen inalteradas independientemente de la navegación.
2. **Persistencia (SQLite):** Lista interactiva que se comunica directamente con la base de datos relacional del dispositivo. Permite registrar nuevos puntos, actualizar coordenadas existentes o eliminarlas permanentemente del almacenamiento.
3. **Mapas y Rutas:** Carga un mapa interactivo de OpenStreetMap centrado en Madrid (zona del Campus Sur de la UPM). Este componente mapea dinámicamente cada coordenada de SQLite en un marcador visual y superpone una línea de ruta azul que une diferentes puntos geográficos clave del recorrido.

Para terminar la sesión, el usuario puede acceder a la sección de **Settings** en la esquina superior. Al pulsar el botón de **Logout**, la aplicación despliega un cuadro de diálogo flotante ("Confirm Logout") solicitando confirmación. Al aceptar, Firebase destruye la sesión del dispositivo y el entorno expulsa inmediatamente al usuario de vuelta a la pantalla de Login, bloqueando de nuevo el acceso.
## Participants

Lista de desarrolladores de MAD:
* Eduardo Enrique Montiel Rios (e.montiel@alumnos.upm.es)
* Miguel Rodríguez de la Huerga (miguel.rdelahuerga@alumnos.upm.es)
