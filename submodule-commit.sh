#!/bin/bash

# get the name of the current submodule
current_submodule=root

commit_message="$1"

# get the name of the branch we're currently on for this submodule
current_submodule_branch=$(git rev-parse --abbrev-ref HEAD)

# get the names of the other submodules with diffs
diff_submodules=$(git submodule foreach --quiet 'git diff --quiet || echo $name')

echo $diff_submodules

# iterate over the submodules with diffs
for submodule in $diff_submodules; do
  # get the name of the branch for this submodule
  submodule_branch=$(git -C $submodule rev-parse --abbrev-ref HEAD)

  # check if this submodule is on the same branch as current submodule
  if [ "$submodule_branch" == "$current_submodule_branch" ]; then
    echo "Submodule $submodule is on the same branch as current submodule"
  else
  
    # check if a branch with the same name as the current submodule branch exists in the submodule
    if git -C $submodule show-ref --verify --quiet "refs/heads/$current_submodule_branch"; then
      echo "Branch $current_submodule_branch already exists in submodule $submodule"
      git -C $submodule checkout $current_submodule_branch
    else
    
      # create a new branch for this submodule with the same name as current submodule
      echo "Submodule $submodule is on a different branch, creating new branch..."
      git -C $submodule checkout -b $current_submodule_branch
    fi
  fi

  # commit the changes for this submodule
  echo "Committing changes for submodule $submodule"
  git -C $submodule add .
  git -C $submodule commit -m "$commit_message"
done

git add .
git commit -m "$commit_message"
