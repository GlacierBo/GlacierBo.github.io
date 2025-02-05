FROM nginx:1.18

EXPOSE 80

COPY . /usr/share/nginx/html/
