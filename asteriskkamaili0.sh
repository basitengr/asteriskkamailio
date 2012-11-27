#!/bin/bash
if [ $USER != "root" ]; then
	su
fi

echo "#Bajando y aplicando llave gpg del repositorio de Kamailio"
wget http://deb.kamailio.org/kamailiodebkey.gpg
apt-key add kamailiodebkey.gpg
rm kamailiodebkey.gpg

echo "#Insertando repositorios Kamailio a sources.list"
echo "### Repositorio Kamailio" >> /etc/apt/sources.list
echo "deb http://deb.kamailio.org/kamailio squeeze main" >> /etc/apt/sources.list
echo "deb-src http://deb.kamailio.org/kamailio squeeze main" >> /etc/apt/sources.list

echo "#Actualizando repositorios e instalando cosas"
apt-get update

echo "¿Desea instalar mysql? [s] o [n]"
read respuesta
if [ $respuesta = "s" ]; then
	apt-get install mysql-server libmysqlclient-dev
fi

apt-get install unixodbc-dev libmyodbc
apt-get install asterisk asterisk-mysql
apt-get install kamailio kamailio-mysql-modules kamailio-tls-modules
apt-get install rtpproxy


echo "Escriba una contraseña para el usuario asterisk de mysql: "
read contrasenasterisk

cat > asterisk.sql <<EOF
CREATE DATABASE asterisk;
USE asterisk;
GRANT ALL ON asterisk.* TO asterisk@localhost IDENTIFIED BY '$contrasenasterisk';
CREATE TABLE 'sipusers' (
  'id' int(11) NOT NULL AUTO_INCREMENT,
  'name' varchar(80) NOT NULL DEFAULT '',
  'host' varchar(31) NOT NULL DEFAULT '',
  'nat' varchar(5) NOT NULL DEFAULT 'no',
  'type' enum('user','peer','friend') NOT NULL DEFAULT 'friend',
  'accountcode' varchar(20) DEFAULT NULL,
  'amaflags' varchar(13) DEFAULT NULL,
  'call-limit' smallint(5) UNSIGNED DEFAULT NULL,
  'callgroup' varchar(10) DEFAULT NULL,
  'callerid' varchar(80) DEFAULT NULL,
  'cancallforward' char(3) DEFAULT 'yes',
  'canreinvite' char(3) DEFAULT 'yes',
  'context' varchar(80) DEFAULT NULL,
  'defaultip' varchar(15) DEFAULT NULL,
  'dtmfmode' varchar(7) DEFAULT NULL,
  'fromuser' varchar(80) DEFAULT NULL,
  'fromdomain' varchar(80) DEFAULT NULL,
  'insecure' varchar(4) DEFAULT NULL,
  'language' char(2) DEFAULT NULL,
  'mailbox' varchar(50) DEFAULT NULL,
  'md5secret' varchar(80) DEFAULT NULL,
  'deny' varchar(95) DEFAULT NULL,
  'permit' varchar(95) DEFAULT NULL,
  'mask' varchar(95) DEFAULT NULL,
  'musiconhold' varchar(100) DEFAULT NULL,
  'pickupgroup' varchar(10) DEFAULT NULL,
  'qualify' char(3) DEFAULT NULL,
  'regexten' varchar(80) DEFAULT NULL,
  'restrictcid' char(3) DEFAULT NULL,
  'rtptimeout' char(3) DEFAULT NULL,
  'rtpholdtimeout' char(3) DEFAULT NULL,
  'secret' varchar(80) DEFAULT NULL,
  'setvar' varchar(100) DEFAULT NULL,
  'disallow' varchar(100) DEFAULT NULL,
  'allow' varchar(100) DEFAULT NULL,
  'fullcontact' varchar(80) NOT NULL DEFAULT '',
  'ipaddr' varchar(45) DEFAULT NULL,
  'port' mediumint(5) UNSIGNED NOT NULL DEFAULT '0',
  'regserver' varchar(100) DEFAULT NULL,
  'regseconds' int(11) NOT NULL DEFAULT '0',
  'lastms' int(11) NOT NULL DEFAULT '0',
  'username' varchar(80) NOT NULL DEFAULT '',
  'defaultuser' varchar(80) NOT NULL DEFAULT '',
  'subscribecontext' varchar(80) DEFAULT NULL,
  'useragent' varchar(20) DEFAULT NULL,
  'sippasswd' varchar(80) DEFAULT NULL,
  PRIMARY KEY ('id'),
  UNIQUE KEY 'name_uk' ('name')
);
CREATE TABLE 'sipregs' (
  'id' int(11) NOT NULL AUTO_INCREMENT,
  'name' varchar(80) NOT NULL DEFAULT '',
  'fullcontact' varchar(80) NOT NULL DEFAULT '',
  'ipaddr' varchar(45) DEFAULT NULL,
  'port' mediumint(5) UNSIGNED NOT NULL DEFAULT '0',
  'username' varchar(80) NOT NULL DEFAULT '',
  'regserver' varchar(100) DEFAULT NULL,
  'regseconds' int(11) NOT NULL DEFAULT '0',
  'defaultuser' varchar(80) NOT NULL DEFAULT '',
  'useragent' varchar(20) DEFAULT NULL,
  'lastms' int(11) DEFAULT NULL,
  PRIMARY KEY ('id'),
  UNIQUE KEY 'name' ('name')
);
CREATE TABLE 'voiceboxes' (
  'uniqueid' int(4) NOT NULL AUTO_INCREMENT,
  'customer_id' varchar(10) DEFAULT NULL,
  'context' varchar(10) NOT NULL,
  'mailbox' varchar(10) NOT NULL,
  'password' varchar(12) NOT NULL,
  'fullname' varchar(150) DEFAULT NULL,
  'email' varchar(50) DEFAULT NULL,
  'pager' varchar(50) DEFAULT NULL,
  'tz' varchar(10) DEFAULT 'central',
  'attach' enum('yes','no') NOT NULL DEFAULT 'yes',
  'saycid' enum('yes','no') NOT NULL DEFAULT 'yes',
  'dialout' varchar(10) DEFAULT NULL,
  'callback' varchar(10) DEFAULT NULL,
  'review' enum('yes','no') NOT NULL DEFAULT 'no',
  'operator' enum('yes','no') NOT NULL DEFAULT 'no',
  'envelope' enum('yes','no') NOT NULL DEFAULT 'no',
  'sayduration' enum('yes','no') NOT NULL DEFAULT 'no',
  'saydurationm' tinyint(4) NOT NULL DEFAULT '1',
  'sendvoicemail' enum('yes','no') NOT NULL DEFAULT 'no',
  'delete' enum('yes','no') DEFAULT 'no',
  'nextaftercmd' enum('yes','no') NOT NULL DEFAULT 'yes',
  'forcename' enum('yes','no') NOT NULL DEFAULT 'no',
  'forcegreetings' enum('yes','no') NOT NULL DEFAULT 'no',
  'hidefromdir' enum('yes','no') NOT NULL DEFAULT 'yes',
  'stamp' timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY ('uniqueid'),
  KEY 'mailbox_context' ('mailbox','context')
);
CREATE TABLE 'voicemessages' (
  'id' int(11) NOT NULL AUTO_INCREMENT,
  'msgnum' int(11) NOT NULL DEFAULT '0',
  'dir' varchar(80) DEFAULT '',
  'context' varchar(80) DEFAULT '',
  'macrocontext' varchar(80) DEFAULT '',
  'callerid' varchar(40) DEFAULT '',
  'origtime' varchar(40) DEFAULT '',
  'duration' varchar(20) DEFAULT '',
  'mailboxuser' varchar(80) DEFAULT '',
  'mailboxcontext' varchar(80) DEFAULT '',
  'recording' longblob,
  'flag' varchar(128) DEFAULT '',
  PRIMARY KEY ('id'),
  KEY 'dir' ('dir')
);	
EOF

