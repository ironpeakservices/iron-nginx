package main

import (
	"fmt"
	"net/http"
	"os"
)

const (
	host = "localhost"
	uri  = "_health"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <port>\n", os.Args[0])
		os.Exit(1)
	}

	resp, err := http.Get(fmt.Sprintf("http://%s:%s/%s", host, os.Args[1], uri))
	if err != nil {
		fmt.Printf("Error: could not query %s:%s: %+v\n", host, os.Args[1], err)
		os.Exit(1)
	}

	defer resp.Body.Close()

	if resp.StatusCode > 399 {
		fmt.Printf("Error: status code returned was %d\n", resp.StatusCode)
		os.Exit(1)
	}

	// exit 0
}
