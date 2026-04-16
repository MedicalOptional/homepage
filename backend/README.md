# Baski Backend

Backend API con Node.js, Express y MongoDB para la app Baski.

## Instalación

```bash
npm install
```

## Variables de Entorno

Crear archivo `.env`:
```
PORT=3000
MONGODB_URI=mongodb+srv://andresserayap17:3226325537An@basedto.zz2b4yw.mongodb.net/?appName=BaseDTO
DB_NAME=tienda
```

## Ejecutar

Desarrollo:
```bash
npm run dev
```

Producción:
```bash
npm start
```

## Endpoints

### Autenticación
- `POST /auth/login` - Login con email y password
- `POST /auth/register` - Registrar nuevo usuario

### Productos
- `GET /products?category=all|masculino|femenino|infantiles` - Obtener productos

## Base de Datos

MongoDB collections:
- `users` - Usuarios registrados
- `products` - Catálogo de productos