echo "#Creando base de datos asterisk, se le pide la contraseña de root"
mysql -u root -p < asterisk.sql 

echo "#Borrando archivo sql asterisk"
rm asterisk.sql

echo "#Configurando odbc"
cat > /etc/odbcinst.ini <<EOF
[MySQL]
Description = MySQL driver
Driver = libmyodbc.so
Setup = libodbcmyS.so
CPTimeout =
CPReuse =
UsageCount = 1
EOF

cat > /etc/odbc.ini <<EOF
[MySQL-asterisk]
Description = MySQL Asterisk database
Trace = Off
TraceFile = stderr
Driver = MySQL
SERVER = localhost
USER = asterisk
PASSWORD = $contrasenasterisk
PORT = 3306
DATABASE = asterisk 
EOF

mv /etc/asterisk/res_odbc.conf /etc/asterisk/res_odbc.conf.ORIG

cat > /etc/asterisk/res_odbc.conf <<EOF
[asterisk]
enabled => yes
dsn => MySQL-asterisk
username => asterisk
password => $contrasenasterisk
pre-connect => yes
EOF

mv /etc/asterisk/extconfig.conf /etc/asterisk/extconfig.conf.ORIG

cat > /etc/asterisk/extconfig.conf <<EOF
[settings]
sipusers => odbc,asterisk,sipusers
sippeers => odbc,asterisk,sipusers
sipregs => odbc,asterisk,sipregs
voicemail => odbc,asterisk,voiceboxes
EOF

mv /etc/asterisk/sip.conf /etc/asterisk/sip.conf.ORIG

echo "#Configurando asterisk"

cat > /etc/asterisk/sip.conf <<EOF
[general]
context = default
bindport = 5070
bindaddr = 127.0.0.1
tcpbindaddr = 127.0.0.1
tcpenable = yes
rtcachefriends=yes 
EOF

mv /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.ORIG

cat > /etc/asterisk/extensions.conf <<EOF
[general] 
static=yes 
writeprotect=no 

[default]
exten => _1XX,1,Dial(SIP/\${EXTEN})
exten => _1XX,n,Voicemail(\${EXTEN},u)
exten => _1XX,n,Hangup
exten => _1XX,101,Voicemail(\${EXTEN},b)
exten => _1XX,102,Hangup
EOF

echo "#Confeccionando archivo de configuración kamailio"

mv /etc/kamailio/kamailio.cfg /etc/kamailio/kamailio.cfg.ORIG


