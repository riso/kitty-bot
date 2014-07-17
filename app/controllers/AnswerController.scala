package controllers

import play.api._
import play.api.mvc._
import play.api.Play._
import play.api.libs.json._
import play.api.libs.ws._
import play.api.data._
import play.api.data.Forms._
import play.api.db.slick._
import play.api.Play.current
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.Random
import models._

object AnswerController extends Controller {

  val answers = List("\"Meow!\"", "\"Purr\"")

  def generateAnswer(xs: List[String], r: Int): Future[Result]= xs match {
	case x :: xs => r match {
		case 0 => Future {Ok(Json.toJson(Answer(None, x)))}
		case _ => generateAnswer(xs, r - 1)
	}
	case Nil => r match {
		case 1 => WS.url("http://catfacts-api.appspot.com/api/facts").get().map { response =>
	      val json = Json.parse(response.body)
		  val fact = (json \ "facts")(0)
	      Ok(Json.toJson(Answer(None, fact toString))) 
		}
		case 0 => WS.url("http://thecatapi.com/api/images/get?format=xml").get().map { response =>
		  val url = response.xml \\ "url"
		  Ok(Json.toJson(Answer(None, "<img src='" + url.text + "'/>")))
		}
	  }
  }

  def index = Action.async { 
	generateAnswer(answers, new Random().nextInt(answers.length + 2))
  }

}
