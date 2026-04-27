# Grand Stakes Casino - Android Nativo (Kotlin)

## Descripción
Grand Stakes es una aplicación de casino moderna migrada completamente de Flutter a **Android Nativo** utilizando Kotlin. El objetivo de este proyecto ha sido reconstruir la experiencia de usuario utilizando las herramientas y estándares más modernos de desarrollo en Android, asegurando un rendimiento superior, una arquitectura escalable y una interfaz gráfica de alta fidelidad.

## Tecnologías y Stack Técnico
* **Lenguaje:** Kotlin
* **Interfaz de Usuario (UI):** Jetpack Compose (Material Design 3)
* **Arquitectura:** Patrón Clean Architecture (división por capas: Data, UI, Logic, DI)
* **Inyección de Dependencias:** Dagger Hilt
* **Base de Datos Local:** Room Database
* **Navegación:** Jetpack Navigation Compose
* **Tipografía:** Integración directa con Google Fonts

## Funcionalidades y Módulos Implementados

La aplicación se estructura en los siguientes paquetes principales dentro de `app/src/main/kotlin/com/grandstakes/`:

### 1. Autenticación (`ui/auth`)
* Pantallas de **Inicio de Sesión** (`LoginScreen.kt`) y **Registro** (`RegisterScreen.kt`).
* Gestión del estado de la sesión mediante `AuthViewModel`.
* Comunicación con la capa de datos a través de `AuthRepository`.

### 2. Navegación Principal y Lobby (`ui/main`)
* **LobbyScreen:** Pantalla principal (hub) con acceso a todas las áreas del casino.
* **TransactionsScreen:** Flujo funcional de banca, depósitos y revisión de transacciones.
* **BottomNavBar:** Componente de barra de navegación inferior estandarizada para transiciones fluidas entre secciones.
* **ConfigScreen:** Configuración de la cuenta y preferencias de la aplicación.
* **TablesScreen:** Explorador de mesas disponibles para los distintos juegos.

### 3. Juegos de Casino (`ui/games`)
Se han implementado interfaces inmersivas e interactivas utilizando Jetpack Compose para los siguientes juegos:
* **Tragamonedas / Slots** (`SlotsScreen.kt`, `SlotGameScreen.kt`)
* **Blackjack** (`BlackjackScreen.kt`)
* **Ruleta** (`RouletteScreen.kt`)
* **Baccarat** (`BaccaratScreen.kt`)

Toda la lógica de juego subyacente ha sido abstraída e implementada en el módulo de negocio `logic/GameLogic.kt`.

### 4. Capa de Datos (`data`)
* **Room Database:** Migración de la persistencia (anteriormente Hive en Flutter) a Room (`AppDatabase.kt`) para asegurar transacciones fiables a nivel local.
* **Entidades:** Definición estructurada de datos e información de usuario en `Models.kt`.

### 5. Inyección de Dependencias (`di`)
* Implementación de **Dagger Hilt** (`AppModule.kt`) para instanciar repositorios, bases de datos y ViewModels de manera limpia, mejorando la mantenibilidad y facilitando el testing.

### 6. Sistema de Diseño (`ui/theme` & `ui/components`)
* Implementación estricta de un sistema de diseño propio ("App Nativa").
* **Theme:** Configuración de paleta de colores vibrantes (`Color.kt`), tipografías (`Type.kt`) y modos de visualización (`Theme.kt`).
* **Componentes Comunes:** Elementos reutilizables y animaciones fluidas centralizadas en `Common.kt` para garantizar consistencia en todas las pantallas.

## Novedades y Cambios Recientes
* Consolidación de la rama nativa (`kotlin`).
* Resolución de dependencias (uso de Compose BOM 2024.02.00, Hilt 2.48, Room 2.6.0).
* Estabilización de la navegación entre pantallas evitando problemas de la pila (back-button) que existían en versiones previas.
* Incorporación y actualización de la **Política de Privacidad** en la documentación base del proyecto.
