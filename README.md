# 🪕 Cambur Pintón

<p align="center">
  <img src="https://camburpinton.devlatam.net/favicon.png" alt="Cambur Pintón Logo" width="140" height="140">
</p>

<p align="center">
  <b>Aplicación Web y Móvil Offline para Digitación de Acordes y Armonía del Cuatro Venezolano</b>
</p>

<p align="center">
  <a href="https://camburpinton.devlatam.net" target="_blank">🌐 Probar Aplicación Web</a>
</p>

---

## 📌 Descripción

**Cambur Pintón** es una herramienta digital desarrollada en Flutter diseñada para cuatristas, músicos y estudiantes de la música tradicional venezolana. Permite explorar la armonía del cuatro, consultar digitaciones de acordes en un diapasón interactivo y realizar búsquedas inversas de posiciones en el instrumento.

## 🚀 Características Principales

* **🎵 Tabla de Tonalidades y Armonía:** Selector de escalas/tonalidades y visualización de acordes por grados armónicos (I, II, III, IV, V, VI, VII).
* **🔍 Identificador Inverso de Acordes:** Armador interactivo de pisadas sobre el diapasón para identificar el acorde resultante y sus funciones armónicas.
* **⚡ Funcionamiento 100% Offline:** Consumo de datos local a través de estructuras JSON integradas, garantizando rapidez y disponibilidad sin conexión.
* **📱 Multiplataforma:** Optimizado para navegadores Web, Android e iOS.

## 🛠️ Tecnologías Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (v3.x+)
* **Lenguaje:** [Dart](https://dart.dev/)
* **Gestión de Estado:** `provider`
* **Despliegue Web:** Apache / cPanel en subdominio dedicado (`camburpinton.devlatam.net`)

## 📁 Estructura del Proyecto

```text
cambur_pinton/
├── assets/
│   └── data/
│       ├── acordes_cuatro.json   # Diccionario de posiciones y trastes
│       └── tonalidades.json      # Escalas y funciones armónicas
├── lib/
│   ├── models/                   # Modelos de datos (Acorde, Tonalidad)
│   ├── services/                 # Carga de datos y lógica de negocio
│   ├── widgets/                  # Diapasón interactivo y componentes UI
│   ├── screens/                  # Pantallas principales
│   └── main.dart                 # Punto de entrada de la aplicación
└── pubspec.yaml                  # Configuración de dependencias y assets
