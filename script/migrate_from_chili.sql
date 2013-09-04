-- superuser required for this stuff. Make wrapper, server, user mapping, connect
CREATE EXTENSION dblink;

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

-- journals
INSERT INTO journals (
     id,
     journalized_id,
     user_id,
     notes,
     created_on,
     journalized_type
  ) SELECT * FROM dblink('select id,journaled_id,user_id,notes,created_at,type from journals')
AS t1(
   id integer,
   journaled_id integer,
   user_id integer,
   notes text,
   created_at timestamp without time zone,
   type character varying(255)
);

-- make the journalized_type work right
UPDATE journals SET journalized_type = trim(trailing 'Journal' from journalized_type);

-- need to populate journal_details. In sha'Allah, we can do this in ruby.

-- levels
INSERT INTO levels SELECT * FROM dblink('select * from levels')
AS t1(
 id integer,
 skill_id integer,
 user_id integer,
 rating integer,
 created_at timestamp without time zone,
 updated_at timestamp without time zone
);

-- member_roles

INSERT INTO member_roles SELECT * FROM dblink('select * from member_roles')
AS t1(
 id integer,
 member_id integer,
 role_id integer,
 inherited_from integer
);

-- members

INSERT INTO members SELECT * FROM dblink('select * from members')
AS t1(
 id integer,
 user_id integer,
 project_id integer,
 created_on timestamp without time zone,
 mail_notification boolean
);

-- projects

INSERT INTO projects (
 id,
 name,
 description,
 homepage,
 is_public,
 parent_id,
 created_on,
 updated_on,
 identifier,
 status,
 lft,
 rgt,
 suppress_email
) SELECT * FROM dblink('select * from projects')
AS t1(
 id integer,
 name character varying(255),
 description text,
 homepage character varying(255),
 is_public boolean,
 parent_id integer,
 created_on timestamp without time zone,
 updated_on timestamp without time zone,
 identifier character varying(255),
 status integer,
 lft integer,
 rgt integer,
 suppress_email boolean
);

-- projects_trackers

INSERT INTO projects_trackers SELECT * FROM dblink('select * from projects_trackers')
AS t1(
  project_id integer,
  tracker_id integer
);

-- queries Don't do

-- repairs

INSERT INTO repairs SELECT * FROM dblink('select * from repairs')
AS t1(
 id integer,
 issue_id integer,
 item_number integer,
 item_desc character varying(255),
 problem_desc text,
 patron_name character varying(255),
 patron_phone character varying(255),
 patron_email character varying(255),
 patron_jhed character varying(255),
 checkout integer,
 notes text,
 created_at timestamp without time zone,
 updated_at timestamp without time zone,
 user_id integer
);

-- roles

-- first, get rid of defaults
TRUNCATE roles;

INSERT INTO roles SELECT * FROM dblink('select * from roles')
AS t1(
 id integer,
 name character varying(30),
 position integer,
 assignable boolean,
 builtin integer,
 permissions text
);

-- settings this should be checked later...
INSERT INTO settings SELECT * FROM dblink('select * from settings')
AS t1(
 id integer,
 name character varying(255),
 value text,
 updated_on timestamp without time zone
);


-- skills
INSERT INTO skills SELECT * FROM dblink('select * from skills')
AS t1(
 id integer,
 name character varying(255),
 skillcat_id integer
);

-- skillcats
INSERT INTO skillcats SELECT * FROM dblink('select * from skillcats')
AS t1(
 id integer,
 name character varying(255),
 descr text
);

-- time_entries (maybe don't do this)
-- timesheets (maybe don't)

-- tokens (safe?)
INSERT INTO tokens SELECT * FROM dblink('select * from tokens')
AS t1(
 id integer,
 user_id integer,
 action character varying(30),
 value character varying(40),
 created_on timestamp without time zone
);


-- trackers
INSERT INTO trackers SELECT * FROM dblink('select * from trackers')
AS t1(
 id integer,
 name character varying(30),
 is_in_chlog boolean,
 position integer,
 is_in_roadmap boolean
);

-- user_preferences
INSERT INTO user_preferences SELECT * FROM dblink('select * from user_preferences')
AS t1(
 id integer,
 user_id integer,
 others text,
 hide_mail boolean,
 time_zone character varying(255)
);


-- users

-- first, clear...
TRUNCATE users;

INSERT INTO users (
 id,
 login,
 hashed_password,
 firstname,
 lastname,
 mail,
 admin,
 status,
 last_login_on,
 language,
 auth_source_id,
 created_on,
 updated_on,
 type,
 identity_url,
 mail_notification,
 salt,
 manager_id,
 digest
  ) SELECT * FROM dblink('select * from users')
AS t1(
 id integer,
 login character varying(255),
 hashed_password character varying(40),
 firstname character varying(30),
 lastname character varying(255),
 mail character varying(60),
 admin boolean,
 status integer,
 last_login_on timestamp without time zone,
 language character varying(5),
 auth_source_id integer,
 created_on timestamp without time zone,
 updated_on timestamp without time zone,
 type character varying(255),
 identity_url character varying(255),
 mail_notification character varying(255),
 salt character varying(64),
 manager_id integer,
 digest boolean
);

-- wages  get it without amount_cents
INSERT INTO wages (
  id,
  user_id,
  created_at,
  updated_at
  ) SELECT * FROM dblink('select id,user_id,created_at,updated_at from wages')
AS t1(
 id integer,
 user_id integer,
 created_at timestamp without time zone,
 updated_at timestamp without time zone
);
-- set amount_cents for manual assignment later
UPDATE wages SET amount_cents = 1200;

-- watchers
INSERT INTO watchers SELECT * FROM dblink('select * from watchers')
AS t1(
 id integer,
 watchable_type character varying(255),
 watchable_id integer,
 user_id integer
);

-- workflows .. some strangeness here
INSERT INTO workflows SELECT * FROM dblink('select * from workflows')
AS t1(
 id integer,
 tracker_id integer,
 old_status_id integer,
 new_status_id integer,
 role_id integer,
 assignee boolean,
 author boolean
);
UPDATE workflows SET type = 'WorkflowTransition';
