--The 'update_is_following()'' function updates the is_following array in the profiles table by appending the author_id when a new row is inserted into the following table, provided the user_id exists in the profiles table.

CREATE FUNCTION update_is_following()
RETURNS trigger AS
$$
BEGIN
    -- Check if the user_id exists in the profiles table
    IF EXISTS (SELECT 1 FROM profiles WHERE id = NEW.user_id) THEN
        -- Add the author_id to the is_following array in the profiles table
        UPDATE profiles
        SET is_following = array_append(is_following, NEW.author_id)
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



--The 'remove_is_following()' function updates the is_following array in the profiles table by removing the author_id when a row is deleted from the following table, provided the user_id exists in the profiles table.

CREATE FUNCTION remove_is_following()
RETURNS trigger AS
$$
BEGIN
    -- Check if the user_id exists in the profiles table
    IF EXISTS (SELECT 1 FROM profiles WHERE id = OLD.user_id) THEN
        -- Remove the author_id from the is_following array in the profiles table
        UPDATE profiles
        SET is_following = array_remove(is_following, OLD.author_id)
        WHERE id = OLD.user_id;
    END IF;
    RETURN OLD;
END;
$$
LANGUAGE plpgsql;


