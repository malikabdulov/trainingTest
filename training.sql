-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               8.0.19 - MySQL Community Server - GPL
-- Операционная система:         Win64
-- HeidiSQL Версия:              11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Дамп структуры базы данных training_test
CREATE DATABASE IF NOT EXISTS `training_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `training_test`;

-- Дамп структуры для таблица training_test.tests
CREATE TABLE IF NOT EXISTS `tests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Дамп данных таблицы training_test.tests: ~1 rows (приблизительно)
/*!40000 ALTER TABLE `tests` DISABLE KEYS */;
INSERT INTO `tests` (`id`, `name`, `description`) VALUES
	(1, 'Тест №1', 'Тест состоит из 20 вопросов. Выбирай ответ с умом, его нельзя поменять');
/*!40000 ALTER TABLE `tests` ENABLE KEYS */;

-- Дамп структуры для таблица training_test.test_answers
CREATE TABLE IF NOT EXISTS `test_answers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned NOT NULL,
  `variant_id` int unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_test_answers_users` (`student_id`),
  KEY `FK_test_answers_test_question_variants` (`variant_id`),
  CONSTRAINT `FK_test_answers_test_question_variants` FOREIGN KEY (`variant_id`) REFERENCES `test_question_variants` (`id`),
  CONSTRAINT `FK_test_answers_users` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Дамп данных таблицы training_test.test_answers: ~40 rows (приблизительно)
/*!40000 ALTER TABLE `test_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_answers` ENABLE KEYS */;

-- Дамп структуры для таблица training_test.test_questions
CREATE TABLE IF NOT EXISTS `test_questions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `test_id` int unsigned DEFAULT NULL,
  `question` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_test_questions_tests` (`test_id`),
  CONSTRAINT `FK_test_questions_tests` FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Дамп данных таблицы training_test.test_questions: ~20 rows (приблизительно)
/*!40000 ALTER TABLE `test_questions` DISABLE KEYS */;
INSERT INTO `test_questions` (`id`, `test_id`, `question`) VALUES
	(1, 1, 'Укажите допустимый возраст для оформления денежного кредита Xsell клиентов:'),
	(2, 1, 'Максимальная сумма Xsell клиентам по денежному кредитованию:'),
	(3, 1, 'Сколько кредитов Клиент может иметь одновременно в БХК?'),
	(4, 1, 'Срок кредитования для продукта "ФЗП_oRBP_1-12 акционный платеж"?'),
	(5, 1, 'Сколько составляет комиссия за ежемесячное обслуживание карточки Dos v3.0? '),
	(6, 1, 'Если Клиент оформил кредит на 10 месяцев (без ФЗ), то когда Клиент сможет сделать досрочное погашение с перерасчетом процентов?'),
	(7, 1, 'Сколько составляет финансовая защита в карте DOS v3.0?'),
	(8, 1, 'Основные преимущества Финансовый Защиты на денежных кредитах:'),
	(9, 1, 'Требования к клиенту для оформления денежного кредит?'),
	(10, 1, 'Клиент оформил кредит с Финансовой Защитой. Когда клиент может закрыть кредит полностью с перерасчетом?'),
	(11, 1, 'Если Клиент оформил кредит на 24 месяцев (без ФЗ), то когда Клиент сможет сделать досрочное погашение с перерасчетом процентов?'),
	(12, 1, 'Сколько календарных дней действует льготный период по карте DOS v 3.0 и DOS v 3.5?'),
	(13, 1, 'Какой статус разговора нужно проставить, если на линии был клиент , сказал "алло" и разговор оборвался?'),
	(14, 1, 'Сколько % составляет Welcomе Bonus по кредитной карте ДОС?'),
	(15, 1, 'Как определяется расчетная дата по кредитной карте?'),
	(16, 1, 'Какая ситуация считается критической ошибкой:'),
	(17, 1, 'Если Клиент отказывается от записи в отделение, сколько раз нужно отработать возражение клиента?'),
	(18, 1, 'Из каких этапов состоит «Работа с возражениями» :'),
	(19, 1, 'В какой ситуации Оператор получает 0 баллов за разговор:'),
	(20, 1, 'Каким образом и какими способами производится перевод бонусов?');
/*!40000 ALTER TABLE `test_questions` ENABLE KEYS */;

