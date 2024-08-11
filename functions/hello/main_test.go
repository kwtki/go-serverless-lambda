package main

import (
	"context"
	"os"
	"testing"
)

func TestHandleRequest(t *testing.T) {
	// Set up the environment variable for the test
	os.Setenv("STAGE", "TEST")

	// Create a sample event
	event := MyEvent{
		Name: "World",
	}

	// Call the function
	response, err := HandleRequest(context.TODO(), event)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Check the response
	expected := "Hello World. This is stage:TEST"
	if response != expected {
		t.Errorf("Expected %s, got %s", expected, response)
	}
}
