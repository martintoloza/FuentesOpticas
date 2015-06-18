DROP TABLE IF EXISTS VentasInv.cadpagos;
CREATE TABLE `cadpagos` (
  `row_id` int(11) NOT NULL auto_increment,
  `optica` int(2) default NULL,
  `numfac` int(10) default NULL,
  `tipo` char(1) default NULL,
  `fecpag` date default NULL,
  `abono` double(11,2) default NULL,
  `pagado` double(11,2) default NULL,
  `retencion` double(11,2) default NULL,
  `deduccion` double(11,2) default NULL,
  `descuento` double(11,2) default NULL,
  `numcheque` char(16) default NULL,
  `codbanco` char(2) default NULL,
  `formapago` int(1) default NULL,
  `indicador` char(1) default NULL,
  `indred` tinyint(1) NOT NULL default '0',
  `pordonde` char(1) default NULL,
  PRIMARY KEY  (`row_id`),
  KEY `Facturas` (`optica`,`numfac`,`tipo`),
  KEY `Fecha` (`optica`,`fecpag`,`numfac`),
  CONSTRAINT `0_149` FOREIGN KEY (`optica`, `numfac`, `tipo`) REFERENCES `cadfactu` (`optica`, `numfac`, `tipo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS VentasInv.cadventa;
CREATE TABLE `cadventa` (
  `row_id` int(11) NOT NULL auto_increment,
  `optica` int(2) default NULL,
  `numfac` int(10) default NULL,
  `tipo` char(1) default NULL,
  `fecfac` date default NULL,
  `codart` char(12) default NULL,
  `descri` char(40) default NULL,
  `cantidad` int(3) default NULL,
  `precioven` double(10,2) default NULL,
  `despor` double(3,2) default NULL,
  `desmon` double(10,2) default NULL,
  `montoiva` double(10,2) default NULL,
  `ppubli` double(10,2) default NULL,
  `indicador` char(1) default NULL,
  `fecdev` date default NULL,
  `pcosto` double(10,2) default NULL,
  PRIMARY KEY  (`row_id`),
  KEY `Facturas` (`optica`,`numfac`,`tipo`),
  CONSTRAINT `0_151` FOREIGN KEY (`optica`, `numfac`, `tipo`) REFERENCES `cadfactu` (`optica`, `numfac`, `tipo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

