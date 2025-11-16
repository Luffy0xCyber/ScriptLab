#!/bin/sh

# su - matricule!!

CSV_FILE="users.csv" # To adapt as needed
OUTPUT="credentials.txt" # same here, to adapt
SHARE_BASE="/home/shared" # Base directory for shared folders

# Clear output file
> "$OUTPUT"

# To clean and standardize group names...
sanitize_group() {
    echo "$1" | iconv -f utf8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_'
}

# Read each line of the CSV file
while IFS=';' read -r matricule prenom nom departement; do
    [ -z "$matricule" ] && continue  # skip empty lines

    comment="$prenom $nom"
    groupe_principal="$matricule"
    groupe_dept="$(sanitize_group "$departement")"
    dir="$SHARE_BASE/$groupe_dept"

    # Password generated with pwgen (!!must be installed!!)
    password=$(pwgen -sB 12 1)

    # Create the primary group 
    getent group "$groupe_principal" >/dev/null || groupadd "$groupe_principal"

    # Create the user
    useradd -m -c "$comment" -g "$groupe_principal" "$matricule"
    echo "$matricule:$password" | chpasswd

    # Create the department group 
    getent group "$groupe_dept" >/dev/null || groupadd "$groupe_dept"

    # Add the user to the department group
    usermod -aG "$groupe_dept" "$matricule"

    # Create the shared directory if it does not exist
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        chown root:"$groupe_dept" "$dir"
        chmod 2770 "$dir"
    fi

    # ACLs: users from "Direction" have access to all folders
    if [ "$departement" = "Direction" ]; then
        for d in "$SHARE_BASE"/*; do
            [ -d "$d" ] && setfacl -m u:"$matricule":rwx "$d"
        done
    else
        # Give access to members of Direction to this folder
        if getent group direction >/dev/null; then
            for user in $(getent group direction | cut -d: -f4 | tr ',' ' '); do
                [ -n "$user" ] && setfacl -m u:"$user":rwx "$dir"
            done
        fi
    fi

    # Save the generated credentials
    echo "$matricule $password" >> "$OUTPUT"

done < "$CSV_FILE"