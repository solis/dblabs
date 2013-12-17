--2. Скачки
--Триггер должен проверять следующее условие: одновременно с одной лошадью не могут работать несколько жокеев (однако какое-то время за лошадью может быть не закреплено ни одного жокея).
--Это и так невозможно благодаря дизайну таблицы. Переформулируем условие - один жокей не может одновременно работать с несколькили лошадями (но некоторое время может не работать ни с одной лошадью)
CREATE OR REPLACE TRIGGER NoMoreThanOneHorse
    BEFORE INSERT OR UPDATE OF Jockey_ID
    ON Horses
    FOR EACH ROW
DECLARE
    NumOfHorsesForJockey NUMBER(4);
BEGIN
    SELECT COUNT(*) INTO NumOfHorsesForJockey FROM Horses
        WHERE Jockey_ID = :NEW.Jockey_ID AND Horse_ID <> :NEW.Horse_ID;
    IF NumOfHorsesForJockey > 0
        THEN RAISE_APPLICATION_ERROR (-20445, 'Нельзя закрепить за лошадью уже занятого жокея!');
        END IF;
END NoMoreThanOneHorse;

--Проверка (предполагаем, что таблица Horses пустая)
INSERT INTO Horses
    VALUES (1, 1, 1, '1', 'M', to_date('01-01-1981', 'dd-mm-yyyy'));

--Не должно сработать
INSERT INTO Horses
    VALUES (2, 1, 1, '2', 'M', to_date('01-01-1981', 'dd-mm-yyyy'));

--Сработает
INSERT INTO Horses
    VALUES (2, 2, 1, '2', 'M', to_date('01-01-1981', 'dd-mm-yyyy'));

--Не должно сработать
UPDATE Horses
    SET Jockey_ID = 2
    WHERE Horse_ID = 1;