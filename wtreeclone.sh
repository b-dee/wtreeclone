#!/usr/bin/env bash

# Exit immediately if anything returns non-zero.
set -e

# Grab initial args.
repo_url="$1"
repo_dir="$2"

# Grab the rest of the args from the third position.
args_rest=("${@:3}")

# Make the parent directory and set cwd to it.
echo "Creating $repo_dir..."
mkdir -p "$repo_dir"
echo "Entering $repo_dir..."
cd "$repo_dir"

# Grab the bare repo.
echo "Getting bare clone of $repo_url..."
git clone --bare "$repo_url" .bare

# Create .git file if it doesn't already exist and
# append gitdir var to point to the bare repo.
echo 'gitdir: ./.bare' > .git 

# Set up fetch from remote origin.
echo 'Configuring fetch...'
git config --local remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

# Enable reflogs.
echo 'Enabling reflogs...'
git config --local core.logallrefupdates true

# Delete existing local branches and fetch remote tracking
# branches that we can use for new local tracking branches.
# We do this before adding any worktrees because tracking
# info is not set by worktree unless creating a new branch.
echo 'Delecting local branch refs (note: this is not destructive)...'
git for-each-ref --format='%(refname:short)' refs/heads | xargs git branch -d
echo 'Fetching remote branch refs...'
git fetch

# For convenience, make any worktrees specified.
# wtree_spec values are strings like 'tree_dir:commit_ish'
# where tree_dir is relative to repo_dir and commit_ish is
# whatever ref you want to check out in the work tree.
for wtree_spec in "${args_rest[@]}"; do
  # Split using cut to grab each part
  tree_dir=$(echo "$wtree_spec" | cut -d ':' -f 1)
  commit_ish=$(echo "$wtree_spec" | cut -d ':' -f 2)

  echo "Adding worktree $tree_dir at $commit_ish..."

  # Add worktrees
  git worktree add "$tree_dir" "$commit_ish"
done

echo 'Done.'

