
# --- !Ups

create table "TODO" ("id" SERIAL PRIMARY KEY,"content" TEXT NOT NULL);

# --- !Downs

drop table "TODO";
