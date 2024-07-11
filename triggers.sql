--The 'following_insert_trigger' trigger is designed to execute the update_is_following() function after each new row is inserted into the following table.

CREATE TRIGGER following_insert_trigger
AFTER INSERT ON following
FOR EACH ROW
EXECUTE FUNCTION update_is_following();

-- Trigger Name: following_insert_trigger
-- Event: AFTER INSERT ON following
-- 	The trigger activates after a new row is inserted into the following table.
-- Operation: FOR EACH ROW
-- 	The trigger operates for each row that is inserted.
-- Action: EXECUTE FUNCTION update_is_following()
-- 	The trigger executes the update_is_following() function after each insert.

---------------------------------------------------------------------------------------------------------------------------------------------------------



--The 'following_delete_trigger' trigger is designed to execute the remove_is_following() function after each row is deleted from the following table.

CREATE TRIGGER following_delete_trigger
AFTER DELETE ON following
FOR EACH ROW
EXECUTE FUNCTION remove_is_following();

--Trigger Name: following_delete_trigger	
--Event: AFTER DELETE ON following
-- 	The trigger activates after a row is deleted from the following table.
--Operation: FOR EACH ROW
-- 	The trigger operates for each row that is deleted.
--Action: EXECUTE FUNCTION remove_is_following()
--	The trigger executes the remove_is_following() function after each delete.
