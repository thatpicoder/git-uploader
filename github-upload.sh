#!/bin/bash

echo "github folder uploader by bitetheapple"
echo


read -p "drag in the folder you want to upload: " FOLDER
read -p "enter your github username: " USERNAME
read -p "enter the github repository name: " REPONAME

echo
read -p "force overwrite remote repo if push fails? (y/N): " FORCE


if [ ! -d "$FOLDER" ]; then
    echo "error: folder does not exist."
    exit 1
fi

cd "$FOLDER" || exit 1

echo
echo "working in: $FOLDER"


if [ ! -d ".git" ]; then
    echo "initializing git repository..."
    git init
else
    echo "git repository already exists."
fi


git branch -M main 2>/dev/null


REMOTE_URL="https://github.com/$USERNAME/$REPONAME.git"

if git remote get-url origin >/dev/null 2>&1; then
    echo "updating existing remote..."
    git remote set-url origin "$REMOTE_URL"
else
    echo "adding remote..."
    git remote add origin "$REMOTE_URL"
fi


echo "adding files..."
git add .


echo "creating commit..."
git commit -m "initial upload" 2>/dev/null


echo "pushing to github..."
if git push -u origin main; then
    echo
    echo "upload successful!"
else
    echo
    echo "push failed."

    if [[ "$FORCE" =~ ^[Yy]$ ]]; then
        echo "force pushing..."
        git push --force origin main
    else
        echo "trying pull + merge..."
        git pull origin main --allow-unrelated-histories
        git push origin main
    fi
fi
