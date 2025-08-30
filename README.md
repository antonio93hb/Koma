# 📱 KOMA – Tu biblioteca de mangas, en la palma de tu mano

**KOMA** es una app nativa para iPhone y iPad, desarrollada con SwiftUI, que te permite **descubrir, guardar y gestionar mangas** de forma rápida, visual y cómoda. Todo con un diseño limpio, moderno y totalmente adaptado a iOS 17, tanto en modo claro como oscuro.

> Imagina tener tu estantería de mangas siempre contigo, con seguimiento de lectura, colecciones personalizadas y un buscador potente con filtros avanzados.

---

## 🧭 ¿Qué puedes hacer con KOMA?

- 🔐 Acceder desde una pantalla de bienvenida con Face ID (interfaz ya lista).
- 🏠 Explorar mangas populares con un carrusel destacado y un grid adaptable.
- 🔎 Buscar por título, género, tema o demografía, con filtros visuales.
- 📚 Crear tu colección personal y hacer seguimiento de tomos leídos o comprados.
- 📄 Ver fichas detalladas de cada manga con información útil y diseño visual cuidado.
- 🌐 Alternar entre vista lista o cuadrícula, ideal para iPhone o iPad.
- 🧠 Disfrutar de una experiencia fluida con datos locales, sin depender siempre de internet.

---

## ⚙️ Tecnología y arquitectura

KOMA no es solo bonita, también está bien hecha por dentro:

- 🔁 **MVVM completo:** separación clara entre vista, modelo y lógica.
- 🔗 **SwiftData:** para guardar mangas, búsquedas y filtros de forma local.
- 🌍 **Localización:** lista para varios idiomas gracias a `String Catalog` y `String(localized:)`.
- 📦 **Repository Pattern:** control total sobre las llamadas a red con `URLSession`.
- 🧪 **Manejo de errores robusto:** enum personalizados (`MangaError`, `NetworkError`) con mensajes claros para el usuario.
- 🧠 **Reactividad moderna:** uso de `@Observable`, `@MainActor` y `Async/Await` para un código limpio y fluido.
- 🎨 **Diseño responsive:** vistas adaptadas a iPhone/iPad, vertical/horizontal, con animaciones suaves y fondo dinámico.

---

## 🗂️ Estructura del proyecto

```bash
📁 Koma
├── Interface/            # Modelos DTO, persistentes y de dominio
├── Preview Content/      # Datos mock para previews SwiftUI
├── Repository/           # Capa de red y persistencia (Data & Network)
├── Resources/            # Imágenes y localización (Asset & String Catalog)
├── Utils/                # Helpers, enums, extensiones, alertas, navegación
├── View/                 # Vistas principales y componentes SwiftUI
├── ViewModel/            # Lógica de presentación de cada pantalla
└── KomaApp.swift         # Punto de entrada de la app (ModelContainer + RootView)
```

> El código está organizado y documentado para facilitar futuras mejoras o contribuciones.

---

## ✨ Detalles que marcan la diferencia

- Fondo dinámico que cambia según el manga destacado en el carrusel.
- Etiquetas visuales para mangas "En emisión", "Finalizado", etc.
- Historial de búsqueda visual con opciones de borrado rápido.
- Grid adaptativo: 3 columnas en iPhone, 5 en iPad.
- Cálculo automático de tomos leídos y comprados.

---

## 🧪 En desarrollo...

Aunque ya es funcional, hay cosas que se añadirán próximamente:

- 🔐 Face ID real (ahora es solo interfaz).
- ☁️ Guardado en la nube con iCloud o similar.
- 🔔 Notificaciones personalizadas (recordatorios de lectura, lanzamientos).
- ⌚ App para Apple Watch con resumen de lectura.

---

## 🛠️ Control de versiones y flujo de trabajo

Desarrollado con Git y GitHub, siguiendo el modelo **GitFlow**:

- `main`: versión estable.
- `develop`: integración de nuevas features.
- `feature/`, `fix/`, `refactor/`: ramas específicas por tarea.

> Esto me ha permitido mantener un desarrollo limpio, organizado y escalable.

---

## 🙌 A nivel personal

Este proyecto ha coincidido con una etapa especialmente exigente para mí, tanto a nivel laboral como personal. Aun así, he querido aplicar todo lo aprendido durante mi formación en desarrollo iOS y entregar una app con mimo, cuidada al detalle, con una arquitectura sólida y con mucho potencial de crecimiento.

---

## 📸 Vista previa

Aquí puedes ver una muestra del diseño multiplataforma de KOMA:

![Previews iPhone + iPad](./Assets/Previews/koma-screens.png)  
_(Imágenes de ejemplo en iPhone y iPad, modo claro y oscuro)_

---

## 🚀 ¿Quieres probarla o colaborar?

KOMA es un proyecto personal, pero estoy abierto a sugerencias, ideas y mejoras.  
Puedes clonarlo, probarlo en Xcode 15+ y ¡darme feedback si quieres!

---

## 📬 Contacto

Desarrollado con 💙 por [Antonio Hernández Barbadilla](https://github.com/antonio93hb)  
LinkedIn: [@antonio93hb](https://www.linkedin.com/in/antonio93hb/)  
Portfolio: [antonio93hb.github.io/portfolio](https://antonio93hb.github.io/portfolio)
