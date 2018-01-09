FROM dockerepo.library.arizona.edu:5000/debian-shibboleth:stretch-1.0

# Make apt-get commands temporarily non-interactive
# Solution from https://github.com/phusion/baseimage-docker/issues/58
# Update apt cache to use fastest local mirror
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive && apt-get install -y supervisor

COPY supervisor/shibboleth.conf /etc/supervisor/conf.d/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
