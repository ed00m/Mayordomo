SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `curso` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `curso` ;

-- -----------------------------------------------------
-- Table `curso`.`usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `curso`.`usuarios` (
  `idusuarios` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`idusuarios`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

--------------------------------------------------------
-- data
--------------------------------------------------------
insert into curso.usuarios values (1, 'Diego');
insert into curso.usuarios values (2, 'Pablo');
insert into curso.usuarios values (3, 'Marcelo');
insert into curso.usuarios values (4, 'Joaquin');
insert into curso.usuarios values (5, 'Ricardo');
insert into curso.usuarios values (6, 'Francisco');

--------------------------------------------------------
-- users
--------------------------------------------------------

GRANT SELECT, UPDATE, INSERT, DELETE
ON curso.*
TO 'usuarios'@'localhost'
IDENTIFIED BY 'usuarios';

flush privileges;
