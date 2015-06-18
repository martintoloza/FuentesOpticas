DELIMITER $$

DROP PROCEDURE IF EXISTS `ventasinv`.`sp_lotes`$$

CREATE PROCEDURE `ventasinv`.`sp_lotes`(IN nEmp INT(2), IN sCodigo CHAR(12), IN sLote CHAR(20),
                                        IN dFecha DATE, IN nCantid INT(5), IN nMov INT(2))
BEGIN
  DECLARE existe BOOL DEFAULT 0;
  DECLARE nSaldo INT  DEFAULT nCantid;

  if LEFT( sCodigo,2 ) >= "60" AND !EMPTY( sLote ) then
     -- 0 Entrada, 1 Reversar Entrada
     -- 2 Salida , 3 Reversar Salida
    if nMov = 1 OR nMov = 2 then
       SET nCantid = nCantid * -1;
       SET nSaldo  = nCantid;
    end if;

     if nMov >= 2 then
        SET nCantid = 0;
     end if;

	   SELECT COUNT(1) > 0 INTO existe FROM lotes
     WHERE optica = nEmp
       AND codigo = sCodigo
       AND lote   = sLote;

     if existe = 0 AND nMov = 0 then
	      INSERT INTO lotes (optica, codigo, lote, fechav, cantidad, existencia)
        VALUES (nEmp, sCodigo, sLote, dFecha, 0, 0);
     end if;

     UPDATE lotes SET cantidad   = cantidad   + nCantid,
                      existencia = existencia + nSaldo
     WHERE optica = nEmp
       AND codigo = sCodigo
       AND lote   = sLote;
  end if;
END$$
--call sp_lotes(4, '6540101000', '235015467', '2012-12-31', 6, 2);
DROP TRIGGER `ventasinv`.`t_cadartid`$$

CREATE TRIGGER `ventasinv`.`t_cadartid`
       BEFORE UPDATE OR DELETE OR INSERT ON `ventasinv`.`cadartid`
FOR EACH ROW BEGIN
  DECLARE nOptica INT;

  SELECT optica INTO nOptica FROM comprasc
  WHERE ingreso = new.ingreso;

  if inserting then
     call sp_lotes(nOptica, new.codigo, new.lote, new.fechav, new.cantidad, 0);
  end if;
  if updating then
     call sp_lotes(nOptica, old.codigo, old.lote, old.fechav, old.cantidad, 1);
     if old.codigo <> new.codigo OR old.lote <> new.lote then
        UPDATE lotes SET codigo = new.codigo,
                         lote   = new.lote
        WHERE optica = nOptica
          AND codigo = old.codigo
          AND lote   = old.lote
          AND cantidad = 0;
     end if;
     call sp_lotes(nOptica, new.codigo, new.lote, new.fechav, new.cantidad, 0);
  end if;
  if deleting then
     call sp_lotes(nOptica, old.codigo, old.lote, old.fechav, old.cantidad, 1);
  end if;

END$$