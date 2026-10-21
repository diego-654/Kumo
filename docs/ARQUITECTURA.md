# Arquitectura de Kumo

Este documento explica *por qué* el proyecto está organizado así.

## 1. Organización por features, no por tipo de archivo

En lugar de carpetas globales `screens/`, `models/`, `services/`, cada
funcionalidad vive en `lib/features/<feature>/`. Así, todo lo relacionado con
"momentos" está junto; añadir, mover o borrar una feature no toca el resto de
la app, y el equipo puede trabajar en paralelo sin pisarse.

`app/` compone la aplicación (router, tema raíz) y `core/` guarda lo que usan
varias features. Una feature nunca importa el interior de otra; si dos
features necesitan algo común, eso sube a `core/`.

## 2. Tres capas dentro de cada feature (arquitectura limpia)

```
presentation  ──►  domain  ◄──  data
```

- **domain**: entidades (`Moment`) y contratos (`MomentsRepository`). Es Dart
  puro: no importa Flutter UI, ni paquetes de red, ni JSON. Es el corazón
  estable de la app.
- **data**: implementa los contratos del dominio. Hoy es
  `InMemoryMomentsRepository`; mañana será una implementación con API o
  Firestore, con DTOs que conviertan JSON ⇄ entidad.
- **presentation**: widgets y providers de Riverpod. Solo conoce la
  *interfaz* del repositorio, nunca la implementación concreta.

La regla de oro es que **las flechas de dependencia apuntan hacia el
dominio**. Esto es el principio de inversión de dependencias (la "D" de
SOLID): cambiar de backend solo modifica `data/` y una línea en el provider.

Casos de uso (`domain/usecases/`): se añadirán cuando haya lógica de negocio
que combine varios repositorios (por ejemplo, "guardar momento" = subir foto
+ clasificar emoción con IA + persistir). Crearlos vacíos ahora solo añadiría
archivos que reenvían llamadas.

## 3. Riverpod para estado e inyección de dependencias

`flutter_riverpod` cumple dos papeles:

1. **Inyección de dependencias**: `momentsRepositoryProvider` es el único
   lugar que decide qué implementación se usa. En tests se reemplaza con
   `ProviderScope(overrides: [momentsRepositoryProvider.overrideWithValue(fake)])`.
2. **Estado reactivo**: `momentsProvider` (un `FutureProvider`) expone un
   `AsyncValue` con `loading`, `error` y `data`, y la pantalla lo pinta con
   `.when(...)`. Así ninguna pantalla olvida los estados de carga o error.

Por qué Riverpod y no Provider/BLoC: es seguro en compilación (no hay
`ProviderNotFoundException` en tiempo de ejecución), no depende del
`BuildContext` y es muy fácil de testear. Por ahora no usamos generación de
código (`riverpod_generator`) para mantener el proyecto simple; se puede
adoptar más adelante.

## 4. go_router para la navegación

- Rutas declarativas y centralizadas en `app/router/`, con las rutas como
  constantes en `AppRoutes` (sin strings mágicos).
- `StatefulShellRoute.indexedStack` crea la barra inferior (Mapa / Momentos)
  y **conserva el estado de cada tab** al cambiar entre ellos, igual que las
  apps nativas de iOS.
- El router está dentro de un provider para que en el futuro pueda leer el
  estado de sesión y redirigir al login (`redirect`).
- Soporta deep links (útil para compartir un lugar del mapa).

## 5. Lints estrictos

`very_good_analysis` activa unas 200 reglas y los modos estrictos del
analizador (`strict-casts`, `strict-inference`, `strict-raw-types`), que
prohíben `dynamic` implícito. Solo desactivamos `public_member_api_docs`,
pensada para paquetes publicados. Ejecuta `flutter analyze --fatal-infos`: el
objetivo es siempre 0 avisos.

Nota: con Dart 3.13 el lint recomienda la nueva sintaxis de constructores
`const new({super.key});`, que equivale a `const MiWidget({super.key});`
sin repetir el nombre de la clase.

## 6. UI

Material 3 con un `ColorScheme.fromSeed`, tema claro y oscuro desde el primer
día, y estados vacíos que explican qué hacer (en lugar de una pantalla en
blanco).

## Identificador de la app

El bundle id es `com.kumoapp.kumo`. Antes de registrar la app en App Store
Connect conviene elegir el definitivo (por ejemplo, con tu dominio), porque
después no se puede cambiar.