echo "#Arrancar en el inicio Kamailio"
sed -i 's/RUN_KAMAILIO=no/RUN_KAMAILIO=yes/g' /etc/default/kamailio

cat > /etc/kamailio/tls.cfg <<EOF
[server:default]
method = SSLv23
verify_certificate = no
require_certificate = no
private_key = /etc/kamailio/kamailio-selfsigned.key
certificate = /etc/kamailio/kamailio-selfsigned.pem
EOF

echo "Escriba la ip de su máquina o nombre de dominio: "
read maquina

cat >> /etc/kamailio/kamctlrc <<EOF
SIP_DOMAIN=$maquina
DBENGINE=MYSQL
EOF

echo "#Creando base de datos Kamailio"
/usr/local/sbin/kamdbctl create

echo "#Configurando Kamailio"

cat > /etc/kamailio/kamailio.cfg <<EOF
#ngrep -d eth0 -p -q -W byline port 5060
#!KAMAILIO
 
#!define WITH_MYSQL
#!define WITH_AUTH
#!define WITH_USRLOCDB
#!define WITH_ASTERISK
#!define WITH_NAT
#!define WITH_TLS
 
#
# Kamailio (OpenSER) SIP Server v3.3 - default configuration script
#     - web: http://www.kamailio.org
#     - git: http://sip-router.org
#
# Direct your questions about this file to: <sr-users@lists.sip-router.org>
#
# Refer to the Core CookBook at http://www.kamailio.org/dokuwiki/doku.php
# for an explanation of possible statements, functions and parameters.
#
# Several features can be enabled using '#!define WITH_FEATURE' directives:
#
# *** To run in debug mode: 
#     - define WITH_DEBUG
#
# *** To enable mysql: 
#     - define WITH_MYSQL
#
# *** To enable authentication execute:
#     - enable mysql
#     - define WITH_AUTH
#     - add users using 'kamctl'
#
# *** To enable IP authentication execute:
#     - enable mysql
#     - enable authentication
#     - define WITH_IPAUTH
#     - add IP addresses with group id '1' to 'address' table
#
# *** To enable persistent user location execute:
#     - enable mysql
#     - define WITH_USRLOCDB
#
# *** To enable presence server execute:
#     - enable mysql
#     - define WITH_PRESENCE
#
# *** To enable nat traversal execute:
#     - define WITH_NAT
#     - install RTPProxy: http://www.rtpproxy.org
#     - start RTPProxy:
#        rtpproxy -l _your_public_ip_ -s udp:localhost:7722
#
# *** To enable PSTN gateway routing execute:
#     - define WITH_PSTN
#     - set the value of pstn.gw_ip
#     - check route[PSTN] for regexp routing condition
#
# *** To enable database aliases lookup execute:
#     - enable mysql
#     - define WITH_ALIASDB
#
# *** To enable speed dial lookup execute:
#     - enable mysql
#     - define WITH_SPEEDDIAL
#
# *** To enable multi-domain support execute:
#     - enable mysql
#     - define WITH_MULTIDOMAIN
#
# *** To enable TLS support execute:
#     - adjust CFGDIR/tls.cfg as needed
#     - define WITH_TLS
#
# *** To enable XMLRPC support execute:
#     - define WITH_XMLRPC
#     - adjust route[XMLRPC] for access policy
#
# *** To enable anti-flood detection execute:
#     - adjust pike and htable=>ipban settings as needed (default is
#       block if more than 16 requests in 2 seconds and ban for 300 seconds)
#     - define WITH_ANTIFLOOD
#
# *** To block 3XX redirect replies execute:
#     - define WITH_BLOCK3XX
#
# *** To enable VoiceMail routing execute:
#     - define WITH_VOICEMAIL
#     - set the value of voicemail.srv_ip
#     - adjust the value of voicemail.srv_port
#
# *** To enhance accounting execute:
#     - enable mysql
#     - define WITH_ACCDB
#     - add following columns to database
#!ifdef ACCDB_COMMENT
  ALTER TABLE acc ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN src_ip varchar(64) NOT NULL default '';
  ALTER TABLE acc ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_ip varchar(64) NOT NULL default '';
  ALTER TABLE missed_calls ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
#!endif
 
####### Defined Values #########
 
# *** Value defines - IDs used later in config
#!ifdef WITH_MYSQL
# - database URL - used to connect to database server by modules such
#       as: auth_db, acc, usrloc, a.s.o.
#!define DBURL "mysql://openser:openserrw@localhost/openser"
#!ifdef WITH_ASTERISK
#!define DBASTURL "mysql://asterisk:$contrasenasterisk@localhost/asterisk"
#!endif
#!endif
#!ifdef WITH_MULTIDOMAIN
# - the value for 'use_domain' parameters
#!define MULTIDOMAIN 1
#!else
#!define MULTIDOMAIN 0
#!endif
 
# - flags
#   FLT_ - per transaction (message) flags
#	FLB_ - per branch flags
#!define FLT_ACC 1
#!define FLT_ACCMISSED 2
#!define FLT_ACCFAILED 3
#!define FLT_NATS 5
 
