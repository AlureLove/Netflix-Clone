package routes

import (
	controller "github.com/AlureLove/Netflix-Clone/Server/MagicStreamMoviesServer/controllers"
	"github.com/AlureLove/Netflix-Clone/Server/MagicStreamMoviesServer/middleware"
	"github.com/gin-gonic/gin"
)

func SetupProtectedRoutes(router *gin.Engine) {
	router.Use(middleware.AuthMiddleWare())

	router.GET("/movie/:imdb_id", controller.GetMovie())
	router.POST("/addmovie", controller.AddMovie())
}
