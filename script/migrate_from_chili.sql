CREATE FOREIGN DATA WRAPPER postgresql VALIDATOR postgresql_fdw_validator;

CREATE SERVER chili
FOREIGN DATA WRAPPER postgresql
OPTIONS (dbname 'chiliproject');

CREATE USER MAPPING FOR redmine SERVER chili OPTIONS (user 'redmine', password 'xxxxxxxx');

SELECT dblink_connect('chili');

-- move auth sources

INSERT INTO auth_sources SELECT * FROM dblink('select * from auth_sources')
AS t1(id integer,
   type character varying(30),
   name character varying(60),
   host character varying(60),
   port integer,
   account character varying(255),
   account_password character varying(255),
   base_dn character varying(255),
   attr_login character varying(30),
   attr_firstname character varying(30),
   attr_lastname character varying(30),
   attr_mail character varying(30),
   onthefly_register boolean,
   tls boolean,
   custom_filter character varying(255)
);

-- move enabled modules
INSERT INTO enabled_modules SELECT * FROM dblink('select * from enabled_modules')
AS t1(
 id integer,
 project_id integer,
 name character varying(255)
 );

-- delete wikis who nees em
DELETE FROM enabled_modules WHERE name = 'wiki';

-- move enumerations
INSERT INTO enumerations SELECT * FROM dblink('select * from enumerations')
AS t1(
   id integer,
   name character varying(30),
   position integer,
   is_default boolean,
   type character varying(255),
   active boolean,
   project_id integer,
   parent_id integer
);

-- move groups_users join table
INSERT INTO groups_users SELECT * FROM dblink('select * from groups_users')
AS t1(
  group_id integer,
  user_id integer
);

-- issue_categories
INSERT INTO issue_categories SELECT * FROM dblink('select * from issue_categories')
AS t1(
 id integer,
 project_id integer,
 name character varying(30),
 assigned_to_id integer               
);

-- issue_relations
INSERT INTO issue_relations SELECT * FROM dblink('select * from issue_relations')
AS t1(
 id integer,
 issue_from_id integer,
 issue_to_id integer,
 relation_type character varying(255),
 delay integer
);

-- issue_statuses
INSERT INTO issue_statuses SELECT * FROM dblink('select * from issue_statuses')
AS t1(
 id integer,
 name character varying(30),
 is_closed boolean,
 is_default boolean,
 position integer,
 default_done_ratio integer
);

-- issues
INSERT INTO issues (
  id,
  tracker_id,
  project_id,
  subject,
  description,
  due_date,
  category_id,
  status_id,
  assigned_to_id,
  priority_id,
  fixed_version_id,
  author_id,
  lock_version,
  created_on,
  updated_on,
  start_date,
  done_ratio,
  estimated_hours,
  parent_id,
  root_id,
  lft,
  rgt,
  start_time,
  end_time
) SELECT * FROM dblink('select * from issues')
AS t1(
 id integer,
 tracker_id integer,
 project_id integer,
 subject character varying(255),
 description text,
 due_date date,
 category_id integer,
 status_id integer,
 assigned_to_id integer,
 priority_id integer,
 fixed_version_id integer,
 author_id integer,
 lock_version integer,
 created_on timestamp,
 updated_on timestamp,
 start_date date,
 done_ratio integer,
 estimated_hours double precision,
 parent_id integer,
 root_id integer,
 lft integer,
 rgt integer,
 start_time timestamp without time zone,
 end_time timestamp without time zone
);

-- journals NOT DONE
INSERT INTO journals (

     id,
     journalized_id,
     user_id,
     notes,
     created_on,
     private_notes    | boolean

  ) SELECT * FROM dblink('select * from journals')
AS t1(
   id integer,
   journaled_id integer,
   user_id integer,
   notes text,
   created_at timestamp without time zone,
   version integer,
   activity_type character varying(255),
   changes text,
   type character varying(255)
);