#!define FLB_NATB 6
#!define FLB_NATSIPPING 7
 
####### Global Parameters #########
 
#!ifdef WITH_DEBUG
debug=4
log_stderror=yes
#!else
debug=2
log_stderror=no
#!endif
 
memdbg=5
memlog=5
 
log_facility=LOG_LOCAL0
 
fork=yes
children=4
 
/* uncomment the next line to disable TCP (default on) */
#disable_tcp=yes
 
/* uncomment the next line to disable the auto discovery of local aliases
   based on reverse DNS on IPs (default on) */
#auto_aliases=no
 
/* add local domain aliases */
#alias="sip.mydomain.com"
 
/* uncomment and configure the following line if you want Kamailio to 
   bind on a specific interface/port/proto (default bind on all available) */
#listen=udp:10.0.0.10:5060
 
/* port to listen to
 * - can be specified more than once if needed to listen on many ports */
port=5060
 
#!ifdef WITH_TLS
enable_tls=yes
#!endif
 
# life time of TCP connection when there is no traffic
# - a bit higher than registration expires to cope with UA behind NAT
tcp_connection_lifetime=3605
 
####### Custom Parameters #########
 
# These parameters can be modified runtime via RPC interface
# - see the documentation of 'cfg_rpc' module.
#
# Format: group.id = value 'desc' description
# Access: \$sel(cfg_get.group.id) or @cfg_get.group.id
#
 
#!ifdef WITH_PSTN
# PSTN GW Routing
#
# - pstn.gw_ip: valid IP or hostname as string value, example:
# pstn.gw_ip = "10.0.0.101" desc "My PSTN GW Address"
#
# - by default is empty to avoid misrouting
pstn.gw_ip = "" desc "PSTN GW Address"
#!endif
 
#!ifdef WITH_VOICEMAIL
# VoiceMail Routing on offline, busy or no answer
#
# - by default Voicemail server IP is empty to avoid misrouting
voicemail.srv_ip = "" desc "VoiceMail IP Address"
voicemail.srv_port = "5060" desc "VoiceMail Port"
#!endif
 
 
#!ifdef WITH_ASTERISK
asterisk.bindip = "127.0.0.1" desc "Asterisk IP Address"
asterisk.bindport = "5070" desc "Asterisk Port"
kamailio.bindip = "0.0.0.0" desc "Kamailio IP Address"
kamailio.bindport = "5060" desc "Kamailio Port"
#!endif
 
####### Modules Section ########
 
# set paths to location of modules (to sources or installation folders)
#!ifdef WITH_SRCPATH
mpath="modules_k:modules"
#!else
mpath="/usr/local/lib/kamailio/modules_k/:/usr/local/lib/kamailio/modules/"
#!endif
 
#!ifdef WITH_MYSQL
loadmodule "db_mysql.so"
#!endif
 
loadmodule "mi_fifo.so"
loadmodule "kex.so"
loadmodule "tm.so"
loadmodule "tmx.so"
loadmodule "sl.so"
loadmodule "rr.so"
loadmodule "pv.so"
loadmodule "maxfwd.so"
loadmodule "usrloc.so"
loadmodule "registrar.so"
loadmodule "textops.so"
loadmodule "siputils.so"
loadmodule "xlog.so"
loadmodule "sanity.so"
loadmodule "ctl.so"
loadmodule "cfg_rpc.so"
loadmodule "mi_rpc.so"
loadmodule "acc.so"
 
#!ifdef WITH_AUTH
loadmodule "auth.so"
loadmodule "auth_db.so"
#!ifdef WITH_IPAUTH
loadmodule "permissions.so"
#!endif
#!endif
 
#!ifdef WITH_ALIASDB
loadmodule "alias_db.so"
#!endif
 
#!ifdef WITH_SPEEDDIAL
loadmodule "speeddial.so"
#!endif
 
#!ifdef WITH_MULTIDOMAIN
loadmodule "domain.so"
#!endif
 
#!ifdef WITH_PRESENCE
loadmodule "presence.so"
loadmodule "presence_xml.so"
#!endif
 
#!ifdef WITH_NAT
loadmodule "nathelper.so"
loadmodule "rtpproxy.so"
#!endif
 
#!ifdef WITH_TLS
loadmodule "tls.so"
#!endif
 
#!ifdef WITH_ANTIFLOOD
loadmodule "htable.so"
loadmodule "pike.so"
#!endif
 
#!ifdef WITH_XMLRPC
loadmodule "xmlrpc.so"
#!endif
 
#!ifdef WITH_DEBUG
loadmodule "debugger.so"
#!endif
 
#!ifdef WITH_ASTERISK
loadmodule "uac.so"
#!endif
 
# ----------------- setting module-specific parameters ---------------
 
 
# ----- mi_fifo params -----
modparam("mi_fifo", "fifo_name", "/tmp/kamailio_fifo")
 
 
# ----- tm params -----
# auto-discard branches from previous serial forking leg
modparam("tm", "failure_reply_mode", 3)
# default retransmission timeout: 30sec
modparam("tm", "fr_timer", 30000)
# default invite retransmission timeout after 1xx: 120sec
modparam("tm", "fr_inv_timer", 120000)
 
 
# ----- rr params -----
# add value to ;lr param to cope with most of the UAs
modparam("rr", "enable_full_lr", 1)
# do not append from tag to the RR (no need for this script)
#!ifdef WITH_ASTERISK
modparam("rr", "append_fromtag", 1)
#!else
modparam("rr", "append_fromtag", 0)
#!endif
 
