# Inception Project - 42 School

This project involves setting up a small infrastructure composed of different services using Docker and Docker Compose.

## 📋 Project Requirements (Mandatory Part)

This implementation includes only the **mandatory requirements**:

- **NGINX** container with TLSv1.2/TLSv1.3 only (port 443)
- **WordPress** container with php-fpm (without nginx)
- **MariaDB** container (without nginx)
- **Volume** for WordPress database
- **Volume** for WordPress website files
- **Docker network** connecting all containers

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     NGINX       │    │   WordPress     │    │    MariaDB      │
│   (Port 443)    │◄──►│   (PHP-FPM)     │◄──►│   (Database)    │
│   SSL/TLS       │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    Docker Network (inception-network)
```

## 🚀 Setup Instructions

### Prerequisites

- Virtual Machine (as required by the subject)
- Docker and Docker Compose installed
- User must be in the `docker` group

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd inception
   ```

2. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Build and start the infrastructure:**
   ```bash
   make
   ```

### Manual Setup Alternative

If you prefer manual setup:

1. **Update your domain name:**
   - Edit `srcs/.env` file
   - Replace `serferna.42.fr` with `yourusername.42.fr`

2. **Add to /etc/hosts:**
   ```bash
   echo "127.0.0.1 yourusername.42.fr" | sudo tee -a /etc/hosts
   ```

3. **Create data directories:**
   ```bash
   sudo mkdir -p /home/$USER/data/{wordpress,mariadb}
   sudo chown -R $USER:$USER /home/$USER/data
   ```

4. **Build and start:**
   ```bash
   make
   ```

## 🛠️ Available Commands

```bash
make all     # Build and start all services (default)
make build   # Build all Docker images
make up      # Start all services
make down    # Stop all services
make logs    # Show logs from all services
make ps      # Show running containers
make clean   # Clean containers and networks
make fclean  # Full cleanup (removes volumes and data)
make re      # Rebuild everything from scratch
make help    # Show help message
```

## 🌐 Access

After successful deployment:

- **WordPress Site**: `https://serferna.42.fr` (or your login)
- **WordPress Admin**: `https://serferna.42.fr/wp-admin`

### Default Credentials

Check the `srcs/.env` file for all credentials:

- **WordPress Admin**: `admin_user` / (see WP_ADMIN_PASSWORD in .env)
- **WordPress User**: `regular_user` / (see WP_USER_PASSWORD in .env)
- **Database**: `wpuser` / (see MYSQL_PASSWORD in .env)

## 📁 Project Structure

```
inception/
├── Makefile                    # Build automation
├── setup.sh                    # Setup script
├── PROJECT_README.md           # This file
└── srcs/
    ├── .env                    # Environment variables
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── nginx/              # NGINX reverse proxy
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/entrypoint.sh
        ├── wordpress/          # WordPress with PHP-FPM
        │   ├── Dockerfile
        │   ├── config/
        │   │   ├── php.ini
        │   │   └── www.conf
        │   └── tools/entrypoint.sh
        └── mariadb/            # MariaDB database
            ├── Dockerfile
            ├── config/my.cnf
            └── tools/entrypoint.sh
```

## 🔧 Configuration Details

### Environment Variables

All configuration is handled through environment variables in `srcs/.env`:

- `DOMAIN_NAME`: Your domain (serferna.42.fr)
- `MYSQL_*`: Database configuration
- `WP_*`: WordPress user configuration

### Volumes

- **WordPress Data**: `/home/$USER/data/wordpress` → `/var/www/html`
- **MariaDB Data**: `/home/$USER/data/mariadb` → `/var/lib/mysql`

### Network

All containers communicate through a custom bridge network `inception-network`.

## 🔒 Security Features

- **SSL/TLS**: NGINX configured with TLSv1.2/TLSv1.3 only
- **HTTPS Only**: No HTTP access (port 443 only)
- **Self-signed Certificate**: Generated automatically
- **Environment Variables**: Passwords stored in .env (not in Dockerfiles)
- **Container Isolation**: Each service in dedicated container

## 🐳 Docker Best Practices

- **No infinite loops**: Proper daemon processes
- **Alpine Linux**: Lightweight base images
- **Multi-stage builds**: Optimized image sizes
- **Health checks**: Proper service dependencies
- **Restart policies**: `unless-stopped` for automatic recovery

## 📝 Subject Compliance

This project strictly follows the 42 School Inception subject requirements:

✅ Virtual Machine deployment  
✅ Custom Dockerfiles (no pre-built images from DockerHub)  
✅ Alpine/Debian base images only  
✅ Each service in dedicated container  
✅ docker-compose.yml called by Makefile  
✅ TLSv1.2/TLSv1.3 only  
✅ Two volumes (database + website files)  
✅ Docker network connection  
✅ Auto-restart on crash  
✅ No hacky patches (tail -f, bash, sleep infinity)  
✅ Proper PID 1 processes  
✅ Two WordPress users (admin + regular)  
✅ Admin username doesn't contain 'admin'  
✅ Environment variables (no passwords in Dockerfiles)  
✅ NGINX as sole entry point (port 443 only)  

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied (Docker)**:
   ```bash
   sudo usermod -aG docker $USER
   # Then logout and login again
   ```

2. **Port 443 already in use**:
   ```bash
   sudo lsof -i :443
   # Stop conflicting services
   ```

3. **Domain not accessible**:
   - Check `/etc/hosts` file
   - Verify Docker containers are running: `make ps`

4. **Database connection issues**:
   - Check MariaDB logs: `make logs`
   - Verify environment variables in `.env`

### Logs and Debugging

```bash
make logs           # All services
make logs nginx     # NGINX only
make logs wordpress # WordPress only
make logs mariadb   # MariaDB only
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

---

**Note**: This is the mandatory part implementation only. No bonus services are included.