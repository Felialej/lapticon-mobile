
# LAPTICON

LAPTICON es una aplicación móvil desarrollada para la asignatura Computación Móvil. Conecta a personas que necesitan enviar encomiendas con viajeros que se desplazan entre ciudades.

Con una misma cuenta se puede acceder al modo Remitente, para publicar encomiendas, y al modo Viajero, para registrar viajes, buscar encomiendas y aceptarlas.

## Funcionalidades principales

- Registro e inicio de sesión de usuarios.
- Consulta y actualización del perfil.
- Cambio entre los modos Remitente y Viajero.
- Publicación, consulta y seguimiento de encomiendas.
- Registro, consulta y búsqueda de viajes.
- Búsqueda de encomiendas por origen y destino.
- Aceptación de encomiendas y confirmación de entrega.

## Tecnologías utilizadas

El frontend está desarrollado en Flutter y Dart. Utilizamos Firebase Authentication mediante su API REST para registrar y autenticar usuarios. El backend de LAPTICON, alojado en Render, gestiona los perfiles, los viajes y las encomiendas.

Desde el backend también consultamos el catálogo de ciudades para los formularios y las búsquedas. El catálogo de países se utiliza para seleccionar el país de nacimiento al registrarse o editar el perfil.

Las peticiones HTTP se realizan con el paquete `http` de Dart. Para acceder a los endpoints protegidos enviamos el `idToken` obtenido de Firebase en la cabecera `Authorization`.

## Cómo está organizado el código

Organizamos el código siguiendo el patrón MVC y separamos las peticiones HTTP de las pantallas.

| Carpeta o archivo | Función |
| --- | --- |
| `lib/main.dart` | Inicia la aplicación y decide si mostrar el inicio de sesión o la navegación principal. |
| `lib/models/` | Define los datos de usuarios, perfiles, viajes y encomiendas. |
| `lib/views/` | Contiene las pantallas y los componentes visuales. |
| `lib/controllers/` | Coordina las operaciones, validaciones y cambios de estado de la interfaz. |
| `lib/services/` | Realiza las peticiones HTTP y procesa las respuestas de las API. |
| `lib/config/` | Centraliza las direcciones de Firebase y del backend. |
| `lib/theme/` y `lib/utils/` | Contienen estilos, formatos y validaciones reutilizables. |
| `test/` | Contiene pruebas automatizadas de diferentes funcionalidades. |

### Inicio de la aplicación

En `main.dart`, la función `main()` ejecuta `LapticonApp`. El `AuthController` mantiene la información de la sesión: cuando hay un usuario autenticado se muestra `MainNavigationView`; de lo contrario, se muestra `LoginView`. El `ListenableBuilder` actualiza esa parte de la interfaz cuando el controlador notifica un cambio.

### Archivos principales de cada flujo

| Flujo | Vista | Controlador | Servicio |
| --- | --- | --- | --- |
| Inicio de sesión | `login_view.dart` | `auth_controller.dart` | `auth_service.dart` |
| Publicar encomienda | `registrar_encomienda_view.dart` | `registrar_encomienda_controller.dart` | `encomiendas_service.dart` |
| Registrar viaje | `registrar_viaje_view.dart` | `registrar_viaje_controller.dart` | `viajes_service.dart` |
| Tomar encomienda | `detalle_encomienda_view.dart` | `tomar_encomienda_controller.dart` | `encomiendas_service.dart` |

La vista recoge los datos y las acciones del usuario, el controlador coordina la operación y el servicio hace la petición al servidor. Los modelos representan los datos que se utilizan.

### Funcionamiento interno

Por ejemplo, al registrar un viaje, `registrar_viaje_view.dart` recoge los datos del formulario y llama a `registrar_viaje_controller.dart`. Este construye el objeto `Viaje` y utiliza `viajes_service.dart` para enviar una petición `POST /api/viajes` al backend.

En el servicio, la petición se realiza con `http.post()`. Los datos se envían en JSON y se incluye el token de Firebase para identificar al usuario:

```dart
respuesta = await http.post(
  uri,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $idToken',
  },
  body: jsonEncode(viaje.toJson()),
);
```

Cuando el backend responde, el servicio comprueba el resultado y el controlador gestiona el éxito o el error para que la vista muestre el mensaje correspondiente.

## Cómo funcionan los flujos principales

**1. Registro de usuarios.** La aplicación crea la cuenta mediante Firebase Authentication. Después utiliza el token recibido para registrar los datos del perfil en el backend (`POST /api/users/register`).

**2. Publicación de encomiendas.** El Remitente completa el formulario y la aplicación envía los datos al backend con `POST /api/encomiendas`. La publicación queda disponible para las búsquedas.

**3. Registro de viajes.** El Viajero ingresa el número de vuelo, las ciudades y la fecha. La aplicación utiliza `POST /api/viajes` y luego permite consultar los viajes registrados.

**4. Interacción entre usuarios.** El Viajero busca una encomienda disponible por ruta y puede tomarla. Si el backend confirma la operación, la encomienda pasa a estado `tomada`. Después se puede confirmar la entrega y actualizarla a `recibida`.

## Endpoints principales

Estos son algunos de los endpoints que consume la aplicación desde sus servicios:

| Método | Endpoint | Uso |
| --- | --- | --- |
| `POST` | `/api/users/register` | Registrar el perfil del usuario. |
| `GET` / `PUT` | `/api/users/{uid}` | Consultar o actualizar el perfil. |
| `POST` / `GET` | `/api/viajes` | Registrar y consultar viajes propios. |
| `GET` | `/api/viajes/disponibles` | Buscar viajeros por ruta. |
| `POST` / `GET` | `/api/encomiendas` | Publicar y consultar encomiendas propias. |
| `GET` | `/api/encomiendas/disponibles` | Buscar encomiendas disponibles. |
| `GET` | `/api/encomiendas/buscar` | Consultar encomiendas disponibles y tomadas por ruta. |
| `PUT` | `/api/encomiendas/tomar/{id}` | Tomar una encomienda. |
| `PUT` | `/api/encomiendas/{id}/estado` | Confirmar el cambio a estado `recibida`. |
| `GET` | `/api/ciudades/ciudades` | Obtener el catálogo de ciudades. |
| `GET` | `/api/ciudades/paises` | Cargar los países para seleccionar el país de nacimiento en el registro y la edición del perfil. |

El backend se encuentra en `https://lapticon-backend.onrender.com`. Su documentación está disponible en [Swagger](https://lapticon-backend.onrender.com/api-docs/).


## Documentación adicional

En la carpeta [Documentación adicional](Documentaci%C3%B3n%20adicional/) se encuentran los siguientes archivos de apoyo del proyecto:

- **[Diagramas](Documentaci%C3%B3n%20adicional/Diagramas/):** diagramas de arquitectura y de los principales flujos de funcionamiento de LAPTICON.
- **[Planeación en Jira](Documentaci%C3%B3n%20adicional/PLANEACI%C3%93N%20JIRA.pdf):** documento de planeación y organización del proyecto.

## Video de funcionamiento

En el siguiente video mostramos el funcionamiento de LAPTICON, incluyendo el registro de usuarios, la publicación de encomiendas, el registro de viajes y la interacción entre Remitente y Viajero.

[Ver video de funcionamiento de LAPTICON](https://youtu.be/CaY2mkUpAYk?si=9a0FljyEYVzSfoPT)