# ----- registrar params -----
modparam("registrar", "method_filtering", 1)
/* uncomment the next line to disable parallel forking via location */
# modparam("registrar", "append_branches", 0)
/* uncomment the next line not to allow more than 10 contacts per AOR */
#modparam("registrar", "max_contacts", 10)
# max value for expires of registrations
modparam("registrar", "max_expires", 3600)
# set it to 1 to enable GRUU
modparam("registrar", "gruu_enabled", 0)
 
 
# ----- acc params -----
/* what special events should be accounted ? */
modparam("acc", "early_media", 0)
modparam("acc", "report_ack", 0)
modparam("acc", "report_cancels", 0)
/* by default ww do not adjust the direct of the sequential requests.
   if you enable this parameter, be sure the enable "append_fromtag"
   in "rr" module */
modparam("acc", "detect_direction", 0)
/* account triggers (flags) */
modparam("acc", "log_flag", FLT_ACC)
modparam("acc", "log_missed_flag", FLT_ACCMISSED)
modparam("acc", "log_extra", 
	"src_user=\$fU;src_domain=\$fd;src_ip=\$si;"
	"dst_ouser=\$tU;dst_user=\$rU;dst_domain=\$rd")
modparam("acc", "failed_transaction_flag", FLT_ACCFAILED)
/* enhanced DB accounting */
#!ifdef WITH_ACCDB
modparam("acc", "db_flag", FLT_ACC)
modparam("acc", "db_missed_flag", FLT_ACCMISSED)
modparam("acc", "db_url", DBURL)
modparam("acc", "db_extra",
	"src_user=\$fU;src_domain=\$fd;src_ip=\$si;"
	"dst_ouser=\$tU;dst_user=\$rU;dst_domain=\$rd")
#!endif
 
 
# ----- usrloc params -----
/* enable DB persistency for location entries */
#!ifdef WITH_USRLOCDB
modparam("usrloc", "db_url", DBURL)
modparam("usrloc", "db_mode", 2)
modparam("usrloc", "use_domain", MULTIDOMAIN)
#!endif
 
 
# ----- auth_db params -----
#!ifdef WITH_AUTH
modparam("auth_db", "calculate_ha1", yes)
modparam("auth_db", "load_credentials", "")
 
#!ifdef WITH_ASTERISK
modparam("auth_db", "user_column", "username")
modparam("auth_db", "password_column", "sippasswd")
modparam("auth_db", "db_url", DBASTURL)
modparam("auth_db", "version_table", 0)
#!else
modparam("auth_db", "db_url", DBURL)
modparam("auth_db", "password_column", "password")
modparam("auth_db", "use_domain", MULTIDOMAIN)
#!endif
 
# ----- permissions params -----
#!ifdef WITH_IPAUTH
modparam("permissions", "db_url", DBURL)
modparam("permissions", "db_mode", 1)
#!endif
 
#!endif
 
 
# ----- alias_db params -----
#!ifdef WITH_ALIASDB
modparam("alias_db", "db_url", DBURL)
modparam("alias_db", "use_domain", MULTIDOMAIN)
#!endif
 
 
# ----- speedial params -----
#!ifdef WITH_SPEEDDIAL
modparam("speeddial", "db_url", DBURL)
modparam("speeddial", "use_domain", MULTIDOMAIN)
#!endif
 
 
# ----- domain params -----
#!ifdef WITH_MULTIDOMAIN
modparam("domain", "db_url", DBURL)
# register callback to match myself condition with domains list
modparam("domain", "register_myself", 1)
#!endif
 
 
#!ifdef WITH_PRESENCE
# ----- presence params -----
modparam("presence", "db_url", DBURL)
 
# ----- presence_xml params -----
modparam("presence_xml", "db_url", DBURL)
modparam("presence_xml", "force_active", 1)
#!endif
 
 
#!ifdef WITH_NAT
# ----- rtpproxy params -----
modparam("rtpproxy", "rtpproxy_sock", "udp:127.0.0.1:7722")
 
# ----- nathelper params -----
modparam("nathelper", "natping_interval", 30)
modparam("nathelper", "ping_nated_only", 1)
modparam("nathelper", "sipping_bflag", FLB_NATSIPPING)
modparam("nathelper", "sipping_from", "sip:pinger@kamailio.org")
 
# params needed for NAT traversal in other modules
modparam("nathelper|registrar", "received_avp", "\$avp(RECEIVED)")
modparam("usrloc", "nat_bflag", FLB_NATB)
#!endif
 
 
#!ifdef WITH_TLS
# ----- tls params -----
modparam("tls", "config", "/usr/local/etc/kamailio/tls.cfg")
#!endif
 
#!ifdef WITH_ANTIFLOOD
# ----- pike params -----
modparam("pike", "sampling_time_unit", 2)
modparam("pike", "reqs_density_per_unit", 16)
modparam("pike", "remove_latency", 4)
 
