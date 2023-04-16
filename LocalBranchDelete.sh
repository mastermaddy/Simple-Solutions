#!/bin/bash

# Loop to prompt user for action until 'q' is entered
while true; do
echo "--------------------------------------------------------------------------------------------"
# Prompt the user to select an action to perform
echo "Select an action:"
echo "1. Print all local branches"
echo "2. Print all local branches that are deleted in remote"
echo "3. Delete all local branches whose corresponding remote branch has been deleted"
echo "4. Exit"
read action

case $action in
  # Print all local branches
  1)
    echo "Local branches:"
    git branch --format='%(refname:short)'
    ;;
  # Print all local branches that are deleted in remote
  2)
    # Get a list of all the remote branches
	remote_branches=$(git ls-remote --heads origin | cut -f 2 | sed 's/refs\/heads\///')

	# Initialize an empty array to store the names of local branches whose remote branch has been deleted or that have no corresponding remote branch
	deleted_branches=()

	# Loop through all the local branches
	for branch in $(git branch --format='%(refname:short)'); do
	  # Check if the current branch is a local branch tracking a remote branch
	  if [[ $(git config --get branch.$branch.remote) == "origin" ]]; then
		# Get the name of the corresponding remote branch
		remote_branch=$(git config --get branch.$branch.merge | sed 's/refs\/heads\///')
		# Check if the remote branch has been deleted
		if [[ ! "$remote_branches" =~ (^|[[:space:]])"$remote_branch"($|[[:space:]]) ]]; then
		  # Add the name of the local branch to the deleted_branches array
		  deleted_branches+=("$branch")
		fi
	  else
		# If the current branch is not tracking a remote branch, add its name to the deleted_branches array
		deleted_branches+=("$branch")
	  fi
	done

	# Print the names of the local branches that correspond to deleted remote branches or that have no corresponding remote branch
	if [[ ${#deleted_branches[@]} -eq 0 ]]; then
	  echo "No local branches found whose remote branch has been deleted or that have no corresponding remote branch"
	else
	  echo "Local branches whose corresponding remote branch has been deleted or that have no corresponding remote branch:"
	  for branch in "${deleted_branches[@]}"; do
		echo "$branch"
	  done
	fi
    ;;
  # Delete all local branches whose corresponding remote branch has been deleted
  3)
    # Get a list of all the remote branches
	remote_branches=$(git ls-remote --heads origin | cut -f 2 | sed 's/refs\/heads\///')

	# Initialize an empty array to store the names of local branches whose remote branch has been deleted or that have no corresponding remote branch
	deleted_branches=()

	# Loop through all the local branches
	for branch in $(git branch --format='%(refname:short)'); do
	  # Check if the current branch is a local branch tracking a remote branch
	  if [[ $(git config --get branch.$branch.remote) == "origin" ]]; then
		# Get the name of the corresponding remote branch
		remote_branch=$(git config --get branch.$branch.merge | sed 's/refs\/heads\///')
		# Check if the remote branch has been deleted
		if [[ ! "$remote_branches" =~ (^|[[:space:]])"$remote_branch"($|[[:space:]]) ]]; then
		  # Add the name of the local branch to the deleted_branches array
		  deleted_branches+=("$branch")
		fi
	  else
		# If the current branch is not tracking a remote branch, add its name to the deleted_branches array
		deleted_branches+=("$branch")
	  fi
	done

	# Print the names of the local branches that correspond to deleted remote branches or that have no corresponding remote branch
	if [[ ${#deleted_branches[@]} -eq 0 ]]; then
	  echo "No local branches found whose remote branch has been deleted or that have no corresponding remote branch"
	else
	  echo "Local branches whose corresponding remote branch has been deleted or that have no corresponding remote branch:"
	  for branch in "${deleted_branches[@]}"; do
		echo "$branch"
		git branch -D "$branch"
	  done
	fi
    ;;
  # Exit the script
  4)
      echo "Exiting the script..."
      exit 0
      ;;
    # Invalid option selected
    *)
      echo "Invalid option selected"
      ;;
esac
done
