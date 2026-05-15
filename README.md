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
* **Navegación intuitiva:** Transición entre diferentes apartados de la aplicación.
* **Manejo de estado visual:** La aplicación recuerda en qué pestaña se encuentra el usuario y la resalta visualmente.
* Logging
* Widgets lifecycle examples
* Persistence
* GPS coordinates
* ListView

Lista de características técnicas de la aplicación:
* **Desarrollo Multiplataforma:** Implementado en Flutter y Dart.
* **Menú:** Utilización del widget `BottomNavigationBar` para la navegación principal.
* **Modularidad:** Separación de la interfaz en múltiples archivos (arquitectura de vistas en la carpeta `screens`) para mantener un código limpio.
* **Gestión de Estado:** Uso de `StatefulWidget` en la vista principal para controlar el índice de la pantalla seleccionada de forma dinámica.

## How to Use

Al iniciar la aplicación, el usuario es dirigido directamente a la pantalla principal de la app ("Inicio"). Para acceder a todas las secciones, el usuario debe utilizar el menú de navegación situado en la parte inferior de la pantalla. Al tocar cualquiera de los tres iconos (Inicio, Buscar, Notificaciones), la vista central se actualizará instantáneamente para mostrar el contenido correspondiente a esa pestaña.  En la página principal tenemos un boton en la parte superior de SETTINGS, el cual nos dice nuestras credenciales almacenadas si ya las hemos introducido.  Tenemos un boton para activar nuestra ubicación y que le permita a la aplicación almacenarla y mostrarnosla en la pantalla de búsqueda.  En la pantalla notificaciones tneemos varios botones que nos muestran a modo ejemplo como sería un alerdialog, un snackbar, etc.

## Participants

Lista de desarrolladores de MAD:
* Eduardo Enrique Montiel Rios (e.montiel@alumnos.upm.es)
* Miguel Rodríguez de la Huerga (miguel.rdelahuerga@alumnos.upm.es)
