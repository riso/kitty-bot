package controllers

import play.api._
import play.api.mvc._
import play.api.Play._
import play.api.libs.json._
import play.api.data._
import play.api.data.Forms._
import play.api.db.slick._
import play.api.Play.current
import models._
import play.api.libs.EventSource
import play.api.libs.iteratee.{Concurrent, Enumeratee}

object TodoController extends Controller {

  /** Central hub for distributing chat messages */
  val (chatOut, chatChannel) = Concurrent.broadcast[JsValue]

  val todoForm = Form(
    mapping(
      "id" -> optional(longNumber),
      "content" -> nonEmptyText
    )(Todo.apply)(Todo.unapply)
  )

  def index(page: Int) = DBAction { implicit rs =>
    Ok(Json.toJson(Todos.all(offset = 10 * page)))
  }

  def chatFeed() = Action {
	Ok.feed(chatOut &> EventSource()).as("text/event-stream")
  }

  def todoList(id: Long) = DBAction { implicit rs =>
    Ok(Json.toJson(Todos.findById(id)))
  }

  def createTodo = DBAction(parse.json) { implicit rs =>
    rs.body.validate[Todo].map {
      case (todo) => 
	    val json =  Json.toJson(Todos.findById(Todos.create(Todo(None, todo.content.trim))))
		chatChannel.push(json)
		Ok(json)
    }.recoverTotal {
      e => BadRequest(Json.obj("status" ->"KO", "message" -> JsError.toFlatJson(e)))
    }
  }

  def updateTodo(id: Long) = DBAction(parse.json) { implicit rs =>
    rs.body.validate[Todo].map {
      case (todo) => 
	  Todos.update(id, Todo(todo.id, todo.content.trim))
      val json = Json.toJson(todo)
	  chatChannel.push(json)
	  Ok(json)
    }.recoverTotal {
      e => BadRequest(Json.obj("status" ->"KO", "message" -> JsError.toFlatJson(e)))
    }
  }

  def deleteTodo(id: Long) = DBAction { implicit rs =>
    (Todos.delete(id) == 1) match {
      case true => Ok(Json.obj("status" ->"OK", "message" -> ("Record deleted successfully.")))
      case _ => BadRequest(Json.obj("status" ->"KO", "message" -> "Record does not exist."))
    }
  }

}
