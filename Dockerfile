FROM php:8.1-apache

# Install Node.js, npm, git, and zip dependencies for Composer
RUN apt-get update && apt-get install -y nodejs npm git unzip libzip-dev \
    && docker-php-ext-install zip

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy project files
COPY . .

# Install Node and PHP dependencies
RUN npm install
RUN composer install --no-dev --optimize-autoloader

# Enable Apache rewrite module and configure web root
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Expose web port
EXPOSE 80

# Replace DISCORD_TOKEN_PLACEHOLDER at startup and launch bot + Apache
CMD sed -i "s|DISCORD_TOKEN_PLACEHOLDER|${DISCORD_TOKEN}|g" _config.json && node bot.js & apache2-foreground
