# horarioFacilSIGA
Proyecto del ramo desarrollo de aplicaciones móviles, el cual consiste en la creación de una aplicación móvil que permita el traspaso del horario que aparece en el SIGA de cada estudiante a una interfaz de más fácil acceso, uso y visibilidad.
Las tecnologías y librerías usadas son:
- Flutter con Dart
- Riverpod
- FilePicker
- FastApi
- Uvicorn
- PyPDF
- Hive
- Firebase Authentication
- Cloud Firestore

# grupo_archivos_siga

Es la parte del proyecto que respecta a la aplicación Flutter con Dart, por complicaciones de Hardware se uso un simulador de Chrome, por lo tanto, para su uso, además de las dependencias necesarias, se requiere cambiar la ip de la API de 127.0.0.1:8000 a 10.0.2.2:8000 (se cambia en lib/data/services/pdf_parser.dart) para usar android studio, es obligatorio primero correr la API para el correcto funcionamiento de la aplicación, y el comando usado en terminal para correr la aplicación en Google Chrome es la siguiente sin las comillas simples 'flutter run -d chrome --web-browser-flag "--disable-web-security"'

# pdf_api_siga

Es la parte del proyecto que respecta a la API que nos deja extraer el texto, para su uso es necesario instalar las dependencias requeridas como fastapi o pypdf, en terminal la línea que se usa para levantar la api es la siguiente sin comillas simples 'uvicorn main:app --reload --host 127.0.0.1 --port 8000'
