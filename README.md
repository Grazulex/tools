# Laravel Project Management Script

This script is designed to help manage Laravel projects with ease by automating some commonly used commands such as project creation, Sail management, Git initialization, and more.

## Features

- Set up Laravel projects quickly by specifying the project directory and name.
- Automatically check if the project and directory exist; if not, prompts to create them.
- Initialize Git repositories if not already set up.
- Install and manage Laravel Sail, including starting, stopping, and checking the status of the service.
- Run PHP commands in the local or Sail environment.
- Simple menu-driven interface for interacting with common Laravel, Git, and Sail commands.

## Requirements

- Laravel installed globally (for project creation).
- Composer installed on your system.
- Docker installed for using Laravel Sail.
- Git for version control management.

## Installation

To use the script:

1. Clone or download the repository.
2. Give execution permissions to the script:

    ```bash
    chmod +x tools.sh
    ```

3. Run the script:

    ```bash
    ./tools.sh
    ```

## Usage

Upon running the script, you will be prompted to enter the project directory and project name. If they do not exist, the script will give you options to create them. From there, you'll have access to the following features:

### Main Features:
- **Git Management**: Check the repository status, pull changes, and push commits.
- **Sail Management**: Start or stop Sail, check PHP versions, and restart Sail services.
- **Artisan Commands**: Run any Artisan commands from the script menu.
- **Testing**: Run Pint or PHP tests (if configured in the project).
- **Composer**: Update Composer dependencies directly from the menu.

### Menu

Once in the menu, you will see options like:

- **10. Pint**: Runs code linting using Pint (if available).
- **11. Test --coverage**: Runs tests with coverage.
- **12. Run Artisan command**: Execute custom Laravel Artisan commands.
- **13. Restart Sail**: Restarts the Laravel Sail containers.
- **20-22**: Git status, pull, and push commands.
- **30. Composer update**: Update your Composer packages.

### Exiting

You can exit the script by selecting option `99`, and you'll be asked if you want to stop Sail before exiting.

## Customization

You can adjust the script for your specific needs, such as modifying the default directory path, customizing commands, or adding new menu options for other tasks.

## Contributions

Feel free to fork this repository and contribute by opening a pull request. All contributions are welcome.

## License

This project is licensed under the MIT License.