-- Дамп структуры для таблица training_test.test_question_variants
CREATE TABLE IF NOT EXISTS `test_question_variants` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `test_question_id` int unsigned NOT NULL,
  `variant` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_right_variant` enum('Y','N') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_test_question_variants_test_questions` (`test_question_id`),
  CONSTRAINT `FK_test_question_variants_test_questions` FOREIGN KEY (`test_question_id`) REFERENCES `test_questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Дамп данных таблицы training_test.test_question_variants: ~60 rows (приблизительно)
/*!40000 ALTER TABLE `test_question_variants` DISABLE KEYS */;
INSERT INTO `test_question_variants` (`id`, `test_question_id`, `variant`, `is_right_variant`) VALUES
	(1, 1, 'от 22 лет до 72 лет', 'N'),
	(2, 1, 'от 23 лет до 75 лет', 'N'),
	(3, 1, 'от 22 лет до 75 лет', 'Y'),
	(4, 2, '2 000 000', 'N'),
	(5, 2, '1 000 000', 'N'),
	(6, 2, '5 000 000', 'Y'),
	(7, 3, '3', 'N'),
	(8, 3, '5', 'Y'),
	(9, 3, '6', 'N'),
	(10, 4, 'от 12 до 60 месяцев', 'N'),
	(11, 4, 'от 6 до 48 месяцев', 'N'),
	(12, 4, 'от 6 до 60 месяцев', 'Y'),
	(13, 5, '899 тг', 'N'),
	(14, 5, '499 тг', 'Y'),
	(15, 5, '0 тг', 'N'),
	(16, 6, 'В течение 14 дней со дня заключения кредитного договора, либо через 6 месяцев с момента оформления кредита', 'Y'),
	(17, 6, 'В течение 14 дней со дня заключения кредитного договора, либо через 3 месяцев с момента оформления кредита', 'N'),
	(18, 6, 'Перерасчет процентов не будет осуществляться,  так как кредит оформлен меньше чем на один год', 'N'),
	(19, 7, '0', 'N'),
	(20, 7, '0,99% от основного долга в расчётную дату', 'Y'),
	(21, 7, '6% от основного долга в расчётную дату', 'N'),
	(22, 8, 'Досрочное погашение, Платежные каникулы и Защита от временной нетрудоспособности', 'Y'),
	(23, 8, 'Досрочное погашение, Защита от временной нетрудоспособности', 'N'),
	(24, 8, 'Досрочное погашение, Платежные каникулы или Защита от временной нетрудоспособности', 'N'),
	(25, 9, 'Все выше перечисленное', 'Y'),
	(26, 9, 'Физ лица РК и иностранные лица, Возраст от 22 до 75 лет, Имеющий постоянный источник дохода', 'N'),
	(27, 9, 'Стаж работы не менее 3-х месяцев, Военнообязанные, Инвалид II и III группы', 'N'),
	(28, 10, 'В любое время (с перерасчётом процентов)', 'Y'),
	(29, 10, 'Только через 6 месяцев (с перерасчётом процентов)', 'N'),
	(30, 10, 'Через 12 месяцев (с перерасчётом процентов)', 'N'),
	(31, 11, 'В течение 14 дней со дня заключения кредитного договора, либо через 6 месяцев с момента оформления кредита', 'N'),
	(32, 11, 'В течение 14 дней со дня заключения кредитного договора, либо через 12 месяцев с момента оформления кредита', 'Y'),
	(33, 11, 'Клиент может в любое время закрыть кредит досрочно', 'N'),
	(34, 12, 'до 30 дней', 'N'),
	(35, 12, 'до 52 дней', 'N'),
	(36, 12, 'до 62 дней', 'Y'),
	(37, 13, 'сообщение на автоответчик', 'N'),
	(38, 13, 'неверный контакт', 'N'),
	(39, 13, 'сбой звонка', 'Y'),
	(40, 14, '6%', 'N'),
	(41, 14, '10%', 'Y'),
	(42, 14, '20%', 'N'),
	(43, 15, 'Расчетная дата зависит от даты произведенной первой транзакции', 'N'),
	(44, 15, 'Расчетная дата зависит от даты подписания кредитного договора', 'Y'),
	(45, 15, 'Расчетная дата зависит от даты оплаты кредитного договора', 'N'),
	(46, 16, 'не соблюдение логики продаж', 'N'),
	(47, 16, 'предоставление конфиденциальной информацию 3 лицу', 'N'),
	(48, 16, 'все ответы верны', 'Y'),
	(49, 17, '1', 'Y'),
	(50, 17, '2', 'N'),
	(51, 17, '0', 'N'),
	(52, 18, 'Аргумент - закрытие', 'N'),
	(53, 18, 'Условное согласие – аргумент – закрытие', 'Y'),
	(54, 18, 'Алгоритма нет', 'N'),
	(55, 19, 'Был сброс со стороны клиента', 'N'),
	(56, 19, 'Оператор не правильно информировал Клиента по продукту', 'N'),
	(57, 19, 'оператор использует 0 аргументов при РСВ', 'Y'),
	(58, 20, 'через терминалы Банка', 'N'),
	(59, 20, 'через мобильное приложение / КЦ', 'Y'),
	(60, 20, 'перевод не предусмотрен', 'N');
/*!40000 ALTER TABLE `test_question_variants` ENABLE KEYS */;

-- Дамп структуры для таблица training_test.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `telegram_id` int unsigned DEFAULT NULL,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `telegram_username` varchar(50) DEFAULT NULL,
  `student_name` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `telegram_id` (`telegram_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Дамп данных таблицы training_test.users: ~4 rows (приблизительно)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `telegram_id`, `first_name`, `last_name`, `telegram_username`, `student_name`, `created_at`, `updated_at`) VALUES
	(13, 336726819, 'Дайана', 'Сержанова', 'DayDayDayDay', 'lola', '2021-04-17 14:14:46', '2021-04-17 14:14:46'),
	(14, 413974882, 'Malik', 'Abdulov', 'MAbdulov', 'Admintino', '2021-04-17 14:46:10', '2021-04-17 14:46:10'),
	(15, 655202129, 'Элька', NULL, NULL, 'Эльнара', '2021-04-17 23:40:37', '2021-04-17 23:40:37'),
	(16, 440772836, 'Nursultan', 'Karabekuly', NULL, 'Нурсултан', '2021-04-17 23:41:13', '2021-04-17 23:41:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
