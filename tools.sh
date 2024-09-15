#!/bin/bash

# Color codes for terminal output
RESET="\033[0m"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD="\033[1m"

# Prompt user for the projects directory
read -e -p "$(echo -e "$GREEN""Enter the projects directory: ""$RESET")" -i "/home/$USER/" projects_directory

# Check if the directory exists, if not, prompt to create it
if [ ! -d "$projects_directory" ]; then
    read -p "$(echo -e "$YELLOW""The directory does not exist, do you want to create it? (y/n): ""$RESET")" create_directory
    if [ "$create_directory" == "y" ]; then
        mkdir "$projects_directory"
    else
        echo -e "${RED} Exiting..."
        exit
    fi
fi

# Change to the projects directory
cd "$projects_directory"

# Prompt user for the project name
read -e -p "$(echo -e "$GREEN""Enter the projects name: ""$RESET")" project_name

# Check if the project directory exists, if not, prompt to create it
if [ ! -d "$projects_directory/$project_name" ]; then
    read -p "$(echo -e "$YELLOW""This project does not exist, do you want to create it? (y/n): ""$RESET")" create_project
    if [ "$create_project" == "y" ]; then
        composer create-project --prefer-dist laravel/laravel "$project_name"
    else
        echo -e "${RED} Exiting..."
        exit
    fi
fi

# Initialize flags for Sail and Git
sail=false
git=false

# Check if the project is a Git repository, if not, prompt to initialize it
if [ ! -d "$projects_directory/$project_name/.git" ]; then
    read -p "$(echo -e "$YELLOW""This project is not a git repository, do you want to init it? (y/n): ""$RESET")" init_git
    if [ "$init_git" == "y" ]; then
        cd "$projects_directory/$project_name"
        git init
        git=true
    fi
else
    git=true
fi

# Check if Sail is installed, if not, prompt to install it
if [ ! -d "$projects_directory/$project_name/vendor/laravel/sail" ]; then
    read -p "$(echo -e "$YELLOW""Sail is not installed in this project, do you want to install it? (y/n): ""$RESET")" install_sail
    if [ "$install_sail" == "y" ]; then
        cd "$projects_directory/$project_name"
        composer require laravel/sail --dev
        php artisan sail:install
        ./vendor/bin/sail up -d
        sail=true
    fi
else
    sail=true
    service_name=$(sed -n '2p' "$projects_directory/$project_name/docker-compose.yml" | cut -d':' -f1 | xargs)
    if [ "$(docker ps | grep "$service_name")" ]; then
        sail=true
    else
        read -p "$(echo -e "$YELLOW""Sail is not running, do you want to start it? (y/n): ""$RESET")" start_sail
        if [ "$start_sail" == "y" ]; then
            cd "$projects_directory/$project_name"
            ./vendor/bin/sail up -d
            sail=true
        fi
    fi
fi

# Clear the screen
clear

# Main loop for user interaction
while true; do
    # Display project information
    echo -e "${BOLD}Projects directory:${RESET} $projects_directory ${BOLD}Project name:${RESET} $project_name"
    echo -e "${GREEN}Git ${git^^}${RESET}"
    echo -e "${GREEN}Sail ${sail^^}${RESET}"

    # Display PHP version based on Sail status
    if [ "$sail" == true ]; then
        echo -e "${GREEN}PHP (docker) $(docker exec -it $(docker ps | grep "$service_name" | cut -d' ' -f1) php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")${RESET}"
    else
        if [ "$(php -v)" ]; then
            echo -e "${GREEN}PHP (local) $(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")${RESET}"
        else
            echo -e "${RED}PHP OFF${RESET}"
        fi
    fi

    # Display menu options
    echo -e "${BOLD}Menu:${RESET}"
    [ -f "$projects_directory/$project_name/vendor/bin/pint" ] && echo -e "${CYAN}10. Pint${RESET}"
    [ -f "$projects_directory/$project_name/vendor/bin/pest" ] && echo -e "${CYAN}11. Test --coverage${RESET}"
    [ -f "$projects_directory/$project_name/artisan" ] && echo -e "${CYAN}12. Run artisan command${RESET}"
    [ "$sail" == true ] && echo -e "${CYAN}13. Restart sail${RESET}"
    [ "$git" == true ] && echo -e "${CYAN}20. Git status${RESET}\n${CYAN}21. Git pull${RESET}\n${CYAN}22. Git push${RESET}"
    [ -f "$projects_directory/$project_name/composer.json" ] && echo -e "${CYAN}30. Composer update${RESET}"
    echo -e "${PURPLE}98. Clean screen${RESET}\n${PURPLE}99. Exit${RESET}"

    # Prompt user for menu option
    read -p "$(echo -e "$GREEN""$USER, Choose an option: ""$RESET")" option

    # Handle menu options
    case $option in
        10) cd "$projects_directory/$project_name" && [ "$sail" == true ] && ./vendor/bin/sail pint || ./vendor/bin/pint ;;
        11) cd "$projects_directory/$project_name" && [ "$sail" == true ] && ./vendor/bin/sail test --coverage || ./vendor/bin/phpunit --coverage-text ;;
        12) cd "$projects_directory/$project_name" && read -p "$(echo -e "$GREEN""Enter the artisan command: ""$RESET")" artisan_command && [ "$sail" == true ] && ./vendor/bin/sail artisan "$artisan_command" || php artisan "$artisan_command" ;;
        13) cd "$projects_directory/$project_name" && ./vendor/bin/sail down && ./vendor/bin/sail up -d ;;
        20) cd "$projects_directory/$project_name" && git status ;;
        21) cd "$projects_directory/$project_name" && git pull --rebase ;;
        22) cd "$projects_directory/$project_name" && git add . && read -p "$(echo -e "$GREEN""Enter the commit message: ""$RESET")" commit_message && git commit -m "$commit_message" && git push ;;
        30) cd "$projects_directory/$project_name" && [ "$sail" == true ] && ./vendor/bin/sail composer update || composer update ;;
        98) clear ;;
        99) [ "$sail" == true ] && read -p "$(echo -e "$YELLOW""Do you want to stop sail? (y/n): ""$RESET")" stop_sail && [ "$stop_sail" == "y" ] && cd "$projects_directory/$project_name" && ./vendor/bin/sail down; break ;;
        *) echo -e "${RED}Invalid option${RESET}" ;;
    esac
done