FROM php:8.4-fpm-alpine

# Instala dependências do sistema e extensões PHP
# Instala msmtp para interceptar e-mails e o Composer globalmente
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers \
  && apk add --no-cache \
    msmtp \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libintl \
  && pecl install xdebug \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) opcache pdo pdo_mysql intl gd zip \
  && apk del -f .build-deps

# Instalar Composer
COPY --from=composer:2.8.10 /usr/bin/composer /usr/bin/composer

# Copia os arquivos de configuração que são comuns a todos os projetos
COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY ./config/msmtprc /etc/msmtprc
COPY ./config/mail.ini /usr/local/etc/php/conf.d/mail.ini

# Define o diretório de trabalho padrão
WORKDIR /app

# Expõe a porta padrão do PHP-FPM
EXPOSE 9000