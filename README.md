Overview
This project contains SQL scripts for creating and managing a database structure that tracks users, authors, posts, comments, and following relationships. The database includes various tables, triggers, and functions designed to maintain and update data integrity automatically.

Tables:

  profiles:
    Stores user profile information, including whether a user is an author.

  authors:
    Tracks authors based on profiles.

  following:
    Tracks which users are following which authors.

  posts:
    Stores information about posts created by users.

  comments:
    Stores comments on posts.

  replies:
    Stores replies to comments.


Triggers:

  following_insert_trigger
    Executes after a row is inserted into the following table.

  following_delete_trigger
    Executes after a row is deleted from the following table.


Functions:
  update_is_following()
    Updates the is_following array in the profiles table when a new follow relationship is added.

  remove_is_following()
    Updates the is_following array in the profiles table when a follow relationship is removed.
