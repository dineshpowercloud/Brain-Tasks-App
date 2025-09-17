FROM nginx:alpine

# Copy static files to Nginx html directory
COPY . /usr/share/nginx/html

# Optional: Custom Nginx config for port 3000 and React routing (single-page app)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
