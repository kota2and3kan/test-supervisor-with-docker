package main

import (
	"fmt"
	"time"
)

func main() {
	for {
		fmt.Println(time.Now())
		fmt.Println("App 1")
		time.Sleep(1 * time.Second)
	}
}
