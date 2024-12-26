# Build static files
FROM alpine:latest AS build-deps

## Set hugo version
ENV HUGO_VERSION 0.55.6

## Install gcompat
RUN apk add --no-cache gcompat

## Install hugo
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
RUN apk add --no-cache --update wget git libstdc++ \
 && wget --no-check-certificate https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} \
 && tar zxvf ${HUGO_BINARY} \
 && mv hugo /usr/local/bin/hugo \
 && rm ${HUGO_BINARY} \
 && chmod +x /usr/local/bin/hugo

## Copy files
WORKDIR /src
COPY . .

## Get repo submodules files
RUN git submodule update --init --recursive

## Build static files
RUN hugo

# Serve static files using nginx
FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-deps /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
