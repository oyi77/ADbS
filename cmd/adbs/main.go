package main

import (
	"fmt"
	"os"

	"adbs/internal/cli"
	"adbs/internal/models"
)

func main() {
	config := models.LoadConfig()

	if len(os.Args) < 2 {
		showHelp()
		return
	}

	cmd := os.Args[1]

	switch cmd {
	case "setup":
		if err := cli.Setup(config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "new":
		if len(os.Args) < 3 {
			fmt.Fprintf(os.Stderr, "Usage: adbs new <name>\n")
			os.Exit(1)
		}
		name := os.Args[2]
		if err := cli.NewWork(name, config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "status":
		if err := cli.Status(config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "done":
		if len(os.Args) < 3 {
			fmt.Fprintf(os.Stderr, "Usage: adbs done <name>\n")
			os.Exit(1)
		}
		name := os.Args[2]
		if err := cli.Done(name, config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "list":
		if err := cli.List(config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "todo":
		if len(os.Args) < 3 {
			fmt.Fprintf(os.Stderr, "Usage: adbs todo <description>\n")
			os.Exit(1)
		}
		description := os.Args[2]
		if err := cli.Todo(description, config.DataDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "help", "--help", "-h":
		showHelp()

	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n", cmd)
		showHelp()
		os.Exit(1)
	}
}

func showHelp() {
	fmt.Print(`ADbS - AI Don't Be Stupid

Keep your AI focused. Stay organized. Ship faster.

Usage: adbs <command> [options]

Work Management:
  new <name>              Start new feature or fix
  status                   Show current work status
  done <name>             Mark work as complete
  list                     List all work items
  
Task Management:
  todo <description>       Add a task or reminder
  
Setup & Maintenance:
  setup                   Initialize ADbS in current project
  help                    Show this help message

Examples:
  adbs new "user authentication"
  adbs status
  adbs todo "Write tests for login"
  adbs done "user authentication"
`)
}
