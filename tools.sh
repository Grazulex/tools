#!/bin/bash
RESET="\033[0m"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'

BOLD="\033[1m"

# this tool is used to managed default commands for my laravel project
# ask for the projects directory
read -e -p "$(echo -e "$GREEN""Enter the projects directory: ""$RESET")" -i "/home/$USER/" projects_directory

#check if the directory exists, if not ask if need to create it
if [ ! -d "$projects_directory" ]; then
    read -p "$(echo -e "$YELLOW""The directory does not exist, do you want to create it? (y/n): ""$RESET")" create_directory
    if [ $create_directory == "y" ]; then
        mkdir $projects_directory
    else
        echo -e "${RED} Exiting..."
        exit
    fi
fi

cd $projects_directory
# ask for the project name
read -e -p "$(echo -e "$GREEN""Enter the projects name: ""$RESET")" project_name

# check if the project exists in the projects_directory, if not ask if need to create it
if [ ! -d "$projects_directory/$project_name" ]; then
    read -p "$(echo -e "$YELLOW""This project does not exist, do you want to create it? (y/n): ""$RESET")" create_project
    if [ $create_project == "y" ]; then
        cd $projects_directory
        composer create-project --prefer-dist laravel/laravel $project_name
    else
        echo -e "${RED} Exiting..."
        exit
    fi
fi

sail=false
git=false

# check if git is actif in the project, if not ask if need to init it
if [ ! -d "$projects_directory/$project_name/.git" ]; then
    read -p "$(echo -e "$YELLOW""This project is not a git repository, do you want to init it? (y/n): ""$RESET")" init_git
    if [ $init_git == "y" ]; then
        cd $projects_directory/$project_name
        git init
        git=true
    fi
else
    git=true
fi

#check if sail is present in the project (composer), if not ask if need to install it
if [ ! -d "$projects_directory/$project_name/vendor/laravel/sail" ]; then
    read -p "$(echo -e "$YELLOW""Sail is not installed in this project, do you want to install it? (y/n): ""$RESET")" install_sail
    if [ $install_sail == "y" ]; then
        cd $projects_directory/$project_name
        composer require laravel/sail --dev
        php artisan sail:install
        ./vendor/bin/sail up -d
        sail=true
    fi
else
  sail=true
  #in the projects directory + project name, read the docker-compose.yml file and get the name of teh first service. exemple: laravel.test 'is on the second line after service:'
  service_name=$(sed -n '2p' $projects_directory/$project_name/docker-compose.yml | cut -d':' -f1 | xargs)
  #check with docker ps if the service is running
  if [ "$(docker ps | grep $service_name)" ]; then
    sail=true
  else
    read -p "$(echo -e "$YELLOW""Sail is not running, do you want to start it? (y/n): ""$RESET")" start_sail
    if [ $start_sail == "y" ]; then
        cd $projects_directory/$project_name
        ./vendor/bin/sail up -d
        sail=true
    fi
  fi
fi

#clean the screen
#clear

#make a loop to show the menu until the user exit with 'q'
while true; do
  ##Welcome the user with his current_user name, current date and time, projects directory(bold) and project name(bold) in one line sentence
  echo -e "${BOLD}Projects directory:${RESET} $projects_directory ${BOLD}Project name:${RESET} $project_name"
  #show if git and sail are installed
  if [ $git == true ]; then
      echo -e "${GREEN}Git ON${RESET}"
  else
      echo -e "${RED}Git OFF${RESET}"
  fi

  if [ $sail == true ]; then
      echo -e "${GREEN}Sail ON${RESET}"
      ##Show PHP version from sail
      echo -e "${GREEN}PHP (docker) $(docker exec -it $(docker ps | grep $service_name | cut -d' ' -f1) php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")${RESET}"
  else
      echo -e "${RED}Sail OFF${RESET}"
      ##check if PHP is installed, if yes, show the version
      if [ "$(php -v)" ]; then
          echo -e "${GREEN}PHP (local) $(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")${RESET}"
      else
          echo -e "${RED}PHP OFF${RESET}"
      fi
  fi

    echo -e "${BOLD}Menu:${RESET}"
    echo -e "${BLUE}----------------------${RESET}"
    echo -e "${CYAN}10. Pint${RESET}"
    echo -e "${CYAN}11. Test --coverage${RESET}"
    echo -e "${CYAN}12. Run artisan command${RESET}"
    if [ $sail == true ]; then
      echo -e "${CYAN}13. Restart sail${RESET}"
    fi
    if [ $git == true ]; then
      echo -e "${BLUE}----------------------${RESET}"
      echo -e "${CYAN}20. Git status${RESET}"
      echo -e "${CYAN}21. Git pull${RESET}"
      echo -e "${CYAN}22. Git push${RESET}"
    fi
    echo -e "${BLUE}----------------------${RESET}"
    echo -e "${CYAN}30. Composer update${RESET}"
    echo -e "${BLUE}----------------------${RESET}"
    echo -e "${PURPLE}98. Clean screen${RESET}"
    echo -e "${PURPLE}99. Exit${RESET}"
    echo -e "${BLUE}----------------------${RESET}"
    read -p "$(echo -e "$GREEN""$USER, Choose an option: ""$RESET")" option
    case $option in
        10)
            cd $projects_directory/$project_name
            if [ $sail == true ]; then
                ./vendor/bin/sail pint
            else
                ./vendor/bin/pint
            fi
            ;;
        11)
            cd $projects_directory/$project_name
            if [ $sail == true ]; then
                ./vendor/bin/sail test --coverage
            else
                ./vendor/bin/phpunit --coverage-text
            fi
            ;;
        12)
            cd $projects_directory/$project_name
            read -p "$(echo -e "$GREEN""Enter the artisan command: ""$RESET")" artisan_command
            if [ $sail == true ]; then
                ./vendor/bin/sail artisan $artisan_command
            else
                php artisan $artisan_command
            fi
            ;;
        13)
            cd $projects_directory/$project_name
            ./vendor/bin/sail down
            ./vendor/bin/sail up -d
            ;;
        20)
            cd $projects_directory/$project_name
            git status
            ;;
        21)
            cd $projects_directory/$project_name
            git pull --rebase
            ;;
        22)
            cd $projects_directory/$project_name
            git add .
            read -p "$(echo -e "$GREEN""Enter the commit message: ""$RESET")" commit_message
            git commit -m "$commit_message"
            git push
            ;;
        30)
            cd $projects_directory/$project_name
            composer update
            ;;
        98)
            clear
            ;;
        99)
            #ask if need to close sail
            if [ $sail == true ]; then
                read -p "$(echo -e "$YELLOW""Do you want to stop sail? (y/n): ""$RESET")" stop_sail
                if [ $stop_sail == "y" ]; then
                    cd $projects_directory/$project_name
                    ./vendor/bin/sail down
                fi
            fi
            break
            ;;
        *)
            echo -e "${RED}Invalid option${RESET}"
            ;;
    esac
done

