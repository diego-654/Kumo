# Kumo

App móvil (iOS y Android) en Flutter para fotografiar lugares, registrar cómo
te hacen sentir y ver un mapa de calor emocional por zonas.

## Requisitos

- Flutter 3.47 (Dart 3.13) o superior, canal stable.

## Comandos

```bash
flutter pub get                 # instalar dependencias
flutter run                     # ejecutar en un simulador o dispositivo
flutter analyze --fatal-infos   # lints estrictos (deben quedar en 0)
flutter test                    # tests
dart format lib test            # formatear
```

## Estructura

```
lib/
├── main.dart                 # punto de entrada: ProviderScope + KumoApp
├── app/                      # composición de la app
│   ├── app.dart              # MaterialApp.router
│   └── router/               # go_router: rutas y shell con la barra inferior
├── core/                     # código transversal (tema, utilidades, errores)
└── features/
    ├── moments/              # registrar momentos (foto + sentimiento)
    │   ├── domain/           # entidades y contratos, Dart puro
    │   ├── data/             # implementaciones de los contratos
    │   └── presentation/     # providers de Riverpod y pantallas
    └── heat_map/             # mapa de calor emocional
```

Las decisiones de arquitectura están explicadas en
[docs/ARQUITECTURA.md](docs/ARQUITECTURA.md).
