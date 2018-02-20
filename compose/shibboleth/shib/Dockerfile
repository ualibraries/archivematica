FROM uazlibraries/shibboleth-fastcgi

# Create archivematica uid.gid so dip-display run by supervisor can see dips
# Add archivematica to _shibd group
# Add _shibd to archivematica group
RUN \
groupadd archivematica --gid 333 && \
useradd archivematica --uid 333 --gid 333 \
--home /var/archivematica --shell /bin/false && \
adduser _shibd archivematica && \
adduser archivematica _shibd
