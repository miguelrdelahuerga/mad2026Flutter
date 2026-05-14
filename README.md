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
  <img width="209" height="372" alt="Pantalla de Inicio" src="https://github.com/user-attachments/assets/bbc3d878-d179-4303-bfdf-456423ae9b89" />
  <img width="215" height="373" alt="Pantalla de Busqueda" src="https://github.com/user-attachments/assets/25a20517-ef66-4264-9e9b-96fffebd3b66" />
  <img width="211" height="371" alt="Pantalla de Notificaciones" src="https://github.com/user-attachments/assets/aabd6aa9-699a-4f39-9d96-59f8961a4bdf" />
</div>
<p align="center">
  <i>Vistas actuales de la aplicación: Inicio, Búsqueda y Notificaciones.</i>
</p>


## Features

Lista de características funcionales de la aplicación en su estado actual:
* **Navegación intuitiva:** Transición entre diferentes apartados de la aplicación.
* **Manejo de estado visual:** La aplicación recuerda en qué pestaña se encuentra el usuario y la resalta visualmente.

Lista de características técnicas de la aplicación:
* **Desarrollo Multiplataforma:** Implementado en Flutter y Dart.
* **Menú:** Utilización del widget `BottomNavigationBar` para la navegación principal.
* **Modularidad:** Separación de la interfaz en múltiples archivos (arquitectura de vistas en la carpeta `screens`) para mantener un código limpio.
* **Gestión de Estado:** Uso de `StatefulWidget` en la vista principal para controlar el índice de la pantalla seleccionada de forma dinámica.

## How to Use

Al iniciar la aplicación, el usuario es dirigido directamente a la pantalla principal de la app ("Inicio"). Para acceder a todas las secciones, el usuario debe utilizar el menú de navegación situado en la parte inferior de la pantalla. Al tocar cualquiera de los tres iconos (Inicio, Buscar, Notificaciones), la vista central se actualizará instantáneamente para mostrar el contenido correspondiente a esa pestaña.

## Participants

Lista de desarrolladores de MAD:
* Eduardo Enrique Montiel Rios (e.montiel@alumnos.upm.es)
* Miguel Rodríguez de la Huerga (miguel.rdelahuerga@alumnos.upm.es)
