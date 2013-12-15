--5. Учет успеваемости студентов
-- Триггер должен препятствовать удалению информации о предмете, если в базе данных есть сведения о студентах, сдававших этот предмет.
CREATE OR REPLACE TRIGGER NoSubjDelIfExamOrTest
    BEFORE DELETE OR UPDATE OF Predmet_ID, Nazvanie
    ON Uchebnyi_Predmet
    FOR EACH ROW
DECLARE
    PassedExamOrTest NUMBER(4);
BEGIN
    SELECT COUNT(*) INTO PassedExamOrTest FROM Ispytanie
        WHERE Predmet_ID = :OLD.Predmet_ID;
    IF PassedExamOrTest > 0
        THEN RAISE_APPLICATION_ERROR (-20134, 'Нельзя удалить предмет, так как в базе есть сведения о студентах, сдававших его');
        END IF;
END NoSubjDelIfExamOrTest;

--Проверка (не должно сработать, если в таблице Ispytanie есть хоть одна запись)
DELETE FROM Uchebnyi_Predmet
    WHERE Predmet_ID IN (SELECT Predmet_ID
        FROM Ispytanie
        GROUP BY Predmet_ID);