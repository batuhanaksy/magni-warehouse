CREATE TABLE IF NOT EXISTS `magni_warehouse` (
  `owner` varchar(50) NOT NULL,
  `id` int(11) NOT NULL DEFAULT 1,
  `name` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
