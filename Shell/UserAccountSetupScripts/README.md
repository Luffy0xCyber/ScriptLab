# User Account Setup Script

This script helps automate creating user accounts from a CSV file in my Linux cybersecurity labs.

What it does
Reads a CSV file named `users.csv` with user info:

```md
<matricule>;<first name>;<last name>;<department>
```
For each user, it:

- Creates a user account with login = matricule

- Creates a primary group also named after the matricule

- Adds the user to a group representing their department (group name simplified)

-  Sets the user’s comment field to "first name last name"

- Generates a 12-char strong password with uppercase, lowercase, number & symbol (using pwgen)

- Creates shared departmental folders with proper group ownership and permissions

- Grants extra ACL permissions for users in the "Direction" department to access all folders

Outputs credentials (matricule and password) to ``credentials.txt`` to keep track.

How to use : <br>

- !!Make sure pwgen is installed before running the script.!!

- Put your user data in ``users.csv`` with the specified format.

- Check the output file ``credentials.txt`` for the generated passwords


# Author of the exercise
Mr. SOLDANI Cyril

# Author of the script
Anas El Faijah