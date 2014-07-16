package models

import play.api._
import play.api.Play.current
import play.api.libs.json._
import scala.slick.lifted.Tag
import play.api.db.slick.Config.driver.simple._

case class Answer(id: Option[Long] = None, content: String)

object Answer {
  implicit val todoFmt = Json.format[Answer]
}
