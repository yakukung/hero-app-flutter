-- MySQL dump 10.13  Distrib 9.5.0, for macos15.4 (arm64)
--
-- Host: localhost    Database: hero_app
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'dfb7ad26-ba1a-11f0-8d38-2ff12afd7862:1-6071';

--
-- Table structure for table `categories`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(150) NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES ('019bbdee-985f-725d-8a19-f23c57263550','วิทยาศาสตร์',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-73d7-a337-fc0f1eee8e2c','คณิตศาสตร์',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-74c2-9c69-da4788065122','คอมพิวเตอร์',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-79e6-81b7-d690639c04ed','ภาษา',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-7a2d-825c-3d19ace2b85f','ศิลปะ',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-7dd3-b57e-e35b3fad00a4','สังคม',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL),('019bbdee-985f-7fe7-846a-3972a042b88c','อื่นๆ',1,'ACTIVE','2026-01-15 02:14:49.055','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_categories` BEFORE INSERT ON `categories` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `keywords`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `keywords` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(150) NOT NULL,
  `usage_count` int NOT NULL DEFAULT '0',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keywords`
--

LOCK TABLES `keywords` WRITE;
/*!40000 ALTER TABLE `keywords` DISABLE KEYS */;
INSERT INTO `keywords` VALUES ('019bbf0a-5cc7-711e-892b-c837346f61c0','คณิต',2,1,'ACTIVE','2026-01-15 00:24:46.023','SYSTEM','2026-01-15 00:34:02.654','SYSTEM',NULL),('019bbf0a-5ccb-711e-892b-d40d7616c50a','ม.ปลาย',2,1,'ACTIVE','2026-01-15 00:24:46.027','SYSTEM','2026-01-15 00:34:02.658','SYSTEM',NULL),('019bbf49-3820-7779-9764-061f338c1458','ทดสอบ',1,1,'ACTIVE','2026-01-15 01:33:25.408','SYSTEM','2026-01-15 01:33:25.415','SYSTEM',NULL),('019bbf65-95ae-7779-9764-395787782885','นนน',1,1,'ACTIVE','2026-01-15 02:04:24.367','SYSTEM','2026-01-15 02:04:24.372','SYSTEM',NULL),('019bbf7c-9fd0-7779-9764-882c0e757b54','วดววดว',1,1,'ACTIVE','2026-01-15 02:29:34.289','SYSTEM','2026-01-15 02:29:34.292','SYSTEM',NULL),('019c23a8-9a06-7cc4-914d-4b8b7f34fb02','kpokpok',2,1,'ACTIVE','2026-02-03 13:19:37.990','SYSTEM','2026-02-03 13:31:57.334','SYSTEM',NULL),('019c23a8-9a0b-7cc4-914d-544cbaa359c6','oijoijoijo',2,1,'ACTIVE','2026-02-03 13:19:37.995','SYSTEM','2026-02-03 13:31:57.338','SYSTEM',NULL),('019c2a89-4712-7334-bb5b-f3056d848544','assess',1,1,'ACTIVE','2026-02-04 21:22:45.650','SYSTEM','2026-02-04 21:22:45.655','SYSTEM',NULL);
/*!40000 ALTER TABLE `keywords` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_keywords` BEFORE INSERT ON `keywords` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `permissions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_permissions` BEFORE INSERT ON `permissions` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `plans`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plans` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'THB',
  `billing_interval` enum('DAY','WEEK','MONTH','YEAR') NOT NULL,
  `billing_interval_count` int NOT NULL DEFAULT '1',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plans`
--

LOCK TABLES `plans` WRITE;
/*!40000 ALTER TABLE `plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `plans` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_plans` BEFORE INSERT ON `plans` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `posts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `content` text NOT NULL,
  `like_count` int NOT NULL DEFAULT '0',
  `comment_count` int NOT NULL DEFAULT '0',
  `share_count` int NOT NULL DEFAULT '0',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sheet_id` (`sheet_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_posts` BEFORE INSERT ON `posts` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `posts_comments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts_comments` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `post_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `content` text NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `posts_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts_comments`
--

LOCK TABLES `posts_comments` WRITE;
/*!40000 ALTER TABLE `posts_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts_comments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_post_comments` BEFORE INSERT ON `posts_comments` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `posts_likes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts_likes` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `post_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `posts_likes_post_id_user_id_unique` (`post_id`,`user_id`),
  UNIQUE KEY `unique_user_post_like` (`user_id`,`post_id`),
  CONSTRAINT `posts_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts_likes`
--

LOCK TABLES `posts_likes` WRITE;
/*!40000 ALTER TABLE `posts_likes` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts_likes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_post_likes` BEFORE INSERT ON `posts_likes` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `posts_shares`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts_shares` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `post_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_posts_shares_post_id` (`post_id`),
  KEY `idx_posts_shares_user_id` (`user_id`),
  CONSTRAINT `posts_shares_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_shares_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts_shares`
--

LOCK TABLES `posts_shares` WRITE;
/*!40000 ALTER TABLE `posts_shares` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts_shares` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_posts_shares` BEFORE INSERT ON `posts_shares` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `roles`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('019affa1-0872-706f-aff1-46d36268f0a8','ADMIN',1,'ACTIVE','2025-12-09 03:22:14.898','SYSTEM',NULL,NULL,NULL),('019affa1-0872-7340-8509-22df2b1553cc','MEMBER',1,'ACTIVE','2025-12-09 03:22:14.898','SYSTEM',NULL,NULL,NULL),('019affa1-0872-78cb-b4ff-5376279dba2d','PREMIUM_MEMBER',1,'ACTIVE','2025-12-09 03:22:14.898','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_roles` BEFORE INSERT ON `roles` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `scopes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scopes` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `role_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `permission_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scopes_permission_id_role_id_unique` (`role_id`,`permission_id`),
  UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `scopes_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `scopes_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scopes`
--

LOCK TABLES `scopes` WRITE;
/*!40000 ALTER TABLE `scopes` DISABLE KEYS */;
/*!40000 ALTER TABLE `scopes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_scopes` BEFORE INSERT ON `scopes` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sessions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `refresh_token` varchar(512) NOT NULL,
  `issued_at` datetime(3) NOT NULL,
  `expires_at` datetime(3) NOT NULL,
  `revoked_flag` tinyint(1) NOT NULL DEFAULT '0',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('019c281d-c020-7225-a712-1d7f99095e7f','019c281d-c011-7225-a712-09bf9b1b82f1','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMTk5NTY0LCJuYmYiOjE3NzAxOTk1NjQsImV4cCI6MTc3MDQ1ODc2NH0.e8bGsfn1e12FbJRXCo4ZZnMbi4swfUcyZ4iie46lsT4','2026-02-04 10:06:04.320','2026-02-07 10:06:04.320',0,NULL,NULL),('019c2918-479f-733f-886c-e379e8cf3d03','019c281d-c011-7225-a712-09bf9b1b82f1','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjE1OTgzLCJuYmYiOjE3NzAyMTU5ODMsImV4cCI6MTc3MDQ3NTE4M30.bOLkWuluJsS_aowePJJURhV9PSxuJaXY2UN2loydam4','2026-02-04 14:39:43.007','2026-02-07 14:39:43.007',0,NULL,NULL),('019c2919-99de-733f-886d-014802bba5ad','019c281d-c011-7225-a712-09bf9b1b82f1','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjE2MDY5LCJuYmYiOjE3NzAyMTYwNjksImV4cCI6MTc3MDQ3NTI2OX0.xxe7NR2jFDmWHLqHcE6qfHaxDfg3D5OrycLIb95ThLU','2026-02-04 14:41:09.598','2026-02-07 14:41:09.598',0,NULL,NULL),('019c295a-f7b1-755c-9efb-fd018ac5cbc3','019c281d-c011-7225-a712-09bf9b1b82f1','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjIwMzUzLCJuYmYiOjE3NzAyMjAzNTMsImV4cCI6MTc3MDQ3OTU1M30.JBk2H8JwwTeP6exAwWzlcR_j_7w9KNQZXGRMbuUFuIo','2026-02-04 15:52:33.457','2026-02-07 15:52:33.457',0,NULL,NULL),('019c2a0d-f530-7774-933a-4b105d322fdc','019c281d-c011-7225-a712-09bf9b1b82f1','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjMyMDgzLCJuYmYiOjE3NzAyMzIwODMsImV4cCI6MTc3MDQ5MTI4M30.8whLzVBFs-gb6YCbqGmpxu-wsTCBKgBx3Qm5Ru__uaY','2026-02-04 19:08:03.760','2026-02-07 19:08:03.760',0,NULL,NULL),('019c2a60-fe5d-7bba-9172-a83265856f14','019c2a60-8841-7bba-9172-a443f5ace840','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjM3NTI1LCJuYmYiOjE3NzAyMzc1MjUsImV4cCI6MTc3MDQ5NjcyNX0.jp6YYK5uUyjRZ25-yHpZwrlSCSx8MHy1WoP0V-m3u68','2026-02-04 20:38:45.597','2026-02-07 20:38:45.597',0,NULL,NULL),('019c2a66-bad4-722e-97b1-6b4ff9752c17','019c2a60-8841-7bba-9172-a443f5ace840','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjM3OTAxLCJuYmYiOjE3NzAyMzc5MDEsImV4cCI6MTc3MDQ5NzEwMX0.IyzdTdSSwwbQO75SHZOCmUXJlHh17k2Hd-7iucFMG1A','2026-02-04 20:45:01.524','2026-02-07 20:45:01.524',0,NULL,NULL),('019c2a86-c964-7334-bb5b-d396c987ab54','019c2a60-8841-7bba-9172-a443f5ace840','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjQwMDAyLCJuYmYiOjE3NzAyNDAwMDIsImV4cCI6MTc3MDQ5OTIwMn0.nSBDBsfSVqUg4DgnS2fXVf92Vzu796qoQt9fm-fIFec','2026-02-04 21:20:02.404','2026-02-07 21:20:02.404',0,NULL,NULL),('019c2cf0-bc55-7222-818b-7c1dbd44c37f','019c2a60-8841-7bba-9172-a443f5ace840','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjgwNTAwLCJuYmYiOjE3NzAyODA1MDAsImV4cCI6MTc3MDUzOTcwMH0.0ulPJiMifQcwnhofdf7riKmMbHGCr_3wtu0EYk8Ssaw','2026-02-05 08:35:00.308','2026-02-08 08:35:00.308',0,NULL,NULL),('019c2cf2-1521-7222-818b-9c63b4f77920','019c2cf2-1516-7222-818b-89efac57b1d4','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyY2YyLTE1MTYtNzIyMi04MThiLTg5ZWZhYzU3YjFkNCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjgwNTg4LCJuYmYiOjE3NzAyODA1ODgsImV4cCI6MTc3MDUzOTc4OH0.cgFQVHbS4w4y1VJHgOiZPXDaJeZJa3mdDKLAZH5g004','2026-02-05 08:36:28.577','2026-02-08 08:36:28.577',0,NULL,NULL),('019c2d24-fbb7-7222-818b-ad9a56f7ac97','019c2a60-8841-7bba-9172-a443f5ace840','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImlzcyI6Ind3dy50ZXN0My5jb20iLCJhdWQiOlsid3d3LnRlc3QxLmNvbSIsInd3dy50ZXN0Mi5jb20iXSwiaWF0IjoxNzcwMjgzOTI0LCJuYmYiOjE3NzAyODM5MjQsImV4cCI6MTc3MDU0MzEyNH0.OyO-Ez02J9JG54WqqVFBh-zY1P24ZJKtQ1KXiiwtQPU','2026-02-05 09:32:04.407','2026-02-08 09:32:04.407',0,NULL,NULL);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sessions` BEFORE INSERT ON `sessions` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `author_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `rating` decimal(3,1) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `author_id` (`author_id`),
  CONSTRAINT `sheets_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets`
--

LOCK TABLES `sheets` WRITE;
/*!40000 ALTER TABLE `sheets` DISABLE KEYS */;
INSERT INTO `sheets` VALUES ('019c2a89-4706-7334-bb5b-e4e0c1668dc1','019c2a60-8841-7bba-9172-a443f5ace840','อะไรไม่รู้','asdasdasd',0.0,100.00,1,'ACTIVE','2026-02-04 21:22:45.638','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `sheets` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets` BEFORE INSERT ON `sheets` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_answers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_answers` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `answer_text` text NOT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT '0',
  `index` int NOT NULL DEFAULT '1',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sheets_answers_question_id` (`question_id`),
  CONSTRAINT `sheets_answers_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `sheets_questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_answers`
--

LOCK TABLES `sheets_answers` WRITE;
/*!40000 ALTER TABLE `sheets_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `sheets_answers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets_answers` BEFORE INSERT ON `sheets_answers` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_categories`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_categories` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `category_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sheets_categories_category_id_sheet_id_unique` (`sheet_id`,`category_id`),
  UNIQUE KEY `unique_sheet_category` (`sheet_id`,`category_id`),
  KEY `idx_sheets_categories_category_id` (`category_id`),
  CONSTRAINT `sheets_categories_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sheets_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_categories`
--

LOCK TABLES `sheets_categories` WRITE;
/*!40000 ALTER TABLE `sheets_categories` DISABLE KEYS */;
INSERT INTO `sheets_categories` VALUES ('019c2a89-470d-7334-bb5b-ef2bcc510e20','019c2a89-4706-7334-bb5b-e4e0c1668dc1','019bbdee-985f-725d-8a19-f23c57263550',1,'ACTIVE','2026-02-04 21:22:45.645','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `sheets_categories` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets_categories` BEFORE INSERT ON `sheets_categories` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_files`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_files` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `format` varchar(255) NOT NULL,
  `size` varchar(255) NOT NULL,
  `original_path` varchar(255) NOT NULL,
  `thumbnail_path` varchar(255) NOT NULL,
  `index` int NOT NULL DEFAULT '1',
  `checksum` varchar(255) NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sheet_id` (`sheet_id`),
  CONSTRAINT `sheets_files_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_files`
--

LOCK TABLES `sheets_files` WRITE;
/*!40000 ALTER TABLE `sheets_files` DISABLE KEYS */;
INSERT INTO `sheets_files` VALUES ('019c2a89-472e-7334-bb5c-09c7f46d691a','019c2a89-4706-7334-bb5b-e4e0c1668dc1','image/jpeg','3936985','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240163377-137235972.jpg','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240163377-137235972.jpg',1,'5b3851a56acd60834d25f79c602f678f',1,'ACTIVE','2026-02-04 21:22:45.678','SYSTEM',NULL,NULL,NULL),('019c2a89-4737-7334-bb5c-102f9f26a5c8','019c2a89-4706-7334-bb5b-e4e0c1668dc1','image/jpeg','1483890','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240164631-596441483.jpg','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240164631-596441483.jpg',2,'d8ece7b0d1d9154044836a3d4bd6487a',1,'ACTIVE','2026-02-04 21:22:45.687','SYSTEM',NULL,NULL,NULL),('019c2a89-473c-7334-bb5c-1910d58c412e','019c2a89-4706-7334-bb5b-e4e0c1668dc1','image/jpeg','989042','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240165151-678675185.jpg','uploads/sheets/019c2a89-4706-7334-bb5b-e4e0c1668dc1/images-1770240165151-678675185.jpg',3,'3dbca1f7ca18653a56108937c4b723b4',1,'ACTIVE','2026-02-04 21:22:45.692','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `sheets_files` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets_files` BEFORE INSERT ON `sheets_files` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_keywords`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_keywords` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `keyword_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sheets_keywords_keyword_id_sheet_id_unique` (`sheet_id`,`keyword_id`),
  UNIQUE KEY `unique_sheet_keyword` (`sheet_id`,`keyword_id`),
  KEY `idx_sheets_keywords_keyword_id` (`keyword_id`),
  CONSTRAINT `sheets_keywords_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sheets_keywords_ibfk_2` FOREIGN KEY (`keyword_id`) REFERENCES `keywords` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_keywords`
--

LOCK TABLES `sheets_keywords` WRITE;
/*!40000 ALTER TABLE `sheets_keywords` DISABLE KEYS */;
INSERT INTO `sheets_keywords` VALUES ('019c2a89-4714-7334-bb5b-fb254ae6beb6','019c2a89-4706-7334-bb5b-e4e0c1668dc1','019c2a89-4712-7334-bb5b-f3056d848544',1,'ACTIVE','2026-02-04 21:22:45.652','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `sheets_keywords` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets_keywords` BEFORE INSERT ON `sheets_keywords` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_questions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_questions` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_text` text NOT NULL,
  `explanation` text,
  `index` int NOT NULL DEFAULT '1',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sheets_questions_sheet_id` (`sheet_id`),
  CONSTRAINT `sheets_questions_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_questions`
--

LOCK TABLES `sheets_questions` WRITE;
/*!40000 ALTER TABLE `sheets_questions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sheets_questions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_sheets_questions` BEFORE INSERT ON `sheets_questions` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sheets_reviews`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sheets_reviews` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'เก็บ id ข้อมูลรีวิวของชีต',
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'เก็บ id ที่อ้างถึงในตาราง sheets',
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'เก็บ id ที่อ้างถึงในตาราง users',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT 'เก็บเนื้อหาของรีวิวชีต',
  `score` int NOT NULL DEFAULT '0' COMMENT 'เก็บคะแนนรีวิวชีต',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'เก็บสถานะการมองเห็นข้อมูล',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE' COMMENT 'เก็บสถานะข้อมูล',
  `created_at` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'เก็บวันที่สร้างข้อมูล',
  `created_by` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM' COMMENT 'เก็บผู้สร้างข้อมูล',
  `updated_at` timestamp(3) NULL DEFAULT NULL COMMENT 'เก็บวันที่แก้ไขล่าสุด',
  `updated_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'เก็บ id ผู้แก้ไขข้อมูลล่าสุด',
  `status_modified_at` timestamp(3) NULL DEFAULT NULL COMMENT 'เก็บวันที่แก้ไขสถานะล่าสุด',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_sheet_user` (`sheet_id`,`user_id`),
  KEY `fk_sheets_reviews_user_id` (`user_id`),
  CONSTRAINT `fk_sheets_reviews_sheet_id` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`),
  CONSTRAINT `fk_sheets_reviews_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลรีวิวของชีต';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sheets_reviews`
--

LOCK TABLES `sheets_reviews` WRITE;
/*!40000 ALTER TABLE `sheets_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `sheets_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `session_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `access_token` varchar(512) NOT NULL,
  `issued_at` datetime(3) NOT NULL,
  `expires_at` datetime(3) NOT NULL,
  `revoked_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `access_token` (`access_token`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `tokens_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens`
--

LOCK TABLES `tokens` WRITE;
/*!40000 ALTER TABLE `tokens` DISABLE KEYS */;
INSERT INTO `tokens` VALUES ('019c281d-c026-7225-a712-22205b5f13df','019c281d-c020-7225-a712-1d7f99095e7f','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAxOTk1NjQsIm5iZiI6MTc3MDE5OTU2NCwiZXhwIjoxNzcwMjM1NTY0fQ.fjVCWFe0HucdkzoGusEObAufw1C_1Bj_gE0F4zLTab4','2026-02-04 10:06:04.326','2026-02-04 20:06:04.326',0),('019c2918-47a3-733f-886c-ec8f078a9980','019c2918-479f-733f-886c-e379e8cf3d03','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMTU5ODMsIm5iZiI6MTc3MDIxNTk4MywiZXhwIjoxNzcwMjUxOTgzfQ.9ev5y836eAnPNvmcnfKSRLGwNr6dNsEUWe0cxjmtTXQ','2026-02-04 14:39:43.010','2026-02-05 00:39:43.010',0),('019c2919-99e2-733f-886d-0eeb0922d104','019c2919-99de-733f-886d-014802bba5ad','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMTYwNjksIm5iZiI6MTc3MDIxNjA2OSwiZXhwIjoxNzcwMjUyMDY5fQ.k-JyAUEXLr6NSGyKJoLjlsXuOlBJuWR_PHCvz0m9PaU','2026-02-04 14:41:09.602','2026-02-05 00:41:09.602',0),('019c295a-f7b4-755c-9efc-0397216975c1','019c295a-f7b1-755c-9efb-fd018ac5cbc3','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMjAzNTMsIm5iZiI6MTc3MDIyMDM1MywiZXhwIjoxNzcwMjU2MzUzfQ.phIx8pvKhGDePasT7KKfaA5yTFVA0uH7aOxzh7mXfYA','2026-02-04 15:52:33.460','2026-02-05 01:52:33.460',0),('019c2a0d-f543-7774-933a-57c7e3494f99','019c2a0d-f530-7774-933a-4b105d322fdc','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyODFkLWMwMTEtNzIyNS1hNzEyLTA5YmY5YjFiODJmMSIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMzIwODMsIm5iZiI6MTc3MDIzMjA4MywiZXhwIjoxNzcwMjY4MDgzfQ.MBbjymvNXkttLWJZ3kbgn4Ff-tWuobE4BwTTTZrQqns','2026-02-04 19:08:03.779','2026-02-05 05:08:03.779',0),('019c2a60-fe64-7bba-9172-b0c57c74354d','019c2a60-fe5d-7bba-9172-a83265856f14','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMzc1MjUsIm5iZiI6MTc3MDIzNzUyNSwiZXhwIjoxNzcwMjczNTI1fQ.GMOOEbtaLC_Oe0IASig3JG4eQwJ5wdfjHUMVUSsbgmg','2026-02-04 20:38:45.604','2026-02-05 06:38:45.604',0),('019c2a66-badc-722e-97b1-724cc79ee681','019c2a66-bad4-722e-97b1-6b4ff9752c17','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyMzc5MDEsIm5iZiI6MTc3MDIzNzkwMSwiZXhwIjoxNzcwMjczOTAxfQ.375yEgZq0XzspmOI1iMfAFPNMdIxNu_oHsuHmV6NgjY','2026-02-04 20:45:01.532','2026-02-05 06:45:01.532',0),('019c2a86-c97f-7334-bb5b-dc2cbc2745d8','019c2a86-c964-7334-bb5b-d396c987ab54','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyNDAwMDIsIm5iZiI6MTc3MDI0MDAwMiwiZXhwIjoxNzcwMjc2MDAyfQ.Jlb4u0kUxpoSUMG8uRbHhUPlTM7rUcZw5OxWlyx66Js','2026-02-04 21:20:02.431','2026-02-05 07:20:02.431',0),('019c2cf0-bc73-7222-818b-8379d83b92c3','019c2cf0-bc55-7222-818b-7c1dbd44c37f','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyODA1MDAsIm5iZiI6MTc3MDI4MDUwMCwiZXhwIjoxNzcwMzE2NTAwfQ.e-EWf2j-4hmS-gPJNNYz0TVg3EloK5u9gDV_oeJGwYc','2026-02-05 08:35:00.339','2026-02-05 18:35:00.339',0),('019c2cf2-1526-7222-818b-a2a192063a98','019c2cf2-1521-7222-818b-9c63b4f77920','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyY2YyLTE1MTYtNzIyMi04MThiLTg5ZWZhYzU3YjFkNCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyODA1ODgsIm5iZiI6MTc3MDI4MDU4OCwiZXhwIjoxNzcwMzE2NTg4fQ.aZhrmJqeEiMM1kvZObMOTB8YbpOKvKNhoAx1Be7z-TE','2026-02-05 08:36:28.582','2026-02-05 18:36:28.582',0),('019c2d24-fbdd-7222-818b-b22a428385b5','019c2d24-fbb7-7222-818b-ad9a56f7ac97','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoiMS4wIiwiaXNzIjoid3d3LnRlc3QzLmNvbSIsInN1YiI6IjAxOWMyYTYwLTg4NDEtN2JiYS05MTcyLWE0NDNmNWFjZTg0MCIsImF1ZCI6WyJ3d3cudGVzdDEuY29tIiwid3d3LnRlc3QyLmNvbSJdLCJhenAiOiI4MmVmY2MxMmQwMDdjNWVlNWMwOWYwNGUyMzZiNThlZSIsInJvbGUiOiIwMTlhZmZhMS0wODcyLTczNDAtODUwOS0yMmRmMmIxNTUzY2MiLCJpYXQiOjE3NzAyODM5MjQsIm5iZiI6MTc3MDI4MzkyNCwiZXhwIjoxNzcwMzE5OTI0fQ.7T7tPCxsKC_ijO0hErK7MoMl2K3mN5KvST7CxXoX4C0','2026-02-05 09:32:04.445','2026-02-05 19:32:04.445',0);
/*!40000 ALTER TABLE `tokens` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_tokens` BEFORE INSERT ON `tokens` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `user_providers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_providers` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `provider_user_id` varchar(255) NOT NULL,
  `provider_name` enum('GOOGLE') NOT NULL,
  `provider_username` varchar(255) NOT NULL,
  `provider_email` varchar(255) NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `provider_user_id` (`provider_user_id`),
  UNIQUE KEY `unique_user_provider` (`user_id`,`provider_name`),
  CONSTRAINT `user_providers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_providers`
--

LOCK TABLES `user_providers` WRITE;
/*!40000 ALTER TABLE `user_providers` DISABLE KEYS */;
INSERT INTO `user_providers` VALUES ('019c281d-c01b-7225-a712-12f7fb7254c3','019c281d-c011-7225-a712-09bf9b1b82f1','eUJjWGc0WMNMcmPbC35GR4CFCPs2','GOOGLE','อัษฎาวุธ ไชยรักษ์','65011212081@msu.ac.th',1,'ACTIVE','2026-02-04 10:06:04.315','SYSTEM',NULL,NULL,NULL),('019c2cf2-151d-7222-818b-96d9b1a73a12','019c2cf2-1516-7222-818b-89efac57b1d4','6ChdcHrH4JU3X0y0uULFNkttYcC2','GOOGLE','Test Atsadawut','testatsadawut@gmail.com',1,'ACTIVE','2026-02-05 08:36:28.573','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `user_providers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_user_providers` BEFORE INSERT ON `user_providers` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` blob,
  `profile_image` text,
  `auth_provider` enum('EMAIL_PASSWORD','GOOGLE') NOT NULL DEFAULT 'EMAIL_PASSWORD',
  `role_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `point` int NOT NULL DEFAULT '0',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('019c281d-c011-7225-a712-09bf9b1b82f1','65011212081_345ff3e6',NULL,NULL,NULL,'GOOGLE','019affa1-0872-7340-8509-22df2b1553cc',0,1,'ACTIVE','2026-02-04 10:06:04.305','SYSTEM',NULL,NULL,NULL),('019c2a60-8841-7bba-9172-a443f5ace840','yakukung','yakukung@gmail.com',_binary '$2b$10$4KvvxmchXFFUy.0uTmdSiOw0B6T4mrDLk/eJZnVWy2caeIl0MR1HG','uploads/users/019c2a60-8841-7bba-9172-a443f5ace840/profiles/profile_image-1770243242185-556255490.png','EMAIL_PASSWORD','019affa1-0872-7340-8509-22df2b1553cc',0,1,'ACTIVE','2026-02-04 20:38:15.361','SYSTEM',NULL,NULL,NULL),('019c2cf2-1516-7222-818b-89efac57b1d4','testatsadawut_af483c63',NULL,NULL,'https://lh3.googleusercontent.com/a/ACg8ocKg1w8DzvS9AwftPueRoF5bO-JIyY407nwPVjktVUDsN6-53w=s96-c','GOOGLE','019affa1-0872-7340-8509-22df2b1553cc',0,1,'ACTIVE','2026-02-05 08:36:28.566','SYSTEM',NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_users` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_payments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_payments` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reference_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reference_table` varchar(100) NOT NULL,
  `payment_method` enum('PROMPTPAY') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'THB',
  `payment_status` enum('PENDING','SUCCESSFUL','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  `slip_image_url` text,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_payments_user_id` (`user_id`),
  CONSTRAINT `users_payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_payments`
--

LOCK TABLES `users_payments` WRITE;
/*!40000 ALTER TABLE `users_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_payments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_user_payments` BEFORE INSERT ON `users_payments` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_plans`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_plans` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `plan_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `start_at` datetime(3) NOT NULL,
  `expires_at` datetime(3) NOT NULL,
  `auto_renew` tinyint(1) NOT NULL DEFAULT '0',
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_plans_plan_id_user_id_unique` (`user_id`,`plan_id`),
  KEY `idx_users_plans_user_id` (`user_id`),
  KEY `idx_users_plans_plan_id` (`plan_id`),
  CONSTRAINT `users_plans_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_plans_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_plans`
--

LOCK TABLES `users_plans` WRITE;
/*!40000 ALTER TABLE `users_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_plans` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_users_plans` BEFORE INSERT ON `users_plans` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_reports`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_reports` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reference_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reference_table` varchar(255) NOT NULL,
  `report_type` enum('SPAM','ABUSE','BUG','OTHER') NOT NULL,
  `reporter_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `content` text NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','REVIEWING','RESOLVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reporter_id` (`reporter_id`),
  CONSTRAINT `users_reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_reports`
--

LOCK TABLES `users_reports` WRITE;
/*!40000 ALTER TABLE `users_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_reports` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_users_reports` BEFORE INSERT ON `users_reports` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_sheets_answers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_sheets_answers` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `selected_answer_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `is_correct` tinyint(1) DEFAULT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question_answer` (`user_id`,`question_id`),
  KEY `idx_users_sheets_answers_question_id` (`question_id`),
  KEY `idx_users_sheets_answers_selected_answer_id` (`selected_answer_id`),
  CONSTRAINT `users_sheets_answers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_sheets_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `sheets_questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_sheets_answers_ibfk_3` FOREIGN KEY (`selected_answer_id`) REFERENCES `sheets_answers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_sheets_answers`
--

LOCK TABLES `users_sheets_answers` WRITE;
/*!40000 ALTER TABLE `users_sheets_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_sheets_answers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_users_sheets_answers` BEFORE INSERT ON `users_sheets_answers` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_sheets_favorites`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_sheets_favorites` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sheet_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `visible_flag` tinyint(1) NOT NULL DEFAULT '1',
  `status_flag` enum('PENDING','ACTIVE','INACTIVE','SUSPENDED','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime(3) NOT NULL,
  `created_by` varchar(255) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` datetime(3) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `status_modified_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_sheets_favorites_sheet_id_user_id_unique` (`sheet_id`,`user_id`),
  UNIQUE KEY `unique_user_sheet_favorite` (`user_id`,`sheet_id`),
  KEY `idx_users_sheets_favorites_sheet_id` (`sheet_id`),
  CONSTRAINT `users_sheets_favorites_ibfk_1` FOREIGN KEY (`sheet_id`) REFERENCES `sheets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_sheets_favorites_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_sheets_favorites`
--

LOCK TABLES `users_sheets_favorites` WRITE;
/*!40000 ALTER TABLE `users_sheets_favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_sheets_favorites` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`yakukung`@`localhost`*/ /*!50003 TRIGGER `before_insert_users_sheets_favorites` BEFORE INSERT ON `users_sheets_favorites` FOR EACH ROW BEGIN
  IF NEW.`id` IS NULL OR NEW.`id` = '' THEN
    SET NEW.`id` = UUIDV7();
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'hero_app'
--
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`yakukung`@`localhost` FUNCTION `UUIDV7`() RETURNS char(36) CHARSET utf8mb4
    NO SQL
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
    DECLARE unix_ms BIGINT;
    DECLARE time_hex CHAR(12);
    DECLARE rand_hex CHAR(20);
    DECLARE version_hex CHAR(4);
    DECLARE variant_hex CHAR(4);
    DECLARE node_hex CHAR(12);
    DECLARE variant_byte_hex CHAR(2);

    SET unix_ms = FLOOR(UNIX_TIMESTAMP(NOW(3)) * 1000);
    SET time_hex = LPAD(HEX(unix_ms), 12, '0');
    SET rand_hex = HEX(RANDOM_BYTES(10));
    SET version_hex = CONCAT('7', SUBSTR(rand_hex, 1, 3));
    SET variant_byte_hex = LPAD(HEX((CONV(SUBSTR(rand_hex, 4, 2), 16, 10) & 0x3F) | 0x80), 2, '0');
    SET variant_hex = CONCAT(variant_byte_hex, SUBSTR(rand_hex, 6, 2));

    SET node_hex = SUBSTR(rand_hex, 8, 12);
    RETURN LOWER(CONCAT(
        SUBSTR(time_hex, 1, 8), '-',
        SUBSTR(time_hex, 9, 4), '-',
        version_hex, '-',
        variant_hex, '-',
        node_hex
    ));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-05 17:19:31
