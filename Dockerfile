FROM alpine:edge

MAINTAINER Jermine.hu@qq.com

# ARGs for docker images build
ARG lang="en_US.UTF-8"
ARG backend="mdb"
ARG overlays=""

# change in childern:
ENV LANG              "${lang}"
ENV SHARED_GROUP_NAME "shared-access"
ENV SHARED_GROUP_ID   "500"
ENV DOMAIN                   ""
# available schemas:
# - collective        Collective attributes (experimental)
# - corba             Corba Object
# - core          (1) OpenLDAP "core"
# - cosine        (2) COSINE Pilot
# - duaconf           Client Configuration (work in progress)
# - dyngroup          Dynamic Group (experimental)
# - inetorgperson (3) InetOrgPerson
# - java              Java Object
# - misc              Miscellaneous Schema (experimental)
# - nadf              North American Directory Forum (obsolete)
# - nis           (3) Network Information Service (experimental)
# - openldap          OpenLDAP Project (FYI)
# - ppolicy           Password Policy Schema (work in progress)
# - samba         (3) Samba user accounts and group maps
# (1) allways added
# (2) required by inetorgperson
# (3) required by default lam configuration
ENV SCHEMAS "cosine inetorgperson nis samba"
ENV CONTAINERNAME            "openldap"
ENV USER                     "ldap"
ENV GROUP                    "$USER"
#ENV ORGANIZATION             ""
ENV PASSWORD                 ""
ENV DEBUG                    1
#ENV MULTI_MASTER_REPLICATION ""
ENV SERVER_NAME              ""

# ADD script files for images
ADD run.sh /run.sh
ADD health.sh /health.sh
ADD samba.schema /etc/openldap/schema/samba.schema

# Set health check policy
HEALTHCHECK --interval=60s --timeout=10s --start-period=600s --retries=3 CMD /health.sh

#Set user group
RUN chmod +x /run.sh /health.sh ;\
    apk add --no-cache openldap openldap-clients openldap-back-$backend ${overlays} ;\
    rm -rf /var/cache/apk/* ;\
    mkdir /run/openldap ;\
    chown $USER.$GROUP /run/openldap 
RUN addgroup -g $SHARED_GROUP_ID $SHARED_GROUP_NAME
RUN addgroup $USER $SHARED_GROUP_NAME

EXPOSE 389
EXPOSE 636

VOLUME /ssl
VOLUME /etc/ldap
VOLUME /var/lib/ldap
VOLUME /var/backups
VOLUME /var/restore

CMD ["/run.sh"]
