-- MySQL dump 10.13  Distrib 5.5.25a, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: swift_development
-- ------------------------------------------------------
-- Server version	5.5.25a-1~dotdeb.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `swift_development`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `swift_development` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `swift_development`;

--
-- Table structure for table `accesses`
--

DROP TABLE IF EXISTS `accesses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accesses` (
  `read_only` tinyint(1) DEFAULT '0',
  `accessible_id` int(11) NOT NULL,
  `accessible_type` varchar(255) NOT NULL,
  `account_id` int(10) unsigned NOT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`accessible_id`,`accessible_type`,`account_id`),
  UNIQUE KEY `unique_accesses_key` (`accessible_id`,`accessible_type`),
  KEY `index_accesses_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accesses`
--

LOCK TABLES `accesses` WRITE;
/*!40000 ALTER TABLE `accesses` DISABLE KEYS */;
/*!40000 ALTER TABLE `accesses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(70) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `group_id` int(11) DEFAULT '6',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `logged_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'admin','group','admin@localhost','$2a$10$sG1P2w41TQQxv21vZCR6YOoWSuX4xGBU91VzbsTWv/rC24paKBz.m',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'designer','group','designer@localhost','$2a$10$cHhWYvttbVIlg5/FhY718OJb6t8RZhJ3Af7kifs6lT3DYzuOhqhdy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'auditor','group','auditor@localhost','$2a$10$PU2f4H75EbAlf87hEwTTD.bTzJPNAeX7UU/Hzo.U.oLWC3/W9zbLa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'editor','group','editor@localhost','$2a$10$eiKO4ObMJ8LhlA79vVzBgePy7sabRe8xM3vY.f9oKv.cZWW3fu9jq',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,'robot','group','robot@localhost','$2a$10$aO8eg1wRJV7pbxQ43xNrS.gkF206B/CCsHmlTxoLCRf79zX3Mx4/a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,'user','group','user@localhost','$2a$10$mY6GFR6PKUjjDnKP8V5MROS8wP8khzAWXa97g5G5CKLPRHE8KVZRe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(8,'Игорь Бочкарёв','','ujifgc@ya.ru',NULL,'yandex','http://openid.yandex.ru/ujifgc/',4,NULL,NULL,NULL,NULL,NULL),(9,'Igor Bochkariov','','ujifgc@gmail.com','$2a$10$wbsKtuzXf15OQ.6KXCSgXu0vSPvdWJz6AlIg8mpDTQZ6XYQ6EBUlC','google','https://www.google.com/accounts/o8/id?id=AItOawkE8RSHwhGP-DsS-XRd4G199E-eLmmZR0o',1,NULL,'2012-07-24 13:35:00',NULL,9,'2012-06-11 11:57:58');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `folder_id` int(11) DEFAULT '2',
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `file_content_type` varchar(63) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assets_created_by` (`created_by_id`),
  KEY `index_assets_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocks`
--

DROP TABLE IF EXISTS `blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `folder_id` int(10) unsigned DEFAULT NULL,
  `type` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_blocks_created_by` (`created_by_id`),
  KEY `index_blocks_updated_by` (`updated_by_id`),
  KEY `index_blocks_folder` (`folder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocks`
--

LOCK TABLES `blocks` WRITE;
/*!40000 ALTER TABLE `blocks` DISABLE KEYS */;
INSERT INTO `blocks` VALUES (4,'Текст в подвале','© 2001–2012, ООО «МИТТЕК»\r\nтел. (3412) 916-026, 916-027','copy','2012-07-01 12:45:03','2012-07-01 12:45:25',1,1,NULL,0);
/*!40000 ALTER TABLE `blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bonds`
--

DROP TABLE IF EXISTS `bonds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonds` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_model` varchar(31) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `child_model` varchar(31) DEFAULT NULL,
  `child_id` int(11) DEFAULT NULL,
  `relation` int(11) DEFAULT '1',
  `manual` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bonds`
--

LOCK TABLES `bonds` WRITE;
/*!40000 ALTER TABLE `bonds` DISABLE KEYS */;
INSERT INTO `bonds` VALUES (10,'2012-03-23 17:43:09','2012-03-23 17:43:09','Page',63,'Folder',5,1,1),(15,'2012-04-01 15:08:33','2012-04-01 15:08:33','Page',66,'CatCard',1,1,1),(17,'2012-07-24 11:00:56','2012-07-24 11:00:56','Page',35,'FormsCard',2,1,1),(18,'2012-07-24 11:00:56','2012-07-24 11:00:56','Page',35,'FormsCard',4,1,1);
/*!40000 ALTER TABLE `bonds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cat_cards`
--

DROP TABLE IF EXISTS `cat_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cat_cards` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `json` text,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cat_cards_slug` (`slug`),
  KEY `index_cat_cards_created_by` (`created_by_id`),
  KEY `index_cat_cards_updated_by` (`updated_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cat_cards`
--

LOCK TABLES `cat_cards` WRITE;
/*!40000 ALTER TABLE `cat_cards` DISABLE KEYS */;
INSERT INTO `cat_cards` VALUES (2,'Ghjdthrf','','ghjdthrf','2012-07-18 13:54:02','2012-07-18 13:54:02','{\"qw\":[\"select\",\"re\\r\\nfd\\r\\ngf\"],\"we\":[\"multiple\",\"uy\\r\\niu\\r\\noi\"],\"re\":[\"number\",\"\"]}',1,1);
/*!40000 ALTER TABLE `cat_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cat_groups`
--

DROP TABLE IF EXISTS `cat_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cat_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `publish_at` datetime DEFAULT NULL,
  `json` text,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `cat_card_id` int(10) unsigned NOT NULL,
  `path` varchar(2000) DEFAULT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cat_groups_slug` (`slug`),
  KEY `index_cat_groups_created_by` (`created_by_id`),
  KEY `index_cat_groups_updated_by` (`updated_by_id`),
  KEY `index_cat_groups_cat_card` (`cat_card_id`),
  KEY `index_cat_groups_path` (`path`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cat_groups`
--

LOCK TABLES `cat_groups` WRITE;
/*!40000 ALTER TABLE `cat_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `cat_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cat_nodes`
--

DROP TABLE IF EXISTS `cat_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cat_nodes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `publish_at` datetime DEFAULT NULL,
  `json` text,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `cat_card_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cat_nodes_slug` (`slug`),
  KEY `index_cat_nodes_created_by` (`created_by_id`),
  KEY `index_cat_nodes_updated_by` (`updated_by_id`),
  KEY `index_cat_nodes_cat_card` (`cat_card_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cat_nodes`
--

LOCK TABLES `cat_nodes` WRITE;
/*!40000 ALTER TABLE `cat_nodes` DISABLE KEYS */;
INSERT INTO `cat_nodes` VALUES (10,'gcsfsd','','gcsfsd','2012-07-18 13:54:12','2012-07-18 13:54:12',0,NULL,'{}',1,1,2);
/*!40000 ALTER TABLE `cat_nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `codes`
--

DROP TABLE IF EXISTS `codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `html` text,
  `is_single` tinyint(1) DEFAULT '0',
  `slug` varchar(255) DEFAULT NULL,
  `is_system` tinyint(1) DEFAULT '0',
  `icon` varchar(255) DEFAULT NULL,
  `placeholder` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_codes_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `codes`
--

LOCK TABLES `codes` WRITE;
/*!40000 ALTER TABLE `codes` DISABLE KEYS */;
INSERT INTO `codes` VALUES (1,'Видеоролик YouTube','Вставляет проигрыватель Ютуба','<iframe width=\"[2:640]\" height=\"[3:480]\" src=\"http://www.youtube.com/embed/[1]\" frameborder=\"0\" allowfullscreen></iframe>',1,'youtube',0,NULL,'Код_видео'),(2,'Внимание','Блок с подложкой и текстом','<div class=\"alert alert-info\"><h4>[1]</h4>[content]</div>',0,'alert',0,NULL,'\"Заголовок\"'),(3,'Верхний индекс','','<sup>[content]</sup>',0,'sup',0,NULL,NULL),(4,'Нижний индекс','','<sub>[content]</sub>',0,'sub',0,NULL,NULL),(5,'Выравнивание по правому краю','','<div class=\"right\">[content]</div>',0,'right',0,NULL,'');
/*!40000 ALTER TABLE `codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `account_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_folders_created_by` (`created_by_id`),
  KEY `index_folders_updated_by` (`updated_by_id`),
  KEY `index_folders_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders`
--

LOCK TABLES `folders` WRITE;
/*!40000 ALTER TABLE `folders` DISABLE KEYS */;
INSERT INTO `folders` VALUES (1,'Layout graphics','2012-02-24 14:47:35','2012-02-24 14:47:35','images',NULL,NULL,NULL),(2,'Common files','2012-02-24 14:47:35','2012-02-24 14:47:35','files',NULL,NULL,NULL),(7,'Успехи и достижения','2012-07-01 14:10:25','2012-07-01 14:33:25','awards',NULL,1,1);
/*!40000 ALTER TABLE `folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forms_cards`
--

DROP TABLE IF EXISTS `forms_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forms_cards` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `json` text,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `kind` varchar(10) DEFAULT 'form',
  `is_published` tinyint(1) DEFAULT '0',
  `publish_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_forms_cards_slug` (`slug`),
  KEY `index_forms_cards_created_by` (`created_by_id`),
  KEY `index_forms_cards_updated_by` (`updated_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forms_cards`
--

LOCK TABLES `forms_cards` WRITE;
/*!40000 ALTER TABLE `forms_cards` DISABLE KEYS */;
INSERT INTO `forms_cards` VALUES (1,'Какими поисковиками вы пользуетесь?','Давно выяснено, что при оценке дизайна и композиции читаемый текст мешает сосредоточиться. **Lorem Ipsum** используют потому, что тот обеспечивает более или менее стандартное заполнение шаблона, а также реальное распределение букв и пробелов в абзацах, которое не получается при простой дубликации \"Здесь ваш текст.. Здесь ваш текст.. Здесь ваш текст..\" Многие программы электронной вёрстки и редакторы HTML используют **Lorem Ipsum** в качестве текста по умолчанию, так что поиск по ключевым словам \"lorem ipsum\" сразу показывает, как много веб-страниц всё ещё дожидаются своего настоящего рождения. За прошедшие годы текст **Lorem Ipsum** получил *много* версий. Некоторые версии появились по ошибке, некоторые - намеренно (например, *юмористические* варианты).','test-form','2012-07-15 12:29:00','2012-07-15 12:43:06','{\"Ваше имя\":[\"string\",\"\"],\"Ваш возраст\":[\"number\",\"\"],\"Ваш пол\":[\"select\",\"женский\\r\\nсредний\\r\\nмужской\"],\"Поисковики\":[\"multiple\",\"Гугл\\r\\nЯндекс\\r\\nБинг\\r\\nРамблер\"],\"Файл\":[\"assets\",\"\"],\"Фото\":[\"images\",\"\"]}',1,1,'form',1,'2012-07-15 12:43:06'),(2,'Какого цвета ёлка?','Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.','elka','2012-07-20 10:32:51','2012-07-24 10:11:59','{\"Какого цвета ёлка?\":[\"select\",\"зелёного\\r\\nкрасного\\r\\nсинего\\r\\nчёрного\"]}',1,1,'inquiry',1,'2012-07-20 10:36:06'),(3,'Исследование количества конечностей','The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from \"de Finibus Bonorum et Malorum\" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.','limbs','2012-07-23 11:24:37','2012-07-23 11:55:53','{\"Руки\":[\"number\",\"\"],\"Ноги\":[\"select\",\"одна\\r\\nдве\\r\\nтри\"],\"Голова\":[\"multiple\",\"одна\\r\\nдве\\r\\nс половиной\"]}',1,1,'form',1,'2012-07-23 11:24:41'),(4,'Сколько дней в году?','','year','2012-07-24 11:00:45','2012-07-24 11:01:49','{\"Сколько дней в году?\":[\"multiple\",\"365\\r\\n366\\r\\nс половиной\\r\\nс четвертью\\r\\n\"]}',1,1,'inquiry',1,'2012-07-24 11:01:49');
/*!40000 ALTER TABLE `forms_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forms_results`
--

DROP TABLE IF EXISTS `forms_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forms_results` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `json` text,
  `forms_card_id` int(10) unsigned NOT NULL,
  `origin` varchar(31) DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_forms_results_forms_card` (`forms_card_id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forms_results`
--

LOCK TABLES `forms_results` WRITE;
/*!40000 ALTER TABLE `forms_results` DISABLE KEYS */;
INSERT INTO `forms_results` VALUES (60,'2012-07-24 10:33:06','{\"Какого цвета ёлка?\":\"красного\"}',2,'10.0.0.1',NULL),(61,'2012-07-24 11:01:04','{\"Сколько дней в году?\":[\"366\",\"с четвертью\"]}',4,'10.0.0.1',NULL),(62,'2012-07-24 11:08:06','{\"Руки\":\"9\",\"Ноги\":\"одна\",\"Голова\":[\"две\"]}',3,'10.0.0.1',NULL),(63,'2012-07-25 10:55:42','{\"Какого цвета ёлка?\":\"красного\"}',2,'10.0.0.1',NULL),(64,'2012-07-25 10:55:44','{\"Какого цвета ёлка?\":\"зелёного\"}',2,'10.0.0.1',NULL),(65,'2012-07-25 10:55:45','{\"Какого цвета ёлка?\":\"красного\"}',2,'10.0.0.1',NULL),(66,'2012-07-25 10:55:47','{\"Какого цвета ёлка?\":\"красного\"}',2,'10.0.0.1',NULL),(67,'2012-07-25 10:55:48','{\"Какого цвета ёлка?\":\"чёрного\"}',2,'10.0.0.1',NULL),(68,'2012-07-25 10:55:49','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(69,'2012-07-25 10:55:50','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(70,'2012-07-25 10:55:51','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(71,'2012-07-25 10:55:52','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(72,'2012-07-25 10:55:53','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(73,'2012-07-25 10:55:54','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(74,'2012-07-25 10:55:55','{\"Какого цвета ёлка?\":\"зелёного\"}',2,'10.0.0.1',NULL),(75,'2012-07-25 10:55:57','{\"Какого цвета ёлка?\":\"красного\"}',2,'10.0.0.1',NULL),(76,'2012-07-25 10:55:58','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(77,'2012-07-25 10:55:59','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(78,'2012-07-25 10:56:00','{\"Какого цвета ёлка?\":\"синего\"}',2,'10.0.0.1',NULL),(79,'2012-07-25 10:56:04','{\"Сколько дней в году?\":[\"366\",\"с четвертью\"]}',4,'10.0.0.1',NULL),(80,'2012-07-25 10:56:05','{\"Сколько дней в году?\":[\"с половиной\"]}',4,'10.0.0.1',NULL),(81,'2012-07-25 10:56:06','{\"Сколько дней в году?\":[\"365\",\"с половиной\"]}',4,'10.0.0.1',NULL),(82,'2012-07-25 10:56:08','{\"Сколько дней в году?\":[\"365\",\"366\"]}',4,'10.0.0.1',NULL),(83,'2012-07-25 10:56:10','{\"Сколько дней в году?\":[\"с половиной\",\"с четвертью\"]}',4,'10.0.0.1',NULL),(84,'2012-07-25 10:56:12','{\"Сколько дней в году?\":[\"365\",\"366\",\"с половиной\",\"с четвертью\"]}',4,'10.0.0.1',NULL),(85,'2012-07-25 10:56:13','{\"Сколько дней в году?\":[\"366\",\"с половиной\"]}',4,'10.0.0.1',NULL);
/*!40000 ALTER TABLE `forms_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fragments`
--

DROP TABLE IF EXISTS `fragments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fragments` (
  `title` varchar(255) DEFAULT NULL,
  `is_fragment` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `id` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fragments_created_by` (`created_by_id`),
  KEY `index_fragments_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fragments`
--

LOCK TABLES `fragments` WRITE;
/*!40000 ALTER TABLE `fragments` DISABLE KEYS */;
INSERT INTO `fragments` VALUES ('Каталог',0,'2012-04-01 13:58:54','2012-04-02 14:40:20',1,1,'catalogue'),('Footer',1,'2012-02-24 14:47:35','2012-07-23 13:13:00',NULL,1,'footer'),('Опросы',0,'2012-07-15 12:39:03','2012-07-15 12:55:21',NULL,1,'forms'),('Фотогалерея',0,'2012-03-21 15:49:55','2012-03-28 12:33:14',1,1,'gallery'),('Header',1,'2012-02-24 14:47:35','2012-07-23 13:11:57',NULL,1,'header'),('Главная',0,'2012-03-20 16:32:20','2012-07-23 13:11:01',1,1,'index'),('inquiries',0,'2012-07-23 11:25:37','2012-07-23 12:14:56',NULL,1,'inquiries'),('Новости',0,'2012-03-27 02:20:53','2012-04-01 15:22:49',1,1,'news'),('Обычная страница',0,'2012-02-24 14:47:35','2012-07-01 13:15:42',NULL,1,'page');
/*!40000 ALTER TABLE `fragments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `folder_id` int(11) DEFAULT '1',
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `file_content_type` varchar(63) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_created_by` (`created_by_id`),
  KEY `index_images_updated_by` (`updated_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES (103,'Контент 2001: Земля надымская','120701141203_1112199394.jpg','2012-07-01 14:12:03','2012-07-01 14:14:02',7,NULL,1,'image/jpeg',68359),(104,'Мир ПК','120701141203_1112199395.jpg','2012-07-01 14:12:03','2012-07-01 14:13:25',7,NULL,1,'image/jpeg',51682),(105,'Контент 2001: Герменевтика','120701141203_1112199396.jpg','2012-07-01 14:12:03','2012-07-01 14:13:51',7,NULL,1,'image/jpeg',72670),(106,'Контент 2000: Чепецкий механический завод','120701141203_1112199397.jpg','2012-07-01 14:12:03','2012-07-01 14:14:20',7,NULL,1,'image/jpeg',79197),(107,'Контент 2000: Калашников','120701141203_1112199398.jpg','2012-07-01 14:12:03','2012-07-01 14:14:35',7,NULL,1,'image/jpeg',80282),(108,'Диплом: Нефть','120701141204_1112199403.jpg','2012-07-01 14:12:04','2012-07-01 14:15:01',7,NULL,1,'image/jpeg',78445),(109,'Экспо \'98','120701141204_1112199404.jpg','2012-07-01 14:12:04','2012-07-01 14:15:35',7,NULL,1,'image/jpeg',75783),(110,'Сайт 2003','120701141204_1112199405.jpg','2012-07-01 14:12:04','2012-07-01 14:15:57',7,NULL,1,'image/jpeg',69976),(111,'Видеотрансляция nadymregion.ru','120701141204_1249286868.jpg','2012-07-01 14:12:04','2012-07-01 14:16:37',7,NULL,1,'image/jpeg',109622),(112,'Живой голос истории','120701141204_1249286882.png','2012-07-01 14:12:04','2012-07-01 14:16:52',7,NULL,1,'image/png',655082),(113,'Лучший сайт городского поселения','120701141204_1249309145.jpg','2012-07-01 14:12:04','2012-07-01 14:17:08',7,NULL,1,'image/jpeg',877041);
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `layouts`
--

DROP TABLE IF EXISTS `layouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `layouts` (
  `title` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `id` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_layouts_created_by` (`created_by_id`),
  KEY `index_layouts_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `layouts`
--

LOCK TABLES `layouts` WRITE;
/*!40000 ALTER TABLE `layouts` DISABLE KEYS */;
INSERT INTO `layouts` VALUES ('Default app','2012-02-24 14:47:35','2012-03-21 14:38:01',NULL,1,'application'),('Raw data','2012-02-24 14:47:35','2012-03-28 12:25:58',NULL,1,'raw');
/*!40000 ALTER TABLE `layouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_articles`
--

DROP TABLE IF EXISTS `news_articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_articles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `news_rubric_id` int(11) DEFAULT '1',
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `date` datetime DEFAULT NULL,
  `info` text,
  `publish_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_news_articles_slug` (`slug`),
  KEY `index_news_articles_created_by` (`created_by_id`),
  KEY `index_news_articles_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news_articles`
--

LOCK TABLES `news_articles` WRITE;
/*!40000 ALTER TABLE `news_articles` DISABLE KEYS */;
/*!40000 ALTER TABLE `news_articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_events`
--

DROP TABLE IF EXISTS `news_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_events` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `info` text,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `publish_at` datetime DEFAULT NULL,
  `news_rubric_id` int(11) DEFAULT '1',
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `period` varchar(255) DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_news_events_slug` (`slug`),
  KEY `index_news_events_created_by` (`created_by_id`),
  KEY `index_news_events_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news_events`
--

LOCK TABLES `news_events` WRITE;
/*!40000 ALTER TABLE `news_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `news_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_rubrics`
--

DROP TABLE IF EXISTS `news_rubrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_rubrics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_news_rubrics_slug` (`slug`),
  KEY `index_news_rubrics_created_by` (`created_by_id`),
  KEY `index_news_rubrics_updated_by` (`updated_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news_rubrics`
--

LOCK TABLES `news_rubrics` WRITE;
/*!40000 ALTER TABLE `news_rubrics` DISABLE KEYS */;
INSERT INTO `news_rubrics` VALUES (1,'Site news','Default news rubric','default','2012-03-16 15:04:01','2012-03-16 15:07:37',NULL,1),(2,'Site events','Default events rubric','events','2012-05-23 11:17:37','2012-05-23 11:17:37',NULL,NULL);
/*!40000 ALTER TABLE `news_rubrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `options`
--

DROP TABLE IF EXISTS `options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `options` (
  `id` varchar(20) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `options`
--

LOCK TABLES `options` WRITE;
/*!40000 ALTER TABLE `options` DISABLE KEYS */;
/*!40000 ALTER TABLE `options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `path` varchar(2000) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `publish_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `layout_id` varchar(20) DEFAULT 'application',
  `fragment_id` varchar(20) DEFAULT 'page',
  `is_module` tinyint(1) DEFAULT '0',
  `params` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pages_created_by` (`created_by_id`),
  KEY `index_pages_updated_by` (`updated_by_id`),
  KEY `index_pages_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (35,'Центр мультимедиа и интернет технологий МИТТЕК','[right]fghj\r\nfh[/right]','/',10,'index',1,NULL,'2012-02-24 14:47:34','2012-07-01 13:51:53',NULL,1,NULL,'application','index',0,''),(36,'Error','Default error page','/error',100,'error',0,NULL,'2012-02-24 14:47:34','2012-07-01 12:53:17',NULL,1,35,'application','page',0,NULL),(37,'Admin panel','','/admin',110,'admin',0,'2012-03-25 16:00:04','2012-02-24 14:47:34','2012-07-01 12:53:15',NULL,1,35,'application','page',0,NULL),(43,'404 Not Found','Sorry, page not found','/error/404',10,'404',0,NULL,'2012-02-24 14:47:35','2012-03-12 14:36:28',NULL,1,36,'application','page',0,NULL),(44,'501 Service Unavailable','Sorry, requested service is unavailable','/error/501',20,'501',0,NULL,'2012-02-24 14:47:35','2012-03-12 14:36:31',NULL,1,36,'application','page',0,NULL),(69,'Разработка сайтов и информационных систем','Отдел Интернет-разработок ООО \"МИТТЕК\" выполняет разработку, поддержку и сопровождение информационных систем, ориентированных на использование в Интернете, а также созданием и эксплуатацией интранет-решений для университета — как чисто образовательных, так и поддерживающих бизнес-процессы.\r\n\r\nВ 2002 году для этих целей нами создан собственный, принципиально новый Конструктор сайтов swift.engine, на основе которого выполнены многие работы. Разработка Конструктора не прекращается ни на день, поэтому помимо обычных Интернет-сайтов мы имеем возможность создавать продвинутые портальные решения.\r\n\r\nВ команду отдела входят профессиональные программисты, дизайнеры, верстальщики и редакторы, благодаря чему мы предоставляем самый высокий в регионе уровень методической и технологической поддержки Интернет-проектов — от визиток до порталов муниципальных образований.','/internet',20,'internet',1,'2012-07-01 12:53:13','2012-07-01 12:53:09','2012-07-01 12:53:28',1,1,35,'application','page',0,''),(71,'Web-сайт: профессиональный подход','10 кратких выводов из 10-летней практики создания сайтов\r\n========================================================\r\n\r\n«Умные предпочитают учиться на ошибках других» — предупреждал О. Бисмарк.\r\n------------------------------------------------------------------------\r\n\r\nПрофессиональная студия предъявляет заказчику «портфолио», а проще — перечень уже реализованных проектов. Каждый проект означает пройденный путь, накопленный креативный опыт, опыт избавления от ошибок. Важно, чтобы в портфолио разработчика были проекты, по сложности и направленности дающие опору, стартовую площадку для работы. Этот фактор сэкономит время и нервы, увеличит шансы на успех. Важен не размер портфолио, а качество выполненных проектов, их время жизни, решенные ими задачи.\r\n\r\nПравильно поставить задачу — это наполовину решить ее.\r\n------------------------------------------------------\r\n\r\nДля заказчика проект его сайта — новый проект. Специалисты интернет-студии с многолетним опытом создания и сопровождения интернет-проектов скорее всего уже разрабатывали подобные сайты, и поэтому знают эффективные решения и не понаслышке представляют большинство подводных камней. Профессиональное обсуждение проекта сайта, его назначения, функциональности и использования позволят заказчику уточнить и сформулировать более реальное видение задачи и сформулировать такое техническое задание, которое реализует истинные цели сайта.\r\n\r\nПрофессиональное разделение труда\r\n---------------------------------\r\n\r\nЭто залог качественного и завершенного выполнения каждого компонента разработки: информационной и навигационной структуры сайта, проработки дизайна каждого типа страницы сайта (в сложном по функциональности сайте кроме дизайна главной страницы может быть еще более 50 поддизайнов различных типов страниц, и каждый тип должен быть выполнен дизайнером строго в стилевом решении сайта), правильной верстки каждого типа страницы, начального наполнения сайта и правильного заполнения метаданных каждой страницы (метаданные — это особые текстовые поля, невидимые на экране, но используемые браузером и поисковиками), формирования списка и функциональности сервисов сайта, а также их правильная настройка. В реализации сайта нет мелочей. Именно профессиональное разделение труда обеспечивает качественную и подробную проработку всех компонент сайта.\r\n\r\nСовместимость с наиболее популярными браузерами\r\n-----------------------------------------------\r\n\r\nСайт должен одинаково хорошо функционировать (выглядеть и работать) во всех наиболее часто используемых браузерах: MS InternetExplorer 6.0 и выше, Opera, Mozilla Firefox, Safari, Google Chrome. Во всех этих программах сайт должен выглядеть одинаково достойно, как графика так и шрифты. Появление на экране компьютера пользователя нечитаемых блоков символов вместо текста, пустых рамок вместо рисунков — признак непрофессиональной разработки сайта.\r\n\r\nУстойчивость дизайна к разрешению экрана\r\n----------------------------------------\r\n\r\nСайт открывается в окне браузера. Ширина окна может варьироваться от сотен пикселей до полутора и более тысяч (особенно на современных широкоформатных мониторах). При любой ширине окна сайт должен выглядеть целостно и читаемо, графический образ страницы не должен разрушаться, а текстовые блоки должны быть удобны для восприятия. Это свойство должно сохраняться при использовании любого из популярных браузеров. Профессионально выполненный дизайн и сборка страниц учитывают эти особенности и не доставляют пользователю неприятных неожиданностей.\r\n\r\nИзначальная поисковая оптимизация сайта\r\n---------------------------------------\r\n\r\nПрофессионально созданный и наполняемый сайт самостоятельно занимает достойные рейтинги в поисковых системах и, как правило, не требует дорогостоящей «раскрутки». Это достигается сочетанием целого ряда продуманных, согласуемых друг с другом во время разработки и развития сайта деталей: информационной структуры, названий разделов и страниц, наполнением полей метаописаний страниц и их согласованностью с текстами сайта, прозрачной навигационной структурой и так далее.\r\n\r\nАвторское сопровождение (техническое, технологическое, методическое, подстраховывающее).\r\n------------------------------------------------------------------------\r\n\r\nПосле разработки и выхода сайта в интернет — рождения сайта — начинается самое интересное, его ЖИЗНЬ, то, ради чего он создавался. Информация живого сайта обновляется, он развивается и вширь, и вглубь. Профессиональное авторское сопровождение как раз и призвано обеспечивать это развитие. Сопровождение подразумевает такое присутствие разработчика, которое незаметно пока все течет гладко, но проявляется в любой внештатной ситуации. Это консультативная или экстренная помощь, это малые или большие доработки.\r\n\r\nСобственный движок\r\n------------------\r\n\r\n«Движок», или, точнее — CMS (Content Мanagement System — Система управления контентом) — это программа, позволяющая удобно и оперативно добавлять (изменять) содержание сайта (без программирования каждой новой страницы на языке разметки). Возможности CMS определяют и возможности развития сайта. Наличие у разработчика собственной проверенной и развиваемой CMS означает, что в случае необходимости функциональность сайта сможет быть расширена за счет доработки новых модулей. Такая ситуация возникает, например, при изменении функциональности сайтов Администраций муниципальных образований, вызванной изменениями законодательства. Даже если принято решение о реализации сайта на другом программном продукте, опыт развития собственного движка позволит максимально корректно и эффективно работать со сторонним продуктом.\r\n\r\nВысокая совокупная надежность\r\n-----------------------------\r\n\r\nНадежность включает в себя много факторов. Это и устойчивость сервера к атакам хакеров (людей и роботов), это стабильная и безотказная работа компьютерного железа и софта, это обязательное регулярное (в зависимости от частоты обновления информации сайта) резервирование всех данных сервера (бэкап), это возможность быстрой генерации копии сайта из сохраненных данных в случае форсмажорной ситуации, и, наконец, это обеспечение видимости сайта в сетях различных операторов связи. Профессиональное разделение труда в процессе информационного наполнения сайта также служит обеспечению надежного функционирования проекта.\r\n\r\nПрофессиональный хостинг\r\n------------------------\r\n\r\nХостинг — услуга по размещению информации на сервере, постоянно находящемся в сети Интернет. Организации, предоставляющие услугу хостинга, кроме программно-технического и кадрового оснащения должны иметь прямой выход в сети наиболее крупных российских операторов связи. Этим условиям удовлетворяют немногие площадки. Именно таким площадкам следует отдать предпочтение при осуществлении хостинга ответственных проектов.\r\n\r\n[right]Широков Владимир Анатольевич\r\nДиректор центра мультимедиа и интернет технологий УдГУ\r\nДиректор ООО «МИТТЕК»[/right]','/internet/professional-web',25,'professional-web',1,'2012-07-01 12:59:11','2012-07-01 12:59:08','2012-07-01 13:46:14',1,1,69,'application','page',0,''),(72,'Решения для интернета','Мы предлагаем для создания и сопровождения вашего сайта воспользоваться Конструктором swift.engine, который позволит вам:\r\n\r\n - самостоятельно, без привлечения программистов, управлять структурой страниц и разделов сайта;\r\n - оперативно и без посредников вносить изменения в содержание сайта;\r\n - создать многопользовательскую модель управления контентом сайта с разграничением прав доступа пользователей к различным разделам сайта;\r\n - управлять сайтом из любой точки планеты;\r\n - точно позиционировать любой объект сайта на странице, и дать возможность повторно использовать его в произвольном количестве страниц различным пользователям в соответствии с их правами;\r\n - и, таким образом, существенно ускорить процесс управления контентом сайта и во много раз уменьшить стоимость его сопровождения.\r\n\r\nУстраивайтесь поудобнее, и мы расскажем вам о сайтах предприятий и организаций, которые уже воспользовались нашим предложением.','/internet/solution',30,'solution',1,'2012-07-01 14:00:06','2012-07-01 14:00:01','2012-07-01 14:00:06',1,1,69,'application','page',0,''),(73,'Интранет-решения','Интранет-решения, ориентированные на управление различными бизнес-процессами, функционируют в локальной сети предприятия, или в Интернете — для связи географически разделённых филиалов (или предприятий холдинга) в едином информационном пространстве.\r\n\r\nМультимедиа центр имеет большой опыт разработки, внедрения и сопровождения интранет-решений для Удмуртского государственного университета, часть которых работает через веб-интерфейс, и доступна для пользователей из любой точки планеты. Как раз о них и пойдёт речь здесь.','/internet/intranet',35,'intranet',1,'2012-07-01 14:01:24','2012-07-01 14:01:21','2012-07-01 14:01:24',1,1,69,'application','page',0,''),(74,'Специальные решения','Кроме решений, ориентированных только на использование внутри предприятия, или исключительно для пользователей Интернета, существует класс гибридных решений, которые трудно отнести к определённой разновидности. Обычно такие решения имеют «открытую» (доступную для всех) и «закрытую» (доступную только для части пользователей) части.\r\n\r\nСпециальные решения характеризуются, как правило, уникальностью, повышенной сложностью постановки задачи, и специфическими особенностями в реализации. И часто подобные решения претендуют на портальный статус.\r\n\r\nМультимедиа центр имеет опыт разработки и поддержки нескольких таких проектов.','/internet/special',40,'special',1,'2012-07-01 14:02:39','2012-07-01 14:02:37','2012-07-01 14:02:39',1,1,69,'application','page',0,''),(75,'О нас','ООО МИТТЕК – профессиональный разработчик решений в области информационных технологий.\r\n\r\nОсновные направления деятельности – создание и сопровождение интернет-сайтов, а также разработка мультимедийных дисков и презентаций: от идеи до воплощения (включая хостинг сайтов и выпуск тиража дисков).\r\n\r\nДля разработки сайтов (от простейших, так называемых «сайтов-визиток» до интернет-магазинов и крупных интернет-порталов государственных учреждений, муниципальных образований и коммерческих организаций) компания МИТТЕК создала свою собственную систему конструирования сайтов – s.e. (swift. engine.) Эта CMS (Content Management System) постоянно совершенствуется и благодаря этому удовлетворяет все более возрастающим современным требованиям по функциональности и безопасности.\r\n\r\nВвиду того, что в последние годы CMS «1С-Битрикс» стала самой популярной платной CMS в России, в 2010г. компания МИТТЕК прошла все необходимые процедуры сертификации и стала сертифицированным партнером «1С-Битрикс»\r\n\r\nЕще одним направлением деятельности является разработка интернет решений для администраций сельских муниципалитетов (сайты, специализированные модули для управления документами).\r\n\r\nРазработка мультимедийных информационных продуктов в последние годы ведется компанией МИТТЕК с применением кроссплатформенных технологий, позволяющей просматривать диски и презентации на любых компьютерах, работающих под Microsoft Windows, Linux или MacOS. Многие полноформатные диски создаются в двух (Рус/Англ) или трехязычной (Рус/Англ/Фр) версии.\r\n\r\nИнтересными и перспективными направлениями деятельности компании являются также: разработка и сопровождение систем электронного обучения (на основе LMS MOODLE); разработка баз данных для создания электронных архивов; ретроконверсия архивных документов и другие виды деятельности в области информационных технологий.\r\n\r\nОсобое внимание компания уделяет сопровождению разработок, выполняемому на договорной основе. Сопровождение сайтов, например, позволяет владельцу сайта забыть обо всех технических и организационных проблемах, связанных с сайтом: это своевременное продление регистрации доменного имени, решение всех проблем хостинговых площадок, решение всех вопросов связанных с изменениями в законодательстве РФ, информационная и организационная поддержка в экстренных случаях, включая восстановление данных при технических авариях или человеческого фактора (ошибках операторов), помощь в размещении больших объемов или новых форматов информации, и так далее и тому подобное, все, что может произойти в течение многолетней работы и развития сайта. Не случайно многие владельцы уже созданных сайтов передают свои сайты на сопровождение в МИТТЕК.\r\n\r\nКомпания выполняет весь цикл разработки: идея –> техническое задание –> календарный план –> проектирование информационной структуры и графического дизайна –> программирование –> сборка –> информационное наполнение –> отладка –> (второй, третий языки) –> размещение на хостинге или выпуск тиража –> обучение представителей Заказчика работе с продуктом --> сопровождение проекта. Цена каждого проекта индивидуальна и рассчитывается после определения и согласования с Заказчиком реальной трудоемкости работ. Предусмотрены скидки и агентское вознаграждение (определяется индивидуально). Определяющая скидка – за соблюдение Заказчиком сроков согласования промежуточных результатов на всех стадиях проекта.\r\n\r\nВ некоторых случаях МИТТЕК выполняет только часть работ (например – графический дизайн, флэш-баннеры или программирование проекта) на договорной основе.\r\n\r\nС момента основания в 2001г. компания МИТТЕК выполнила большое количество работ, ряд из которых отмечен призами. ','/about',25,'about',1,'2012-07-01 14:06:52','2012-07-01 14:06:46','2012-07-01 14:06:52',1,1,35,'application','page',0,''),(76,'Успехи и достижения','Работы ООО МИТТЕК неоднократно отмечались на престижных всероссийских конкурсах среди разработчиков мультимедиа и информационных продуктов.\r\n\r\nБолее 10 лет ООО МИТТЕК успешно развивает и внедряет современные мультимедийные технологии. И сегодня ООО МИТТЕК занимает достойное место среди российских мультимедиа-разработчиков.\r\n\r\n----------\r\n\r\n[image 112 Живой голос истории]\r\n[image 111 Видеотрансляция nadymregion.ru]\r\n[image 113 Лучший сайт городского поселения]\r\n[image 108 Диплом: Нефть]\r\n[image 110 Сайт 2003]\r\n[image 105 Контент 2001: Герменевтика]\r\n[image 103 Контент 2001: Земля надымская]\r\n[image 104 Мир ПК]\r\n[image 107 Контент 2000: Калашников]\r\n[image 106 Контент 2000: Чепецкий механический завод]\r\n[image 109 Экспо \'98]\r\n','/awards',30,'awards',1,'2012-07-01 14:35:30','2012-07-01 14:07:56','2012-07-01 14:35:30',1,1,35,'application','page',0,''),(77,'Формы','','/forms',35,'forms',1,'2012-07-15 12:39:34','2012-07-15 12:39:17','2012-07-23 11:25:14',1,1,35,'application','forms',1,''),(78,'Опросы','','/inquiries',40,'inquiries',0,'2012-07-23 11:25:51','2012-07-23 11:25:46','2012-07-23 12:15:17',1,1,35,'application','inquiries',1,'');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-07-25 19:33:36
