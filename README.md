## Proyecto Base MAD 2026 - Flutter

## Workspace

**Github:**
* **Repository:** (https://github.com/miguelrdelahuerga/mad2026Flutter)
* **Releases:** (https://github.com/miguelrdelahuerga/mad2026Flutter/releases)
* **Workspace:** (https://upm365.sharepoint.com/:u:/r/sites/mad2026Flutter/SitePages/Tracking.aspx?csf=1&web=1&share=IQAwzHxBsJYiQ4kDyDDOq3bAATEu24qRqQiveXjvy8y1CQE&e=LA344Q)

## Description

Oasis Tracker es una aplicación desarrollada como proyecto para la asignatura Mobile App Development (MAD) en la Universidad Politécnica de Madrid (UPM). Concebida como una herramienta colaborativa de supervivencia urbana, la app ayuda a los ciudadanos a combatir las olas de calor mediante la geolocalización de "Oasis" (fuentes de agua potable, zonas de sombra frondosas y refugios interiores con aire acondicionado).

El objetivo de este proyecto ha sido construir una arquitectura escalable e integrar servicios avanzados como autenticación en la nube, bases de datos relacionales locales, consumo de APIs REST en tiempo real y lectura de sensores de hardware (GPS), todo ello envuelto en una experiencia de usuario fluida y colaborativa.

## Screenshots and navigation


<div align="center">
  <img width="449" height="954" alt="image" src="https://github.com/user-attachments/assets/7e193ddd-2eac-4827-b751-673f6d8b7d51" />
  <img width="453" height="959" alt="image" src="https://github.com/user-attachments/assets/b0e5c337-a70b-4285-92e2-e6f1011f63ff" />
  <img width="443" height="969" alt="image" src="https://github.com/user-attachments/assets/0e057e5b-9ca1-41cf-affd-27fc62eade0f" />
  <img width="447" height="951" alt="image" src="https://github.com/user-attachments/assets/246b50f0-4088-4105-91ad-88f0d84e3fde" />



</div>
<p align="center">
  <i>Vistas actuales de la aplicación: Inicio, Búsqueda y Notificaciones.</i>
</p>


Lista de características funcionales de la aplicación en su estado actual:
* **Autenticación segura en la nube:** Pantalla de Login integrada con Firebase Authentication que restringe el acceso a la aplicación únicamente a usuarios registrados.
* **Geolocalización por Hardware (GPS):** Acceso nativo al sensor de ubicación del dispositivo para capturar coordenadas exactas del usuario y auto-centrar la cámara del mapa.
* **Alertas Meteorológicas en Tiempo Real:** Consumo dinámico de la API pública de Open-Meteo. La app lee el GPS del usuario, consulta la temperatura exacta en su ubicación y emite alertas (Verde, Naranja, Roja) basadas en el riesgo por calor.
* **Persistencia Colaborativa (SQLite):** Almacenamiento estructurado en base de datos local para la gestión del inventario de Oasis. Permite registrar nuevos puntos (por GPS o manual), categorizarlos, editar su estado ("Operativo" / "Averiado") y eliminarlos.
* **Mapas Dinámicos e Interactivos:** Integración con OpenStreetMap que renderiza marcadores inteligentes leyendo de SQLite. Los iconos cambian según el tipo de oasis (Gota, Árbol, Nieve) y se vuelven rojos si la comunidad reporta que están fuera de servicio.
* **Navegación Cruzada:** Menú dinámico con `IndexedStack` que mantiene el estado, y lógica de salto que permite tocar un Oasis en la lista y redirigir automáticamente la cámara del mapa hacia esas coordenadas exactas.

Lista de características técnicas de la aplicación:
* **Desarrollo Multiplataforma:** Proyecto desarrollado íntegramente con el SDK de Flutter y el lenguaje Dart.
* **Modularidad y Arquitectura Clean:** Separación estricta de responsabilidades en capas de interfaz (`screens`), lógica de control (`main_screen.dart`), y persistencia (`DatabaseHelper`).
* **Gestión de Estado Reactiva:** Uso de `StatefulWidget` combinado con `StreamBuilder` para escuchar los cambios de sesión de Firebase.
* **Consumo de APIs (HTTP):** Deserialización de respuestas JSON mediante el paquete `http`.
* **Ecosistema de Dependencias:** Incorporación de `flutter_map` y `latlong2` para renderizado geoespacial, `sqflite` para el motor relacional, `geolocator` para permisos y hardware nativo, y configuración automatizada con `firebase_options.dart`.

## How to Use

Al iniciar la aplicación, el flujo de seguridad intercepta la ruta inicial y dirige al usuario a la pantalla de **Firebase Login**. Para acceder al sistema, el usuario debe autenticarse con credenciales válidas. Tras la validación, el sistema redirige automáticamente al entorno principal.

El usuario interactúa a través del menú de navegación inferior (`BottomNavigationBar`) para explorar los 4 módulos principales:

1. **Sensor (Captura GPS):** Permite al usuario solicitar acceso al GPS de su dispositivo para obtener su ubicación actual exacta. Una vez localizada, ofrece un botón para registrar esa posición directamente como un nuevo Oasis colaborativo, eligiendo su tipo mediante un formulario emergente.
2. **Radar de Oasis (Base de Datos):** Una lista interactiva conectada a SQLite que muestra el historial de puntos guardados. El usuario puede:
   * Añadir coordenadas de forma manual mediante el botón flotante (+).
   * Marcar instantáneamente si una fuente está rota o seca usando el interruptor rápido (Switch).
   * Editar los datos (pulsación larga) o borrar registros.
   * **Navegar al Mapa:** Al hacer un toque simple sobre cualquier elemento de la lista, la app cambia de pestaña y hace zoom en el mapa exactamente sobre ese Oasis.
3. **Avisos (Clima API):** Un panel de prevención de golpes de calor. Incluye un protocolo médico de actuación y un botón dinámico que utiliza el GPS para consultar vía internet la temperatura actual de la zona, mostrando alertas en pantalla (SnackBar) codificadas por colores según la gravedad.
4. **Mapa de Oasis:** Un mapa de OpenStreetMap que, al abrirse, se centra automáticamente en la posición del usuario. Dibuja todos los Oasis almacenados en la base de datos local, cambiando visualmente su icono si el punto ha sido marcado como "fuera de servicio" en la pestaña del Radar.

Para terminar la sesión, desde la sección de **Settings** (arriba a la derecha), el usuario puede pulsar el botón rojo de **Logout**. Esto despliega un diálogo de seguridad y, al confirmar, destruye el token del dispositivo bloqueando de nuevo el acceso.
## Participants

Lista de desarrolladores de MAD:
* Eduardo Enrique Montiel Rios (e.montiel@alumnos.upm.es)
* Miguel Rodríguez de la Huerga (miguel.rdelahuerga@alumnos.upm.es)
