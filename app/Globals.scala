import play.api._
import play.api.mvc.WithFilters
import play.api.mvc.EssentialAction
import play.api.db.slick._
import play.api.Play.current
import models._
import play.filters.headers.SecurityHeadersFilter
import scala.concurrent.ExecutionContext.Implicits.global

object Global extends WithFilters(SecurityHeadersFilter()) with  GlobalSettings {

	override def onStart(app: Application) {
		InitialData.insert()
	}

	object InitialData {
		def insert() = {
			DB.withSession { implicit s:Session =>
				println(s)
			}
		}
	}

	override def doFilter(action: EssentialAction): EssentialAction = EssentialAction { 
		request => action.apply(request).map(_.withHeaders("Access-Control-Allow-Origin" -> "*"))
	}
}
