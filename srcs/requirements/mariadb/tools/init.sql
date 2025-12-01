CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};

-- Opcional, si quieres asegurar que root tiene contraseña (no es imprescindible)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Crear el usuario administrador solo si no existe (nombre no debe contener 'admin' o variantes)
CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';

-- Crear un segundo usuario (no administrador) solo si no existe
CREATE USER IF NOT EXISTS '${DB_SECOND_NAME}'@'%' IDENTIFIED BY '${DB_SECOND_PASSWORD}';

-- Dar acceso completo al usuario administrador sobre la base de datos de WordPress
GRANT ALL PRIVILEGES ON ${DB_DATABASE}.* TO '${DB_USER_NAME}'@'%';

-- Dar permisos limitados al segundo usuario sobre la base de datos WordPress
GRANT SELECT, INSERT, UPDATE, DELETE ON ${DB_DATABASE}.* TO '${DB_SECOND_NAME}'@'%';

FLUSH PRIVILEGES;