# ----- htable params -----
# ip ban htable with autoexpire after 5 minutes
modparam("htable", "htable", "ipban=>size=8;autoexpire=300;")
#!endif
 
#!ifdef WITH_XMLRPC
# ----- xmlrpc params -----
modparam("xmlrpc", "route", "XMLRPC");
modparam("xmlrpc", "url_match", "^/RPC")
#!endif
 
#!ifdef WITH_DEBUG
# ----- debugger params -----
modparam("debugger", "cfgtrace", 1)
#!endif
 
####### Routing Logic ########
 
 
# Main SIP request routing logic
# - processing of any incoming SIP request starts with this route
# - note: this is the same as route { ... }
request_route {
 
	# per request initial checks
	route(REQINIT);
 
	# NAT detection
	route(NATDETECT);
 
	# handle requests within SIP dialogs
	route(WITHINDLG);
 
	### only initial requests (no To tag)
 
	# CANCEL processing
	if (is_method("CANCEL"))
	{
		if (t_check_trans())
			t_relay();
		exit;
	}
 
	t_check_trans();
 
	# authentication
	route(AUTH);
 
	# record routing for dialog forming requests (in case they are routed)
	# - remove preloaded route headers
	remove_hf("Route");
	if (is_method("INVITE|SUBSCRIBE"))
		record_route();
 
	# account only INVITEs
	if (is_method("INVITE"))
	{
		setflag(FLT_ACC); # do accounting
	}
 
	# dispatch requests to foreign domains
	route(SIPOUT);
 
	### requests for my local domains
 
	# handle presence related requests
	route(PRESENCE);
 
	# handle registrations
	route(REGISTRAR);
 
	if (\$rU==\$null)
	{
		# request with no Username in RURI
		sl_send_reply("484","Address Incomplete");
		exit;
	}
 
	# dispatch destinations to PSTN
	route(PSTN);
 
	# user location service
	route(LOCATION);
 
	route(RELAY);
}
 
 
route[RELAY] {
 
	# enable additional event routes for forwarded requests
	# - serial forking, RTP relaying handling, a.s.o.
	if (is_method("INVITE|SUBSCRIBE")) {
		t_on_branch("MANAGE_BRANCH");
		t_on_reply("MANAGE_REPLY");
	}
	if (is_method("INVITE")) {
		t_on_failure("MANAGE_FAILURE");
	}
 
	if (!t_relay()) {
		sl_reply_error();
	}
	exit;
}
 
# Per SIP request initial checks
route[REQINIT] {
#!ifdef WITH_ANTIFLOOD
	# flood dection from same IP and traffic ban for a while
	# be sure you exclude checking trusted peers, such as pstn gateways
	# - local host excluded (e.g., loop to self)
	if(src_ip!=myself)
	{
		if(\$sht(ipban=>\$si)!=\$null)
		{
			# ip is already blocked
			xdbg("request from blocked IP - \$rm from \$fu (IP:\$si:\$sp)\n");
			exit;
		}
		if (!pike_check_req())
		{
			xlog("L_ALERT","ALERT: pike blocking \$rm from \$fu (IP:\$si:\$sp)\n");
			\$sht(ipban=>\$si) = 1;
			exit;
		}
	}
#!endif
 
	if (!mf_process_maxfwd_header("10")) {
		sl_send_reply("483","Too Many Hops");
		exit;
	}
 
	if(!sanity_check("1511", "7"))
	{
		xlog("Malformed SIP message from \$si:\$sp\n");
		exit;
	}
}
 
# Handle requests within SIP dialogs
route[WITHINDLG] {
	if (has_totag()) {
		# sequential request withing a dialog should
		# take the path determined by record-routing
		if (loose_route()) {
			if (is_method("BYE")) {
				setflag(FLT_ACC); # do accounting ...
				setflag(FLT_ACCFAILED); # ... even if the transaction fails
			}
			if ( is_method("ACK") ) {
				# ACK is forwarded statelessy
				route(NATMANAGE);
			}
			route(RELAY);
		} else {
			if (is_method("SUBSCRIBE") && uri == myself) {
				# in-dialog subscribe requests
				route(PRESENCE);
				exit;
			}
			if ( is_method("ACK") ) {
				if ( t_check_trans() ) {
					# no loose-route, but stateful ACK;
					# must be an ACK after a 487
					# or e.g. 404 from upstream server
					t_relay();
					exit;
				} else {
					# ACK without matching transaction ... ignore and discard
					exit;
				}
			}
			sl_send_reply("404","Not here");
		}
		exit;
	}
}
 
# Handle SIP registrations
route[REGISTRAR] {
	if (is_method("REGISTER"))
	{
		if(isflagset(FLT_NATS))
		{
			setbflag(FLB_NATB);
			# uncomment next line to do SIP NAT pinging 
			## setbflag(FLB_NATSIPPING);
		}
		if (!save("location"))
			sl_reply_error();
 
#!ifdef WITH_ASTERISK
		route(REGFWD);
#!endif
 
		exit;
	}
}
 
