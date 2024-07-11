--This SQL script creates a table named posts with various columns and constraints.
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_title TEXT,
    post_author UUID REFERENCES auth.users(id),
    post_body TEXT,
    post_author_name TEXT,
    testaments TEXT,
    old_testament_book TEXT,
    new_testament_book TEXT,
    post_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    book_name TEXT,
    post_comments INT[],
    post_subtitle TEXT
);





--This script creates a new authors table and populates it with data from the profiles table, but only for profiles where is_author is true.
CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

-- Populate the authors table with data from the profiles table where is_author is true
INSERT INTO authors (author_id, first_name, last_name)
	SELECT id, first_name, last_name
	FROM profiles
	WHERE is_author = TRUE;




--This script creates the 'follwing' table that's designed to track which users are following which authors. It includes a unique identifier for each follow action, references to the user and author being followed, and a timestamp indicating when the follow action occurred.
CREATE TABLE following (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id),
    author_id UUID REFERENCES profiles(id),
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--This script creates the 'comments' table which is designed to store information about comments made by users on posts, including the comment's unique ID, associated post and commenter IDs, text content, and creation timestamp.
CREATE TABLE comments (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(id),
    commenter_id UUID REFERENCES auth.users(id),
    comment_text TEXT,
    comment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);



--This script creates the 'replies' table which is designed to store information about replies made by users to comments, including the reply's unique ID, associated comment and replier IDs, text content, and creation timestamp.
CREATE TABLE replies (
    reply_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID REFERENCES comments(comment_id),
    replier_id UUID REFERENCES auth.users(id),
    reply_text TEXT,
    reply_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);