-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ad_mgmt
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema ad_mgmt
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ad_mgmt` DEFAULT CHARACTER SET utf8 ;
USE `ad_mgmt` ;

-- -----------------------------------------------------
-- Table `ad_mgmt`.`teams`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`teams` (
  `team_id` INT NOT NULL,
  `team_name` VARCHAR(45) NULL,
  PRIMARY KEY (`team_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`employees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`employees` (
  `employee_id` INT NOT NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `address` VARCHAR(45) NULL,
  `title` VARCHAR(45) NULL,
  `salary` INT NULL,
  `start_date` DATE NULL,
  `end_date` DATE NULL,
  `team_id` INT NOT NULL,
  PRIMARY KEY (`employee_id`),
  INDEX `fk_employees_teams1_idx` (`team_id` ASC) VISIBLE,
  CONSTRAINT `fk_employees_teams1`
    FOREIGN KEY (`team_id`)
    REFERENCES `ad_mgmt`.`teams` (`team_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`personas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`personas` (
  `persona_id` VARCHAR(10) NOT NULL,
  `persona_name` VARCHAR(30) NULL,
  `persona_description` VARCHAR(500) NULL,
  PRIMARY KEY (`persona_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`product_service`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`product_service` (
  `ps_id` VARCHAR(10) NOT NULL,
  `ps_name` VARCHAR(45) NULL,
  `ps_description` VARCHAR(250) NULL,
  `contact_person` VARCHAR(60) NULL,
  PRIMARY KEY (`ps_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`status_catalog`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`status_catalog` (
  `status_id` INT NOT NULL,
  `status_name` VARCHAR(45) NULL,
  PRIMARY KEY (`status_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`campaigns`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`campaigns` (
  `campaign_id` INT NOT NULL,
  `employee_id` INT NOT NULL,
  `ps_id` VARCHAR(10) NOT NULL,
  `status_id` INT NOT NULL,
  `description` VARCHAR(250) NULL,
  `planned_budget` INT NULL,
  `planned_start_date` DATE NULL,
  `planned_end_date` DATE NULL,
  `start_date` DATE NULL,
  `end_date` DATE NULL,
  PRIMARY KEY (`campaign_id`, `employee_id`, `ps_id`, `status_id`),
  INDEX `fk_campaigns_employees1_idx` (`employee_id` ASC) VISIBLE,
  INDEX `fk_campaigns_product_service2_idx` (`ps_id` ASC) VISIBLE,
  INDEX `fk_campaigns_status_catalog1_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_campaigns_employees1`
    FOREIGN KEY (`employee_id`)
    REFERENCES `ad_mgmt`.`employees` (`employee_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_campaigns_product_service2`
    FOREIGN KEY (`ps_id`)
    REFERENCES `ad_mgmt`.`product_service` (`ps_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_campaigns_status_catalog1`
    FOREIGN KEY (`status_id`)
    REFERENCES `ad_mgmt`.`status_catalog` (`status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`platforms`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`platforms` (
  `platform_id` VARCHAR(10) NOT NULL,
  `platform_name` VARCHAR(45) NULL,
  `is_digital` INT NULL,
  PRIMARY KEY (`platform_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`ads`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`ads` (
  `ad_id` INT NOT NULL,
  `campaign_id` INT NOT NULL,
  `platform_id` VARCHAR(10) NOT NULL,
  `persona_id` VARCHAR(10) NOT NULL,
  `planned_start_date` DATE NULL,
  `planned_end_date` DATE NULL,
  `start_date` DATE NULL,
  `end_date` DATE NULL,
  `details` VARCHAR(250) NULL,
  `cost` INT NULL,
  PRIMARY KEY (`ad_id`, `campaign_id`, `platform_id`, `persona_id`),
  INDEX `fk_ads_campaigns1_idx` (`campaign_id` ASC) VISIBLE,
  INDEX `fk_ads_platforms1_idx` (`platform_id` ASC) VISIBLE,
  INDEX `fk_ads_personas1_idx` (`persona_id` ASC) VISIBLE,
  CONSTRAINT `fk_ads_campaigns1`
    FOREIGN KEY (`campaign_id`)
    REFERENCES `ad_mgmt`.`campaigns` (`campaign_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ads_platforms1`
    FOREIGN KEY (`platform_id`)
    REFERENCES `ad_mgmt`.`platforms` (`platform_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ads_personas1`
    FOREIGN KEY (`persona_id`)
    REFERENCES `ad_mgmt`.`personas` (`persona_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`linkedin_metrics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`linkedin_metrics` (
  `ad_id` INT NOT NULL,
  `update_title` VARCHAR(45) NULL,
  `update_link` VARCHAR(100) NULL,
  `impressions` INT NULL,
  `video_views` INT NULL,
  `clicks` INT NULL,
  `click_through_rate` FLOAT NULL,
  `likes` INT NULL,
  `comments` INT NULL,
  `shares` INT NULL,
  `follows` INT NULL,
  `engagement_rate` FLOAT NULL,
  PRIMARY KEY (`ad_id`),
  INDEX `fk_linkedin_metrics_ads1_idx` (`ad_id` ASC) VISIBLE,
  CONSTRAINT `fk_linkedin_metrics_ads1`
    FOREIGN KEY (`ad_id`)
    REFERENCES `ad_mgmt`.`ads` (`ad_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`facebook_metrics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`facebook_metrics` (
  `ad_id` INT NOT NULL,
  `permalink` VARCHAR(100) NULL,
  `post_message` VARCHAR(250) NULL,
  `type` VARCHAR(50) NULL,
  `lifetime_post_total_reach` INT NULL,
  `lifetime_post_organic_reach` INT NULL,
  `lifetime_post_paid_reach` INT NULL,
  `lifetime_post_total_impressions` INT NULL,
  `lifetime_post_organic_impressions` INT NULL,
  `lifetime_post_paid_impressions` INT NULL,
  `lifetime_engaged_users` INT NULL,
  PRIMARY KEY (`ad_id`),
  INDEX `fk_facebook_metrics_ads1_idx` (`ad_id` ASC) VISIBLE,
  CONSTRAINT `fk_facebook_metrics_ads1`
    FOREIGN KEY (`ad_id`)
    REFERENCES `ad_mgmt`.`ads` (`ad_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ad_mgmt`.`status_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ad_mgmt`.`status_history` (
  `history_id` INT NOT NULL AUTO_INCREMENT,
  `campaign_id` INT NOT NULL,
  `employee_id` INT NOT NULL,
  `prev_status_id` INT NOT NULL,
  `update_time` DATETIME NULL,
  `details` VARCHAR(200) NULL,
  PRIMARY KEY (`history_id`, `prev_status_id`),
  INDEX `fk_status_history_status_catalog1_idx` (`prev_status_id` ASC) VISIBLE,
  INDEX `fk_status_history_campaigns1_idx` (`campaign_id` ASC) VISIBLE,
  INDEX `fk_status_history_employees1_idx` (`employee_id` ASC) VISIBLE,
  CONSTRAINT `fk_status_history_status_catalog1`
    FOREIGN KEY (`prev_status_id`)
    REFERENCES `ad_mgmt`.`status_catalog` (`status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_status_history_campaigns1`
    FOREIGN KEY (`campaign_id`)
    REFERENCES `ad_mgmt`.`campaigns` (`campaign_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_status_history_employees1`
    FOREIGN KEY (`employee_id`)
    REFERENCES `ad_mgmt`.`employees` (`employee_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- ------------------
-- Insert Data
-- ------------------

-- Platforms Table
INSERT INTO platforms
(platform_id, platform_name, is_digital)
VALUES
("FB","Facebook",1),
("LI","LinkedIn",1),
("NP","Newspaper",0),
("RD","Radio",0),
("TV","Television",0);

-- Teams Table
INSERT INTO teams
(team_id, team_name)
VALUES
(1,"Content"),
(2,"Social Media"),
(3,"Paid Media");

-- Employees Table
INSERT INTO employees
(employee_id, first_name, last_name, address, title, salary, start_date, end_date, team_id)
VALUES
(1,"Hermione","Granger","The Burrow","Charms Tutor",100000,"2018-02-14",NULL,1),
(2,"Harry","Potter","Hogwarts","Lord",400000,"2018-02-14",NULL,2),
(3,"Ron","Weasley","Little Hangleton","Quidditch Captin",50000,"2021-02-14",NULL,3),
(4,"Draco","Malfoy","Malfoy Manor","Snake",250000,"2020-02-14",NULL,1),
(5,"Lord","Voldemort","Little Whinging","Dark Lord",400000,"2015-05-23",NULL,2),
(6,"Bellatrix","Lestrange","Godric's Hollow","Senior Warlock",100000,"2017-06-08",NULL,3),
(7,"Sirius","Black","Spinner's End","Godparent",300000,"2015-06-09","2021-03-01",1),
(8,"Ginny","Weasly","Shell Cottage","Deputy Headmaster",50000,"2015-09-10",NULL,2),
(9,"Lucius","Malfoy","Malfoy Manor","Director of Magical Secuirity",100000,"2016-12-25",NULL,3),
(10,"Cho","Chang","Hogsmeade Station","Master of Death",125000,"2019-04-12",NULL,1);

-- Personas Table
INSERT INTO personas
(persona_id, persona_name, persona_description)
VALUES
("AA","Attentive Andy","Interested in occupation related content"),
("BC","Bored Charlie","Interested in funny content"),
("MM","Mother Mandy","Interested in familial content"),
("BB","Busy Bob","Interested in news");

-- Product / Service Table
INSERT INTO product_service
(ps_id, ps_name, ps_description, contact_person)
VALUES
("P1","cool_thing","A cool product that we are selling and we really want to push it. ","Jack, Black"),
("S1","service_helpful ","We have this new service people will think is helpful. ","Thomas, Nussman"),
("P2","helpful_solution ","This solution will solve our customers efficiency constraints.","Sarah, Tod"),
("P3","original_product","Our original product we became famous for. ","Jack, Black"),
("S2","service_new","A brand new service we have in our portfolio. ","Thomas, Nussman");

-- Status Catalog Table
INSERT INTO status_catalog
(status_id, status_name)
VALUES
(1,"In Process"),
(2,"On Hold"),
(3,"Overtime"),
(4,"Cancelled"),
(5,"Complete");

-- Campaign Table
INSERT INTO campaigns
(campaign_id,employee_id,description,status_id,planned_budget,
planned_start_date,planned_end_date,start_date,end_date,ps_id)
VALUES
(123,2,"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut metus diam. Morbi sollicitudin elit sit amet sapien blandit vestibulum.",1,1000,"2021-02-27","2021-03-27","2021-02-27",NULL,"P1"),
(456,6,"Sed imperdiet euismod libero, nec tincidunt leo placerat quis. Vestibulum interdum magna nulla, non semper turpis porta at. Cras ultricies nulla ut enim pulvinar, ut luctus quam tincidunt.",2,1500,"2021-04-20","2021-05-20",NULL,NULL,"P1"),
(986,1,"Duis varius dui enim. Nullam vulputate gravida ligula, vitae mattis erat ornare quis. ",5,1000,"2021-02-14","2021-03-02","2021-02-14","2021-03-02","S1"),
(524,2,"Suspendisse ut condimentum risus. Fusce magna neque, feugiat at ligula tincidunt, elementum suscipit odio. ",1,19000,"2021-01-20","2021-02-20","2021-01-25",NULL,"P2"),
(219,7,"Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed mollis eu est at posuere.",4,3000,"2021-02-11","2021-03-13","2021-02-11","2021-02-28","P3"),
(94,8,"Fusce accumsan tortor nunc, ac porttitor odio molestie non. Pellentesque vehicula risus sapien, sed iaculis nunc imperdiet ut",2,2500,"2021-03-02","2021-04-10",NULL,NULL,"S2"),
(498,4,"Aenean ullamcorper, metus sed ultrices consectetur, orci purus rhoncus magna, nec semper purus mauris sit amet purus.",4,1000,"2021-01-10","2021-03-10","2021-01-12","2021-01-23","P3"),
(157,5,"Nunc auctor nec magna id tempus. Cras tempor iaculis lectus, id cursus nisl cursus eu. Integer sed lorem tincidunt, egestas enim eget, dapibus est.",3,3000,"2021-02-23","2021-03-10","2021-02-24",NULL,"S1"),
(852,10,"Donec vitae nisl ac orci luctus tincidunt non quis ante. Donec aliquam nulla mauris, ut sagittis nisl venenatis vel. Sed sodales sem vel purus eleifend, ut sollicitudin massa pretium.",1,17500,"2021-02-10","2021-03-15","2021-02-10",NULL,"S2");

-- Status History Table
INSERT INTO status_history
(history_id,campaign_id,employee_id,prev_status_id,update_time,details)
VALUES
(1,456,10,1,"2021-02-27 00:51:21","Change from in progress to hold "),
(2,986,10,1,"2021-02-10 10:23:44","Placed on hold due to human resource contraints"),
(3,986,5,2,"2021-02-12 12:55:45","Placed on in progress after being delayed "),
(4,986,3,1,"2021-03-02 07:10:20","Changed to complete, as it is done "),
(5,219,3,1,"2021-02-27 15:03:06","Campaign was cancelled due to product issue "),
(6,94,9,1,"2021-03-08 10:05:12","Change to on hold as focus for campagain ran into issues "),
(7,498,9,1,"2021-01-23 09:10:22","Campaign was cancelled due to logistical issues"),
(8,157,8,1,"2021-03-10 15:27:01","Campaign is on-going past the planned end date");

-- Ads Table
INSERT INTO ads
(ad_id,persona_id,platform_id,campaign_id,planned_start_date,
planned_end_date,start_date,end_date,details,cost)
VALUES
(9854,"AA","FB",123,"2021-02-27","2021-03-13","2021-02-27","2021-03-13","Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut metus diam. Morbi sollicitudin elit sit amet sapien blandit vestibulum.",200),
(9738,"BB","FB",524,"2021-01-20","2021-02-03","2021-01-25","2021-02-08","Sed imperdiet euismod libero, nec tincidunt leo placerat quis. Vestibulum interdum magna nulla, non semper turpis porta at. Cras ultricies nulla ut enim pulvinar, ut luctus quam tincidunt.",100),
(9123,"MM","FB",986,"2021-02-14","2021-03-02","2021-02-14","2021-03-02","Duis varius dui enim. Nullam vulputate gravida ligula, vitae mattis erat ornare quis. ",400),
(9548,"BB","FB",524,"2021-02-08","2021-02-20","2021-03-06",NULL,"Suspendisse ut condimentum risus. Fusce magna neque, feugiat at ligula tincidunt, elementum suscipit odio. ",300),
(9328,"BB","FB",219,"2021-02-11","2021-02-25","2021-02-11","2021-02-25","Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed mollis eu est at posuere.",600),
(8743,"AA","FB",219,"2021-02-25","2021-03-11","2021-02-25","2021-02-28","Fusce accumsan tortor nunc, ac porttitor odio molestie non. Pellentesque vehicula risus sapien, sed iaculis nunc imperdiet ut",100),
(9874,"BC","FB",498,"2021-01-10","2021-03-10","2021-01-12","2021-01-23","Aenean ullamcorper, metus sed ultrices consectetur, orci purus rhoncus magna, nec semper purus mauris sit amet purus.",100),
(7802,"MM","FB",157,"2021-02-23","2021-03-10","2021-02-24",NULL,"Nunc auctor nec magna id tempus. Cras tempor iaculis lectus, id cursus nisl cursus eu. Integer sed lorem tincidunt, egestas enim eget, dapibus est.",1800),
(7809,"BB","FB",852,"2021-02-10","2021-03-15","2021-02-10",NULL,"Donec vitae nisl ac orci luctus tincidunt non quis ante. Donec aliquam nulla mauris, ut sagittis nisl venenatis vel. Sed sodales sem vel purus eleifend, ut sollicitudin massa pretium.",754),
(9076,"BC","FB",123,"2021-03-11","2021-03-25","2021-03-11",NULL,"Duis vitae vehicula velit. Suspendisse pellentesque, dolor vel hendrerit tincidunt, nibh risus iaculis eros, a ultrices nunc erat vitae turpis.",150),
(8793,"MM","FB",524,"2021-01-20","2021-02-03","2021-01-25","2021-02-08","Quisque euismod pretium felis, et finibus metus. Etiam hendrerit lobortis libero ac ornare.",600),
(2123,"BB","LI",123,"2021-02-27","2021-03-13","2021-02-27","2021-03-13","Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut metus diam. Morbi sollicitudin elit sit amet sapien blandit vestibulum.",100),
(2126,"AA","LI",852,"2021-02-10","2021-03-15","2021-02-28",NULL,"Sed imperdiet euismod libero, nec tincidunt leo placerat quis. Vestibulum interdum magna nulla, non semper turpis porta at. Cras ultricies nulla ut enim pulvinar, ut luctus quam tincidunt.",200),
(2128,"BC","LI",986,"2021-02-14","2021-03-02","2021-02-14","2021-03-02","Duis varius dui enim. Nullam vulputate gravida ligula, vitae mattis erat ornare quis. ",600),
(2134,"AA","LI",524,"2021-02-08","2021-02-20","2021-03-06",NULL,"Suspendisse ut condimentum risus. Fusce magna neque, feugiat at ligula tincidunt, elementum suscipit odio. ",478),
(1312,"BC","LI",219,"2021-02-11","2021-02-25","2021-02-11","2021-02-25","Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed mollis eu est at posuere.",400),
(3212,"AA","LI",219,"2021-02-25","2021-03-11","2021-02-25","2021-02-28","Fusce accumsan tortor nunc, ac porttitor odio molestie non. Pellentesque vehicula risus sapien, sed iaculis nunc imperdiet ut",500),
(3123,"BC","LI",157,"2021-02-23","2021-02-28","2021-02-24","2021-03-01","Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed mollis eu est at posuere.",102),
(3578,"AA","LI",157,"2021-02-28","2021-03-10","2021-03-01",NULL,"Fusce accumsan tortor nunc, ac porttitor odio molestie non. Pellentesque vehicula risus sapien, sed iaculis nunc imperdiet ut",356),
(3420,"BC","LI",852,"2021-02-10","2021-03-15","2021-02-10","2021-02-28","Aenean ullamcorper, metus sed ultrices consectetur, orci purus rhoncus magna, nec semper purus mauris sit amet purus.",450),
(2315,"AA","LI",123,"2021-03-11","2021-03-25","2021-03-11",NULL,"Nunc auctor nec magna id tempus. Cras tempor iaculis lectus, id cursus nisl cursus eu. Integer sed lorem tincidunt, egestas enim eget, dapibus est.",100),
(2594,"BC","LI",498,"2021-01-10","2021-03-10","2021-01-12","2021-01-23","Donec vitae nisl ac orci luctus tincidunt non quis ante. Donec aliquam nulla mauris, ut sagittis nisl venenatis vel. Sed sodales sem vel purus eleifend, ut sollicitudin massa pretium.",290),
(6534,"MM","NP",498,"2021-01-10","2021-03-10","2021-01-12","2021-01-23","Duis vitae vehicula velit. Suspendisse pellentesque, dolor vel hendrerit tincidunt, nibh risus iaculis eros, a ultrices nunc erat vitae turpis.",499),
(6578,"AA","NP",157,"2021-02-23","2021-03-01","2021-02-24",NULL,"Quisque euismod pretium felis, et finibus metus. Etiam hendrerit lobortis libero ac ornare.",1379),
(4576,"BC","RD",123,"2021-03-04","2021-03-11","2021-03-04","2021-03-11","Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut metus diam. Morbi sollicitudin elit sit amet sapien blandit vestibulum.",500),
(5747,"AA","RD",524,"2021-01-30","2021-02-06","2021-01-30","2021-02-06","Sed imperdiet euismod libero, nec tincidunt leo placerat quis. Vestibulum interdum magna nulla, non semper turpis porta at. Cras ultricies nulla ut enim pulvinar, ut luctus quam tincidunt.",900),
(7689,"BC","TV",852,"2021-02-10","2021-03-15","2021-02-10",NULL,"Duis varius dui enim. Nullam vulputate gravida ligula, vitae mattis erat ornare quis. ",10000),
(7896,"MM","TV",524,"2021-01-30","2021-02-06","2021-01-30","2021-02-06","Suspendisse ut condimentum risus. Fusce magna neque, feugiat at ligula tincidunt, elementum suscipit odio. ",10000);

-- Facebook Metrics
INSERT INTO facebook_metrics
(ad_id,permalink,post_message,type,lifetime_post_total_reach,lifetime_post_organic_reach,
lifetime_post_paid_reach,lifetime_post_total_impressions,lifetime_post_organic_impressions,
lifetime_post_paid_impressions,lifetime_engaged_users)
VALUES
(9854,"facebook.com/ourpage/posts/this","We have this awesome thing for you ","Photo / Video",12263,6622,5641,9933,4172,5761,11098),
(9738,"facebook.com/ourpage/posts/that","This is a cool product","Photo Carousel",76526,55099,21427,34437,24450,9987,55481),
(9123,"facebook.com/ourpage/posts/product","Join us ","Slideshow",31999,20799,11200,21759,11532,10227,26879),
(9548,"facebook.com/ourpage/posts/fun","Do this now ","Photo / Video",31237,25927,5310,14057,1827,12229,22647),
(9328,"facebook.com/ourpage/posts/hi","Check this out ","Photo Album",14853,9209,5644,12922,6849,6073,13888),
(8743,"facebook.com/ourpage/posts/cool","We love our customers","Slideshow",2833,227,2606,595,30,565,1714),
(9874,"facebook.com/ourpage/posts/thing","Big update","Canvas",8046,1931,6115,3057,397,2660,5552),
(7802,"facebook.com/ourpage/posts/peeps","Breaking news","Photo Album",3084,648,2436,2560,205,2355,2822),
(7809,"facebook.com/ourpage/posts/join","Amazing stuff","Photo Album",23537,4237,19300,12475,9356,3119,18006),
(9076,"facebook.com/ourpage/posts/ad","What are you wating for? ","Photo Carousel",34714,19440,15274,12497,3499,8998,23606),
(8793,"facebook.com/ourpage/posts/party","This is fun ","Canvas",57793,41033,16760,55481,34398,21083,56637);

-- LinkedIn Metrics
INSERT INTO linkedin_metrics
(ad_id,update_title,update_link,impressions,video_views,clicks,
click_through_rate,likes,comments,shares,follows,engagement_rate)
VALUES
(2123,"We have this awesome thing for you ","ourwebsite.com/this",1740,1352,654,19.74,506,411,87,139,23.22),
(2126,"This is a cool product","ourwebsite.com/that",3364,NULL,2024,73.09,2794,1016,1028,265,81.21),
(2128,"Join us ","ourwebsite.com/product",4960,NULL,1539,29.88,4438,1750,1930,334,63.57),
(2134,"Do this now ","ourwebsite.com/fun",13911,NULL,5998,62.4,4664,3605,1935,1112,65.69),
(1312,"Check this out ","ourwebsite.com/hi",43295,12862,30917,33.56,30701,29842,3569,2681,62.16),
(3212,"We love our customers","ourwebsite.com/cool",3234,745,209,0.25,2366,2168,1827,299,1.3),
(3123,"Big update","ourwebsite.com/thing",12728,NULL,9613,0.62,204,203,49,1183,10.35),
(3578,"Breaking news","ourwebsite.com/peeps",27074,NULL,16553,1.83,14263,6629,9898,615,30.46),
(3420,"Amazing stuff","ourwebsite.com/join",5160,NULL,2464,3.56,1046,159,136,263,8.08),
(2315,"What are you wating for? ","ourwebsite.com/ad",5731,NULL,3520,7.23,5537,201,1142,193,48.21),
(2594,"This is fun ","ourwebsite.com/party",69940,10345,43305,63.93,49962,40275,803,4591,77.97);

