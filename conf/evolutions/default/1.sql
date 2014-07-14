# --- Created by Slick DDL
# To stop Slick DDL generation, remove this comment and start using Evolutions

# --- !Ups

create table "TODO" ("id" SERIAL PRIMARY KEY,"content" TEXT NOT NULL);

# --- !Downs

drop table "TODO";

