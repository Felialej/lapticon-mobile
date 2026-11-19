# LAPTICON

LAPTICON es una aplicación móvil que desarrollamos para la asignatura Computación Móvil. Su objetivo es conectar a personas que necesitan enviar encomiendas con viajeros que se desplazan entre ciudades.

Desde una misma cuenta se puede usar el modo Remitente para publicar una encomienda o el modo Viajero para buscarla y aceptarla.

## Funcionalidades principales

- Registro de usuarios e inicio de sesión.
- Consulta y actualización del perfil.
- Selección y cambio entre los modos Remitente y Viajero.
- Publicación y seguimiento de encomiendas.
- Registro, consulta y búsqueda de viajes.
- Búsqueda de encomiendas por ciudad de origen y destino.
- Aceptación de encomiendas, consulta de las tomadas y confirmación de entrega.

## Tecnologías utilizadas

La aplicación está desarrollada en Flutter y Dart. Para el inicio de sesión utilizamos Firebase Authentication mediante su API REST. El backend REST de LAPTICON gestiona los perfiles, los viajes y las encomiendas, y proporciona los catálogos de ciudades y países.

## Estructura del proyecto

El código sigue el patrón MVC y se organiza en estas carpetas dentro de `lib/`.

- `models` contiene los modelos de datos.
- `views` contiene las pantallas y sus componentes.
- `controllers` gestiona las validaciones, el estado y las operaciones.
- `services` se comunica con las API.

La configuración, los estilos y las utilidades están en `config`, `theme` y `utils`.

## Ejecución

Se necesita tener Flutter instalado, un emulador o dispositivo Android configurado y conexión a internet.
