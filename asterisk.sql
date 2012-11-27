CREATE DATABASE asterisk;
 
USE asterisk;
 
GRANT ALL ON asterisk.* TO asterisk@localhost IDENTIFIED BY '1984as19terisk84';
 
CREATE TABLE `sipusers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `host` varchar(31) NOT NULL DEFAULT '',
  `nat` varchar(5) NOT NULL DEFAULT 'no',
  `type` enum('user','peer','friend') NOT NULL DEFAULT 'friend',
  `accountcode` varchar(20) DEFAULT NULL,
  `amaflags` varchar(13) DEFAULT NULL,
  `call-limit` smallint(5) UNSIGNED DEFAULT NULL,
  `callgroup` varchar(10) DEFAULT NULL,
  `callerid` varchar(80) DEFAULT NULL,
  `cancallforward` char(3) DEFAULT 'yes',
  `canreinvite` char(3) DEFAULT 'yes',
  `context` varchar(80) DEFAULT NULL,
  `defaultip` varchar(15) DEFAULT NULL,
  `dtmfmode` varchar(7) DEFAULT NULL,
  `fromuser` varchar(80) DEFAULT NULL,
  `fromdomain` varchar(80) DEFAULT NULL,
  `insecure` varchar(4) DEFAULT NULL,
  `language` char(2) DEFAULT NULL,
  `mailbox` varchar(50) DEFAULT NULL,
  `md5secret` varchar(80) DEFAULT NULL,
  `deny` varchar(95) DEFAULT NULL,
  `permit` varchar(95) DEFAULT NULL,
  `mask` varchar(95) DEFAULT NULL,
  `musiconhold` varchar(100) DEFAULT NULL,
  `pickupgroup` varchar(10) DEFAULT NULL,
  `qualify` char(3) DEFAULT NULL,
  `regexten` varchar(80) DEFAULT NULL,
  `restrictcid` char(3) DEFAULT NULL,
  `rtptimeout` char(3) DEFAULT NULL,
  `rtpholdtimeout` char(3) DEFAULT NULL,
  `secret` varchar(80) DEFAULT NULL,
  `setvar` varchar(100) DEFAULT NULL,
  `disallow` varchar(100) DEFAULT NULL,
  `allow` varchar(100) DEFAULT NULL,
  `fullcontact` varchar(80) NOT NULL DEFAULT '',
  `ipaddr` varchar(45) DEFAULT NULL,
  `port` mediumint(5) UNSIGNED NOT NULL DEFAULT '0',
  `regserver` varchar(100) DEFAULT NULL,
  `regseconds` int(11) NOT NULL DEFAULT '0',
  `lastms` int(11) NOT NULL DEFAULT '0',
  `username` varchar(80) NOT NULL DEFAULT '',
  `defaultuser` varchar(80) NOT NULL DEFAULT '',
  `subscribecontext` varchar(80) DEFAULT NULL,
  `useragent` varchar(20) DEFAULT NULL,
  `sippasswd` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_uk` (`name`)
);
 
 
CREATE TABLE `sipregs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `fullcontact` varchar(80) NOT NULL DEFAULT '',
  `ipaddr` varchar(45) DEFAULT NULL,
  `port` mediumint(5) UNSIGNED NOT NULL DEFAULT '0',
  `username` varchar(80) NOT NULL DEFAULT '',
  `regserver` varchar(100) DEFAULT NULL,
  `regseconds` int(11) NOT NULL DEFAULT '0',
  `defaultuser` varchar(80) NOT NULL DEFAULT '',
  `useragent` varchar(20) DEFAULT NULL,
  `lastms` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
);
 
 
CREATE TABLE `voiceboxes` (
  `uniqueid` int(4) NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(10) DEFAULT NULL,
  `context` varchar(10) NOT NULL,
  `mailbox` varchar(10) NOT NULL,
  `password` varchar(12) NOT NULL,
  `fullname` varchar(150) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `pager` varchar(50) DEFAULT NULL,
  `tz` varchar(10) DEFAULT 'central',
  `attach` enum('yes','no') NOT NULL DEFAULT 'yes',
  `saycid` enum('yes','no') NOT NULL DEFAULT 'yes',
  `dialout` varchar(10) DEFAULT NULL,
  `callback` varchar(10) DEFAULT NULL,
  `review` enum('yes','no') NOT NULL DEFAULT 'no',
  `operator` enum('yes','no') NOT NULL DEFAULT 'no',
  `envelope` enum('yes','no') NOT NULL DEFAULT 'no',
  `sayduration` enum('yes','no') NOT NULL DEFAULT 'no',
  `saydurationm` tinyint(4) NOT NULL DEFAULT '1',
  `sendvoicemail` enum('yes','no') NOT NULL DEFAULT 'no',
  `delete` enum('yes','no') DEFAULT 'no',
  `nextaftercmd` enum('yes','no') NOT NULL DEFAULT 'yes',
  `forcename` enum('yes','no') NOT NULL DEFAULT 'no',
  `forcegreetings` enum('yes','no') NOT NULL DEFAULT 'no',
  `hidefromdir` enum('yes','no') NOT NULL DEFAULT 'yes',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`uniqueid`),
  KEY `mailbox_context` (`mailbox`,`context`)
);
 
 
CREATE TABLE `voicemessages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `msgnum` int(11) NOT NULL DEFAULT '0',
  `dir` varchar(80) DEFAULT '',
  `context` varchar(80) DEFAULT '',
  `macrocontext` varchar(80) DEFAULT '',
  `callerid` varchar(40) DEFAULT '',
  `origtime` varchar(40) DEFAULT '',
  `duration` varchar(20) DEFAULT '',
  `mailboxuser` varchar(80) DEFAULT '',
  `mailboxcontext` varchar(80) DEFAULT '',
  `recording` longblob,
  `flag` varchar(128) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `dir` (`dir`)
);