# USER location service
route[LOCATION] {
 
#!ifdef WITH_SPEEDIAL
	# search for short dialing - 2-digit extension
	if(\$rU=~"^[0-9][0-9]\$")
		if(sd_lookup("speed_dial"))
			route(SIPOUT);
#!endif
 
#!ifdef WITH_ALIASDB
	# search in DB-based aliases
	if(alias_db_lookup("dbaliases"))
		route(SIPOUT);
#!endif
 
#!ifdef WITH_ASTERISK
	if(is_method("INVITE") && (!route(FROMASTERISK))) {
		# if new call from out there - send to Asterisk
		# - non-INVITE request are routed directly by Kamailio
		# - traffic from Asterisk is routed also directy by Kamailio
		route(TOASTERISK);
		exit;
	}
#!endif
 
	\$avp(oexten) = \$rU;
	if (!lookup("location")) {
		\$var(rc) = \$rc;
		route(TOVOICEMAIL);
		t_newtran();
		switch (\$var(rc)) {
			case -1:
			case -3:
				send_reply("404", "Not Found");
				exit;
			case -2:
				send_reply("405", "Method Not Allowed");
				exit;
		}
	}
 
	# when routing via usrloc, log the missed calls also
	if (is_method("INVITE"))
	{
		setflag(FLT_ACCMISSED);
	}
}
 
# Presence server route
route[PRESENCE] {
	if(!is_method("PUBLISH|SUBSCRIBE"))
		return;
 
#!ifdef WITH_PRESENCE
	if (!t_newtran())
	{
		sl_reply_error();
		exit;
	};
 
	if(is_method("PUBLISH"))
	{
		handle_publish();
		t_release();
	}
	else
	if( is_method("SUBSCRIBE"))
	{
		handle_subscribe();
		t_release();
	}
	exit;
#!endif
 
	# if presence enabled, this part will not be executed
	if (is_method("PUBLISH") || \$rU==\$null)
	{
		sl_send_reply("404", "Not here");
		exit;
	}
	return;
}
 
