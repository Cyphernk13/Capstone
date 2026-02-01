#!/bin/bash



# 1. Create the Group

echo "Creating group 'internal_team'..."

sudo groupadd internal_team



# 2. Create the Users

# Alice: The Insider (Added to the group)

echo "Creating user 'alice'..."

sudo useradd -m -G internal_team alice

echo "alice:password123" | sudo chpasswd



# Bob: The Outsider (NOT in the group)

echo "Creating user 'bob'..."

sudo useradd -m bob

echo "bob:password123" | sudo chpasswd



# 3. Create the Secure Directory (in /opt to ensure accessibility)

echo "Setting up secure directory..."

sudo mkdir -p /opt/project5_secure

echo "This is Top Secret Data for Project 5." | sudo tee /opt/project5_secure/secret.txt



# 4. Lock Permissions (770: Owner=RWX, Group=RWX, Others=None)

sudo chown :internal_team /opt/project5_secure

sudo chmod 770 /opt/project5_secure



echo "Setup complete! Users 'alice' and 'bob' are ready."
