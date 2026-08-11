FROM php:8.1-apache

# Install Node.js & npm
RUN apt-get update && apt-get install -y nodejs npm

WORKDIR /var/www/html

# Copy project files
COPY . .

# Install dependencies
RUN npm install

# Enable Apache rewrite module and configure web root
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Expose web port
EXPOSE 80

# Start both Node bot and Apache web server
CMD node bot.js & apache2-foreground