# Authentication route
route[AUTH] {
#!ifdef WITH_AUTH
 
#!ifdef WITH_ASTERISK
	# do not auth traffic from Asterisk - trusted!
	if(route(FROMASTERISK))
		return;
#!endif
 
#!ifdef WITH_IPAUTH
	if((!is_method("REGISTER")) && allow_source_address())
	{
		# source IP allowed
		return;
	}
#!endif
 
	if (is_method("REGISTER") || from_uri==myself)
	{
		# authenticate requests
#!ifdef WITH_ASTERISK
		if (!auth_check("\$fd", "sipusers", "1")) {
#!else
		if (!auth_check("\$fd", "subscriber", "1")) {
#!endif
			auth_challenge("\$fd", "0");
			exit;
		}
		# user authenticated - remove auth header
		if(!is_method("REGISTER|PUBLISH"))
			consume_credentials();
	}
	# if caller is not local subscriber, then check if it calls
	# a local destination, otherwise deny, not an open relay here
	if (from_uri!=myself && uri!=myself)
	{
		sl_send_reply("403","Not relaying");
		exit;
	}
 
#!endif
	return;
}
 
# Caller NAT detection route
route[NATDETECT] {
#!ifdef WITH_NAT
	force_rport();
	if (nat_uac_test("19")) {
		if (is_method("REGISTER")) {
			fix_nated_register();
		} else {
			fix_nated_contact();
		}
		setflag(FLT_NATS);
	}
#!endif
	return;
}
 
# RTPProxy control
route[NATMANAGE] {
#!ifdef WITH_NAT
	if (is_request()) {
		if(has_totag()) {
			if(check_route_param("nat=yes")) {
				setbflag(FLB_NATB);
			}
		}
	}
	if (!(isflagset(FLT_NATS) || isbflagset(FLB_NATB)))
		return;
 
	rtpproxy_manage();
 
	if (is_request()) {
		if (!has_totag()) {
			add_rr_param(";nat=yes");
		}
	}
	if (is_reply()) {
		if(isbflagset(FLB_NATB)) {
			fix_nated_contact();
		}
	}
#!endif
	return;
}
 
# Routing to foreign domains
route[SIPOUT] {
	if (!uri==myself)
	{
		append_hf("P-hint: outbound\r\n");
		route(RELAY);
	}
}
 
# PSTN GW routing
route[PSTN] {
#!ifdef WITH_PSTN
	# check if PSTN GW IP is defined
	if (strempty(\$sel(cfg_get.pstn.gw_ip))) {
		xlog("SCRIPT: PSTN rotuing enabled but pstn.gw_ip not defined\n");
		return;
	}
 
	# route to PSTN dialed numbers starting with '+' or '00'
	#     (international format)
	# - update the condition to match your dialing rules for PSTN routing
	if(!(\$rU=~"^(\+|00)[1-9][0-9]{3,20}\$"))
		return;
 
	# only local users allowed to call
	if(from_uri!=myself) {
		sl_send_reply("403", "Not Allowed");
		exit;
	}
 
	\$ru = "sip:" + \$rU + "@" + \$sel(cfg_get.pstn.gw_ip);
 
	route(RELAY);
	exit;
#!endif
 
	return;
}
 
# XMLRPC routing
#!ifdef WITH_XMLRPC
route[XMLRPC] {
	# allow XMLRPC from localhost
	if ((method=="POST" || method=="GET")
			&& (src_ip==127.0.0.1)) {
		# close connection only for xmlrpclib user agents (there is a bug in
		# xmlrpclib: it waits for EOF before interpreting the response).
		if (\$hdr(User-Agent) =~ "xmlrpclib")
			set_reply_close();
		set_reply_no_connect();
		dispatch_rpc();
		exit;
	}
	send_reply("403", "Forbidden");
	exit;
}
#!endif
 
# route to voicemail server
route[TOVOICEMAIL] {
#!ifdef WITH_VOICEMAIL
	if(!is_method("INVITE"))
		return;
 
	# check if VoiceMail server IP is defined
	if (strempty(\$sel(cfg_get.voicemail.srv_ip))) {
		xlog("SCRIPT: VoiceMail rotuing enabled but IP not defined\n");
		return;
	}
	if(\$avp(oexten)==\$null)
		return;
 
	\$ru = "sip:" + \$avp(oexten) + "@" + \$sel(cfg_get.voicemail.srv_ip)
				+ ":" + \$sel(cfg_get.voicemail.srv_port);
	route(RELAY);
	exit;
#!endif
 
	return;
}
 
# manage outgoing branches
branch_route[MANAGE_BRANCH] {
	xdbg("new branch [\$T_branch_idx] to \$ru\n");
	route(NATMANAGE);
}
 
# manage incoming replies
onreply_route[MANAGE_REPLY] {
	xdbg("incoming reply\n");
	if(status=~"[12][0-9][0-9]")
		route(NATMANAGE);
}
 
# manage failure routing cases
failure_route[MANAGE_FAILURE] {
	route(NATMANAGE);
 
	if (t_is_canceled()) {
		exit;
	}
 
#!ifdef WITH_BLOCK3XX
	# block call redirect based on 3xx replies.
	if (t_check_status("3[0-9][0-9]")) {
		t_reply("404","Not found");
		exit;
	}
#!endif
 
#!ifdef WITH_VOICEMAIL
	# serial forking
	# - route to voicemail on busy or no answer (timeout)
	if (t_check_status("486|408")) {
		route(TOVOICEMAIL);
		exit;
	}
#!endif
}
 
#!ifdef WITH_ASTERISK
# Test if coming from Asterisk
route[FROMASTERISK] {
	if(\$si==\$sel(cfg_get.asterisk.bindip)
			&& \$sp==\$sel(cfg_get.asterisk.bindport))
		return 1;
	return -1;
}
 
# Send to Asterisk
route[TOASTERISK] {
	\$du = "sip:" + \$sel(cfg_get.asterisk.bindip) + ":"
			+ \$sel(cfg_get.asterisk.bindport);
	route(RELAY);
	exit;
}
 
# Forward REGISTER to Asterisk
route[REGFWD] {
	if(!is_method("REGISTER"))
	{
		return;
	}
	\$var(rip) = \$sel(cfg_get.asterisk.bindip);
	\$uac_req(method)="REGISTER";
	\$uac_req(ruri)="sip:" + \$var(rip) + ":" + \$sel(cfg_get.asterisk.bindport);
	\$uac_req(furi)="sip:" + \$au + "@" + \$var(rip);
	\$uac_req(turi)="sip:" + \$au + "@" + \$var(rip);
	\$uac_req(hdrs)="Contact: <sip:" + \$au + "@"
				+ \$sel(cfg_get.kamailio.bindip)
				+ ":" + \$sel(cfg_get.kamailio.bindport) + ">\r\n";
	if(\$sel(contact.expires) != \$null)
		\$uac_req(hdrs)= \$uac_req(hdrs) + "Expires: " + \$sel(contact.expires) + "\r\n";
	else
		\$uac_req(hdrs)= \$uac_req(hdrs) + "Expires: " + \$hdr(Expires) + "\r\n";
	uac_req_send();
}
#!endif
EOF

/etc/init.d/asterisk restart
/etc/init.d/kamailio restart

echo "********************** FIN ***********************"

#INSERT INTO sipusers (name, username, host, sippasswd, fromuser, fromdomain, mailbox)
#  VALUES ('101', '101', 'dynamic', '101', '101', 'yoursip.com', '101');
#INSERT INTO sipusers (name, username, host, sippasswd, fromuser, fromdomain, mailbox)
#  VALUES ('102', '102', 'dynamic', '102', '102', 'yoursip.com', '102');
#INSERT INTO sipusers (name, username, host, sippasswd, fromuser, fromdomain, mailbox)
#  VALUES ('103', '103', 'dynamic', '103', '103', 'yoursip.com', '103');
 
#INSERT INTO sipregs(name) VALUES('101');
#INSERT INTO sipregs(name) VALUES('102');
#INSERT INTO sipregs(name) VALUES('103');
 
#INSERT INTO voiceboxes(customer_id, context, mailbox, password) VALUES ('101', 'default', '101', '1234');
#INSERT INTO voiceboxes(customer_id, context, mailbox, password) VALUES ('101', 'default', '102', '1234');
#INSERT INTO voiceboxes(customer_id, context, mailbox, password) VALUES ('101', 'default', '103', '1234');
