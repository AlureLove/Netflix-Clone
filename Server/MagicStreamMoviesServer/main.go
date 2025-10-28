package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()

	router.GET("/hello", func(c *gin.Context) {
		c.String(200, "Hello, MagicStreamMovies!")
	})

	if err := router.Run(":8081"); err != nil {
		fmt.Println("Failed to start server:", err)
	}
}
