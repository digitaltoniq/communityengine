CREATE TABLE `activities` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `action` varchar(50) default NULL,
  `item_id` int(11) default NULL,
  `item_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_activities_on_created_at` (`created_at`),
  KEY `index_activities_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=297 DEFAULT CHARSET=utf8;

CREATE TABLE `ads` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `html` text,
  `frequency` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `start_date` datetime default NULL,
  `end_date` datetime default NULL,
  `location` varchar(255) default NULL,
  `published` tinyint(1) default '0',
  `time_constrained` tinyint(1) default '0',
  `audience` varchar(255) default 'all',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `albums` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `description` text,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `view_count` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `assets` (
  `id` int(11) NOT NULL auto_increment,
  `filename` varchar(255) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `content_type` varchar(255) default NULL,
  `size` int(11) default NULL,
  `attachable_type` varchar(255) default NULL,
  `attachable_id` int(11) default NULL,
  `updated_at` datetime default NULL,
  `created_at` datetime default NULL,
  `thumbnail` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `tips` text,
  `new_post_text` varchar(255) default NULL,
  `nav_text` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `choices` (
  `id` int(11) NOT NULL auto_increment,
  `poll_id` int(11) default NULL,
  `description` varchar(255) default NULL,
  `votes_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `clippings` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `image_url` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `favorited_count` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_clippings_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(50) default '',
  `created_at` datetime NOT NULL,
  `commentable_id` int(11) NOT NULL default '0',
  `commentable_type` varchar(15) NOT NULL default '',
  `user_id` int(11) NOT NULL default '0',
  `recipient_id` int(11) default NULL,
  `comment` text,
  `author_name` varchar(255) default NULL,
  `author_email` varchar(255) default NULL,
  `author_url` varchar(255) default NULL,
  `author_ip` varchar(255) default NULL,
  `notify_by_email` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  KEY `fk_comments_user` (`user_id`),
  KEY `index_comments_on_recipient_id` (`recipient_id`),
  KEY `index_comments_on_created_at` (`created_at`),
  KEY `index_comments_on_commentable_type` (`commentable_type`),
  KEY `index_comments_on_commentable_id` (`commentable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8;

CREATE TABLE `companies` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(60) NOT NULL default '',
  `description` text,
  `logo_id` int(11) default NULL,
  `view_count` int(11) default '0',
  `state_id` int(11) default NULL,
  `country_id` int(11) default NULL,
  `metro_area_id` int(11) default NULL,
  `profile_public` tinyint(1) default NULL,
  `zip` varchar(255) default NULL,
  `url_slug` varchar(255) default NULL,
  `domains` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `contests` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `begin_date` datetime default NULL,
  `end_date` datetime default NULL,
  `raw_post` text,
  `post` text,
  `banner_title` varchar(255) default NULL,
  `banner_subtitle` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=221 DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `user_id` int(11) default NULL,
  `start_time` datetime default NULL,
  `end_time` datetime default NULL,
  `description` text,
  `metro_area_id` int(11) default NULL,
  `location` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `favorites` (
  `id` int(11) NOT NULL auto_increment,
  `updated_at` datetime default NULL,
  `created_at` datetime default NULL,
  `favoritable_type` varchar(255) default NULL,
  `favoritable_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `ip_address` varchar(255) default '',
  PRIMARY KEY  (`id`),
  KEY `fk_favorites_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `followings` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `followee_id` int(11) default NULL,
  `followee_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `forums` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `topics_count` int(11) default '0',
  `sb_posts_count` int(11) default '0',
  `position` int(11) default NULL,
  `description_html` text,
  `owner_type` varchar(255) default NULL,
  `owner_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `friendship_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `friendships` (
  `id` int(11) NOT NULL auto_increment,
  `friend_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `initiator` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `friendship_status_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_friendships_on_user_id` (`user_id`),
  KEY `index_friendships_on_friendship_status_id` (`friendship_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `homepage_features` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `url` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `updated_at` datetime default NULL,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `thumbnail` varchar(255) default NULL,
  `size` int(11) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL auto_increment,
  `email_addresses` varchar(255) default NULL,
  `message` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `logos` (
  `id` int(11) NOT NULL auto_increment,
  `company_id` int(11) default NULL,
  `filename` varchar(255) default NULL,
  `content_type` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `thumbnail` varchar(255) default NULL,
  `size` int(11) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `sender_id` int(11) default NULL,
  `recipient_id` int(11) default NULL,
  `sender_deleted` tinyint(1) default '0',
  `recipient_deleted` tinyint(1) default '0',
  `subject` varchar(255) default NULL,
  `body` text,
  `read_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `metro_areas` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `state_id` int(11) default NULL,
  `country_id` int(11) default NULL,
  `users_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=273 DEFAULT CHARSET=utf8;

CREATE TABLE `moderatorships` (
  `id` int(11) NOT NULL auto_increment,
  `forum_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_moderatorships_on_forum_id` (`forum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `monitorships` (
  `id` int(11) NOT NULL auto_increment,
  `topic_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `offerings` (
  `id` int(11) NOT NULL auto_increment,
  `skill_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `user_id` int(11) default NULL,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `size` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `thumbnail` varchar(255) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `album_id` int(11) default NULL,
  `view_count` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_photos_on_parent_id` (`parent_id`),
  KEY `index_photos_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8;

CREATE TABLE `plugin_schema_migrations` (
  `plugin_name` varchar(255) default NULL,
  `version` varchar(255) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `polls` (
  `id` int(11) NOT NULL auto_increment,
  `question` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `post_id` int(11) default NULL,
  `votes_count` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_polls_on_created_at` (`created_at`),
  KEY `index_polls_on_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `raw_post` text,
  `post` text,
  `title` varchar(255) default NULL,
  `category_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `view_count` int(11) default '0',
  `contest_id` int(11) default NULL,
  `emailed_count` int(11) default '0',
  `favorited_count` int(11) default '0',
  `published_as` varchar(16) default 'draft',
  `published_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_posts_on_category_id` (`category_id`),
  KEY `index_posts_on_published_at` (`published_at`),
  KEY `index_posts_on_published_as` (`published_as`),
  KEY `index_posts_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;

CREATE TABLE `representative_invitations` (
  `id` int(11) NOT NULL auto_increment,
  `email_addresses` varchar(255) default NULL,
  `message` varchar(255) default NULL,
  `representative_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `representative_roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `representatives` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `company_id` int(11) default NULL,
  `title` varchar(255) default NULL,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `url_slug` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `representative_role_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `rsvps` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `event_id` int(11) default NULL,
  `attendees_count` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sb_posts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `topic_id` int(11) default NULL,
  `body` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `forum_id` int(11) default NULL,
  `body_html` text,
  PRIMARY KEY  (`id`),
  KEY `index_sb_posts_on_forum_id` (`forum_id`,`created_at`),
  KEY `index_sb_posts_on_user_id` (`user_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `sessid` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_sessid` (`sessid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `skills` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `states` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8;

CREATE TABLE `static_pages` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `content` text,
  `active` tinyint(1) default '0',
  `visibility` varchar(255) default 'Everyone',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) default NULL,
  `taggable_id` int(11) default NULL,
  `taggable_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_type` (`taggable_type`),
  KEY `index_taggings_on_taggable_id` (`taggable_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type` (`taggable_id`,`taggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `topics` (
  `id` int(11) NOT NULL auto_increment,
  `forum_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `hits` int(11) default '0',
  `sticky` int(11) default '0',
  `sb_posts_count` int(11) default '0',
  `replied_at` datetime default NULL,
  `locked` tinyint(1) default '0',
  `replied_by` int(11) default NULL,
  `last_post_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_topics_on_forum_id` (`forum_id`),
  KEY `index_topics_on_sticky_and_replied_at` (`forum_id`,`sticky`,`replied_at`),
  KEY `index_topics_on_forum_id_and_replied_at` (`forum_id`,`replied_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `description` text,
  `avatar_id` int(11) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `stylesheet` text,
  `view_count` int(11) default '0',
  `vendor` tinyint(1) default '0',
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `state_id` int(11) default NULL,
  `metro_area_id` int(11) default NULL,
  `login_slug` varchar(255) default NULL,
  `notify_comments` tinyint(1) default '1',
  `notify_friend_requests` tinyint(1) default '1',
  `notify_community_news` tinyint(1) default '1',
  `country_id` int(11) default NULL,
  `featured_writer` tinyint(1) default '0',
  `last_login_at` datetime default NULL,
  `zip` varchar(255) default NULL,
  `birthday` date default NULL,
  `gender` varchar(255) default NULL,
  `profile_public` tinyint(1) default '1',
  `activities_count` int(11) default '0',
  `sb_posts_count` int(11) default '0',
  `sb_last_seen_at` datetime default NULL,
  `role_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_avatar_id` (`avatar_id`),
  KEY `index_users_on_featured_writer` (`featured_writer`),
  KEY `index_users_on_activated_at` (`activated_at`),
  KEY `index_users_on_vendor` (`vendor`),
  KEY `index_users_on_login_slug` (`login_slug`),
  KEY `index_users_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `poll_id` int(11) default NULL,
  `choice_id` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20090728141518');

INSERT INTO schema_migrations (version) VALUES ('20090729213942');

INSERT INTO schema_migrations (version) VALUES ('20090730195219');

INSERT INTO schema_migrations (version) VALUES ('20090801171818');

INSERT INTO schema_migrations (version) VALUES ('20090801214622');

INSERT INTO schema_migrations (version) VALUES ('20090807231721');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');