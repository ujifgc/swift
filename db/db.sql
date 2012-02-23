-- MySQL dump 10.13  Distrib 5.5.19, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: swift_development
-- ------------------------------------------------------
-- Server version	5.5.19-1~dotdeb.1

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
  PRIMARY KEY (`accessible_id`,`accessible_type`,`account_id`),
  UNIQUE KEY `unique_accesses_key` (`accessible_id`,`accessible_type`),
  KEY `index_accesses_account` (`account_id`),
  CONSTRAINT `accesses_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'admin','group','admin@localhost','$2a$10$jrrMu2jwLJRcI8r1q2x/TuoJMPr2RlUR6ufNQExliy0YYPTx4XEi2',NULL,NULL,NULL),(2,'designer','group','designer@localhost','$2a$10$57mQbZgAoqLHMMF0kW6/xuF.tuAVADbOlLh7h.fsfa3wb1P/EfiNa',NULL,NULL,NULL),(3,'auditor','group','auditor@localhost','$2a$10$soMk/WAUlFiTPT/.NltoUuGeB5Dft0zsRQcVyqt2IKMI3ERHJR45C',NULL,NULL,NULL),(4,'editor','group','editor@localhost','$2a$10$A6rnE0hrCsc0rIGyGrDcgOHoX3lP2azIleXiVO5bjC9Xg.zErbiIK',NULL,NULL,NULL),(5,'robot','group','robot@localhost','$2a$10$3FYaSzOkS1oz1xFF37ZqP.u8g51Co6JHtusHklOZAfJjmHnO.1Ze2',NULL,NULL,NULL),(6,'user','group','user@localhost','$2a$10$w8NrkxkPyz1mWk4pa3HWt.eRpZSgvImPg4UkuuUIFAtSgM1JfN7uG',NULL,NULL,NULL);
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
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `folder_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assets_created_by` (`created_by_id`),
  KEY `index_assets_updated_by` (`updated_by_id`),
  KEY `index_assets_folder` (`folder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` VALUES (3,'Валерий Меладзе - Девуша из высшего общества','120223001223_Валерий_Меладзе_-_Девуша_из_высшего_общества.MP3','2012-02-23 00:12:23','2012-02-23 00:12:23',1,1,2);
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
  PRIMARY KEY (`id`),
  KEY `index_blocks_created_by` (`created_by_id`),
  KEY `index_blocks_updated_by` (`updated_by_id`),
  KEY `index_blocks_folder` (`folder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocks`
--

LOCK TABLES `blocks` WRITE;
/*!40000 ALTER TABLE `blocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocks` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders`
--

LOCK TABLES `folders` WRITE;
/*!40000 ALTER TABLE `folders` DISABLE KEYS */;
INSERT INTO `folders` VALUES (1,'Layout graphics','2012-02-20 13:44:10','2012-02-20 13:44:10','images',NULL,NULL,NULL),(2,'Common files','2012-02-20 13:44:10','2012-02-20 13:44:10','files',NULL,NULL,NULL);
/*!40000 ALTER TABLE `folders` ENABLE KEYS */;
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
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `folder_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_created_by` (`created_by_id`),
  KEY `index_images_updated_by` (`updated_by_id`),
  KEY `index_images_folder` (`folder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `layouts`
--

DROP TABLE IF EXISTS `layouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `layouts` (
  `slug` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`slug`),
  KEY `index_layouts_created_by` (`created_by_id`),
  KEY `index_layouts_updated_by` (`updated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `layouts`
--

LOCK TABLES `layouts` WRITE;
/*!40000 ALTER TABLE `layouts` DISABLE KEYS */;
INSERT INTO `layouts` VALUES ('application','2012-02-23 13:38:30','2012-02-23 13:38:30',NULL,NULL);
/*!40000 ALTER TABLE `layouts` ENABLE KEYS */;
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
  `priority` int(11) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '1',
  `publish_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(10) unsigned DEFAULT NULL,
  `updated_by_id` int(10) unsigned DEFAULT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `layout_slug` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pages_created_by` (`created_by_id`),
  KEY `index_pages_updated_by` (`updated_by_id`),
  KEY `index_pages_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (103,'Index','index','/',NULL,'index',1,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,NULL,'application'),(104,'Error','Default error page','/error',NULL,'error',0,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,103,'application'),(105,'Admin panel',NULL,'/admin',NULL,'admin',1,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,103,'application'),(106,'About this site','This web site is generated by Swift Singer','/about',NULL,'about',1,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,103,'application'),(111,'404 Not Found','Sorry, page not found','/error/404',NULL,'404',0,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,104,'application'),(112,'501 Service Unavailable','Sorry, requested service is unavailable','/error/501',NULL,'501',0,NULL,'2012-02-20 13:44:10','2012-02-20 13:44:10',NULL,NULL,104,'application');
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

-- Dump completed on 2012-02-23 15:00:21
