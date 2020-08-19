-- 1. Вывести самую объемную книгу

#если нас интересуют лишь названия самой объемной книжке\книжек
EXPLAIN
SELECT name FROM books 
WHERE pages=(SELECT MAX(pages) from books);

#если нас интересует полная информация о самой объемной книжке\книжек
SELECT b1.* FROM books b1
INNER JOIN 
(SELECT MAX(pages) max_pages FROM books) b2 
ON b1.pages = b2.max_pages;


SELECT * FROM books b, orders o WHERE b.id = o.id_book;
-- 2. Вывести всех студентов, что брали книгу name_1 (студент мог 1 книгу брать несколько раз)
SELECT DISTINCT o.name FROM books b 
LEFT JOIN orders o 
ON b.id = o.id_book 
WHERE b.name = 'name_1';

-- 3. Какое кол-во студентов брали книгу name_2 (поле orders.name - это уникальный ключ идентификатор студента)
#если имеется ввиду сколько разных студентов брали книгу name_2, то
SELECT COUNT(b1.name) 
FROM (SELECT DISTINCT o.name 
FROM books b LEFT JOIN orders o 
ON b.id = o.id_book 
WHERE b.name = 'name_2'
) b1;

#если имеется ввиду сколько всего раз брали книгу name_2, то
SELECT COUNT(b1.name) FROM (
SELECT o.name 
FROM books b LEFT JOIN orders o 
ON b.id = o.id_book 
WHERE b.name = 'name_2'
) b1;

-- 4. Вывести в алфавитном порядке названия самых дорогих книг в каждом жанре. C условием, что все цены уникальны
SELECT b1.* FROM books b1
INNER JOIN 
(SELECT genre, MAX(price) max_price 
FROM books GROUP BY genre) b2 
ON b1.genre = b2.genre AND b1.price = b2.max_price
ORDER BY b1.name;

-- 5. Вывести данные по книгам, в названии которых присутствует символ "%"

#если нас интересует лишь информация о книгах
SELECT * FROM books WHERE name LIKE '%\%%';

#если нас интересует полная информация
SELECT b.*, o.id AS id_order, o.name as student_name, o.date FROM (
SELECT * FROM books WHERE name LIKE '%|%%' ESCAPE '|'
) b LEFT JOIN orders o 
ON b.id = o.id_book;

-- 6. Вывести имена последних трех студентов и книги, которые они брали когда либо

#если нас интересует три последних студента по алфавиту
SELECT b.*, o2.id AS id_order, o2.name, o2.date 
FROM (SELECT o.* FROM (
SELECT DISTINCT name FROM orders 
ORDER BY name DESC LIMIT 3) o1 
INNER JOIN orders o ON o1.name = o.name
) o2 LEFT JOIN books b ON b.id = o2.id_book
ORDER BY o2.name;

#если нас интересует три последних студента по дате
SELECT b.*, o2.id AS id_order, o2.name, o2.date 
FROM (SELECT o.* FROM (
SELECT name, MAX(date) as max_date 
FROM orders GROUP BY name 
ORDER BY max_date DESC LIMIT 3) o1 
INNER JOIN orders o ON o1.name = o.name
) o2 LEFT JOIN books b ON b.id = o2.id_book
ORDER BY o2.name;

-- 7. Вывести книги, которые студенты не брали в течении текущего месяца
SELECT b.* FROM books b LEFT JOIN (
SELECT id_book, MAX(date) as mx_date FROM orders GROUP BY id_book 
HAVING mx_date >= DATE_SUB(LAST_DAY(NOW()), INTERVAL DAY(LAST_DAY(NOW()))-1 DAY)
) b2 ON b.id = b2.id_book
WHERE b2.id_book IS NULL;