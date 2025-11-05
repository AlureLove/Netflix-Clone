package main

import (
	"fmt"

	"github.com/AlureLove/Netflix-Clone/Server/MagicStreamMoviesServer/routes"
	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()

	router.GET("/hello", func(c *gin.Context) {
		c.String(200, "Hello, MagicStreamMovies!")
	})

	routes.SetupProtectedRoutes(router)
	routes.SetupUnProtectedRoutes(router)
	
	if err := router.Run(":8081"); err != nil {
		fmt.Println("Failed to start server:", err)
	}
}
