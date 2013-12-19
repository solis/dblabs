-- Триггер должен проверять следующее условие: одновременно с одной лошадью не могут работать
-- несколько жокеев (однако какое-то время за лошадью может быть не закреплено ни одного жокея).
CREATE OR REPLACE TRIGGER CHECK_HORSE_RIDER
    BEFORE DELETE OR UPDATE JOCKEY_ID
    ON HORSES
DECLARE

BEGIN

END CHECK_HORSE_RIDER