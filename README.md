# wtreeclone
## A script to clone bare repos and use worktrees with working tracking branches.

Installation instructions below.

## Who is this for?

Anyone who wants to work with a git repo using git worktrees, using a bare repo 
to organise files into one directory per worktree under a parent directory.

## Why does it exist?

If you've ever tried to use worktrees with a bare repo, you may have noticed
that: 

1. Fetch is not configured.
2. Reflogs are not enabled.
3. Tracking info is not set up correctly for branches that already exist.

## What does this do?

This script is intended to be ran once, when first cloning a repo. After this,
simply use worktrees in the normal way.

It does the following: 

1. Clone the repo at the specified URL into the specified directory.
2. Create a .git file at the root, pointing to the bare repo.
3. Add config for fetch to the .git/config file.
4. Enable reflogs using core.logallrefupdates in that same file.
5. Delete existing local branches (see below).
6. Do a fetch to get remote tracking branches.
7. Add any initial worktrees you specify (see below).

## Why is deleting local branches necessary?

Per the [docs](https://git-scm.com/docs/git-worktree) for git worktree, for tracking
info to be set up (--track) a new branch must be created. Having existing local branches
causes git to simply check out the existing local branch in the new worktree without
setting the upstream. You would then have to remember to manually run `git branch -u ...`
to make the branch a local tracking branch and get git status to reflect tracking.

By deleting the existing branches and fetching remotes, git recognises that a new branch
with the same name as a remote tracking branch is being created, and sets the upstream
accordingly.

The -d option is used, meaning that unmerged branches will not be deleted and script
execution will halt there with a message. You will then need to either delete or merge
these branches. If you aren't using these unmerged branches to create initial worktrees and
you are fine with deleting them yourself before doing so (or setting up tracking yourself)
you can simply remove the delete step from the script so that it runs to completion. 

## How do I install this?

Clone the repo to wherever you put unpackaged software and add the /bin directory to
your PATH so that the script is available everywhere. E.g.

```
$ git clone <repo_url> /opt/wtreeclone
$ echo 'export PATH="/opt/wtreeclone/bin:$PATH"' >> ~/.bashrc (or zshrc etc.)
$ source ~/.bashrc (or simply restart shell)
$ wtreedir <repo_url> <repo_dir> [wtree_spec[ wtree_spec[ ...]]]
```

## How do I use this?

Usage is as follows:

`$ wtreedir <repo_url> <repo_dir> [<wtree_spec>[ <wtree_spec>[ ...]]]`

<repo_url> is the URL used to clone your repo.
<repo_dir> is the parent directory you wish to contain the bare repo and worktrees.

The rest of the parameters are interpreted as a list of <wtree_spec> strings, each
separated by whitespace (see below).

## How do I specify some initial worktrees?

<wtree_spec> values are strings like '<tree_dir>:<commit_ish>'
where <tree_dir> is relative to <repo_dir> and <commit_ish> is
whatever ref you want to check out in the worktree.

Enjoy.
