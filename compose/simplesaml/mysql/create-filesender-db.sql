CREATE DATABASE IF NOT EXISTS filesender ;
CREATE USER 'filesenderDBA'@'%' IDENTIFIED BY 'filesenderPSWD' ;
GRANT ALL ON filesender.* TO 'filesenderDBA'@'%' ;
FLUSH PRIVILEGES ;
