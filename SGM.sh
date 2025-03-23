#!/bin/bash
# Jan Gebser - Brainhub24.com
# Email: github@brainhub24.com
# About this Tool:
# - It will an effective fast tool to simply grand regular users SUDO Power!
# Improvements:
# - Nothing atm, more improvements will come soon maybe

display_dragon() {
    clear
    echo -e "\033[1;32m" # I like the Hackers Green color! :D
    cat << "EOF"
+=======================================+
| ____  _   _ ____   ___                |
|/ ___|| | | |  _ \ / _ \     [SGM v.1.0|
|\___ \| | | | | | | | | |              |
| ___) | |_| | |_| | |_| |              |
||____/ \___/|____/ \___/  _ ____       |
| / ___|  _ \    / \  | \ | |  _ \      |
|| |  _| |_) |  / _ \ |  \| | | | |     |
|| |_| |  _ <  / ___ \| |\  | |_| |     |
| \____|_| \_\/_/___\_\_|_\_|____/____  |
||  \/  |  / \  / ___|_   _| ____|  _ \ |
|| |\/| | / _ \ \___ \ | | |  _| | |_) ||
|| |  | |/ ___ \ ___) || | | |___|  _ < |
||_|  |_/_/   \_\____/ |_| |_____|_| \_\|
+=======================================+
EOF
    sleep 1
    clear
    cat << "EOF"
                            ==(W{==========-      /===-
                              ||  (.--.)         /===-_---~~~~~~~~~------____
                              | \_,|**|,__      |===-~___                _,-' `
                 -==\\        `\ ' `--'   ),    `//~\\   ~~~~`---.___.-~~
             ______-==|        /`\_. .__/\ \    | |  \\           _-~`
       __--~~~  ,-/-==\\      (   | .  |~~~~|   | |   `\        ,'
    _-~       /'    |  \\     )__/==0==-\<>/   / /      \      /
  .'        /       |   \\      /~\___/~~\/  /' /        \   /'
 /  ____  /         |    \`\.__/-~~   \  |_/'  /          \/'
/-'~    ~~~~~---__  |     ~-/~         ( )   /'        _--~`
                  \_|      /        _) | ;  ),   __--~~
                    '~~--_/      _-~/- |/ \   '-~ \
                   {\__--_/}    / \\_>-|)<__\      \
                   /'   (_/  _-~  | |__>--<__|      |
                  |   _/) )-~     | |__>--<__|      |
                  / /~ ,_/       / /__>---<__/      |
                 o-o _//        /-~_>---<__-~      /
                 (^(~          /~_>---<__-      _-~
                ,/|           /__>--<__/     _-~
             ,//('(          |__>--<__|     /  - BRAINHUB24 -  .----_
            ( ( '))          |__>--<__|    |                 /' _---_~\
         `-)) )) (           |__>--<__|    |               /'  /     ~\`\
        ,/,'//( (             \__>--<__\    \            /'  //        ||
      ,( ( ((, ))              ~-__>--<_~-_  ~--____---~' _/'/        /'
    `~/  )` ) ,/|                 ~-_~>--<_/-__       __-~ _/
  ._-~//( )/ )) `                    ~~-'_/_/ /~~~~~~~__--~
   ;'( ')/ ,)(                              ~~~~~~~~~~
  ' ') '( (/
                 ~~~~ ROAR! SUDO GRANTED! ~~~~
EOF
    echo -e "\033[0m" # Reset...
}

# List my posible users 2 grand SUSHI... ähm SUDO!
list_users() {
    echo "Available Users:"
    printf "%-5s %-20s\n" "ID" "Username"
    printf "%-5s %-20s\n" "---" "--------"

    # Trying to retrieve all users, skipping out system users (UID >= 1000) for a shorter list^^
    awk -F: '$3 >= 1000 && $1 != "nobody" {print NR, $1}' /etc/passwd | while read id username; do
        printf "%-5s %-20s\n" "$id" "$username"
    done
}

# Verify the mission
verify_sudo_permission() {
    local username=$1
    if groups "$username" | grep -qE 'sudo|wheel'; then
        echo "Verification successful: User '$username' has sudo privileges."
    else
        echo "Verification failed: User '$username' does not have sudo privileges."
    fi
}

# Woohaa looping...
while true; do
    # Run it as root you freak!
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root pls."
       exit 1
    fi

    # Getting all relevant Users
    list_users

    # Choose the chosen one - NEO :D
    read -p "Enter the ID of the user to grant sudo privileges: " user_id

    # Extraction!
    selected_username=$(awk -F: -v id="$user_id" '$3 >= 1000 && $1 != "nobody" {if(NR == id) print $1}' /etc/passwd)

    # Uhmm..
    if [[ -z "$selected_username" ]]; then
        echo "Invalid user ID selected. Exiting."
        exit 1
    fi

    # Add the selected user to the damn appropriate group ('sudo' or 'wheel')
    if grep -q '^sudo:' /etc/group; then
        usermod -aG sudo "$selected_username"
        echo "User '$selected_username' has been added to the 'sudo' group."
    elif grep -q '^wheel:' /etc/group; then
        usermod -aG wheel "$selected_username"
        echo "User '$selected_username' has been added to the 'wheel' group."
    else
        echo "Neither 'sudo' nor 'wheel' group found. Cannot proceed."
        exit 1
    fi

    # Ordering the DRAGON MASTER Z!
    display_dragon

    # CHECK SUDO POWER!
    verify_sudo_permission "$selected_username"

    # Try again if you want..
    read -p "Do you want to grant sudo power to another user? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Exiting the program. Goodbye!"
        break
    fi
done
