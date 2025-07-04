#!/usr/bin/env bash
# Usage example: apply-patches.sh release/1.99 - Apply all fork patches to any branch

set -e

TARGET_BRANCH=$1
MARKER_COMMIT_MSG=${2:-"geektrust initial commit marker"}
SOURCE_BRANCH=${3:-"main"}
UPSTREAM_URL=${4:-"https://github.com/gitpod-io/openvscode-server.git"}

if [ -z "$TARGET_BRANCH" ]; then
	echo "Usage: $0 <target-branch> [marker-commit-msg] [source-branch] [upstream-url]"
	echo "Example: $0 release/1.99"
	echo "Example: $0 feature/new-thing 'geektrust initial commit marker' main"
	echo "Example: $0 release/1.99 'geektrust initial commit marker' main https://github.com/gitpod-io/openvscode-server.git"
	exit 1
fi

echo "Applying all patches to branch: $TARGET_BRANCH"

check_upstream() {
	git remote -v | grep --quiet upstream
	if [[ $? -ne 0 ]]; then
		echo "Upstream repository not configured"
		echo "Setting upstream URL to ${UPSTREAM_URL}"
		git remote add upstream $UPSTREAM_URL
	else
		echo "Upstream repository already configured"
	fi
}

get_marker_commit() {
	local marker_commit=$(git log $SOURCE_BRANCH --pretty="%H" --max-count=1 --grep "$MARKER_COMMIT_MSG")
	if [[ -z $marker_commit ]]; then
		echo "Error: Could not find marker commit with message: $MARKER_COMMIT_MSG"
		exit 1
	fi
	echo $marker_commit
}

get_patch_commits() {
	local marker_commit=$(get_marker_commit)
	git log --pretty="%H" --reverse ${marker_commit}^..${SOURCE_BRANCH}
}

apply_changes() {
	check_upstream

	echo "Fetching from upstream and origin..."
	git fetch upstream || git fetch origin

	if git show-ref --verify --quiet refs/heads/$TARGET_BRANCH; then
		echo "Branch $TARGET_BRANCH already exists locally. Checking it out..."
		git checkout $TARGET_BRANCH

		if git show-ref --verify --quiet refs/remotes/origin/$TARGET_BRANCH; then
			echo "Pulling latest changes from origin/$TARGET_BRANCH..."
			git pull origin $TARGET_BRANCH
		fi

		local source_marker_commit=$(get_marker_commit)
		local all_source_commits=($(git log --pretty="%H" --reverse ${source_marker_commit}^..${SOURCE_BRANCH}))

		if [ ${#all_source_commits[@]} -eq 0 ]; then
			echo "No commits found in $SOURCE_BRANCH after marker commit"
			return
		fi

		local source_subjects=()
		for commit in "${all_source_commits[@]}"; do
			source_subjects+=("$(git log --pretty="%s" -n 1 $commit)")
		done

		local target_subjects=$(git log --pretty="%s" --no-merges -n ${#all_source_commits[@]} $TARGET_BRANCH)

		local commits_to_apply=()
		for i in "${!all_source_commits[@]}"; do
			local subject="${source_subjects[$i]}"
			if ! echo "$target_subjects" | grep -Fxq "$subject"; then
				commits_to_apply+=("${all_source_commits[$i]}")
			fi
		done

		if [ ${#commits_to_apply[@]} -eq 0 ]; then
			echo "No new commits to apply from $SOURCE_BRANCH"
			echo "Branch $TARGET_BRANCH is up to date"
			return
		fi

		local commits=("${commits_to_apply[@]}")
		echo "Found ${#commits[@]} new commits to apply"

	else
		if git show-ref --verify --quiet refs/remotes/upstream/$TARGET_BRANCH; then
			echo "Creating $TARGET_BRANCH from upstream/$TARGET_BRANCH"
			git checkout -b $TARGET_BRANCH upstream/$TARGET_BRANCH
		elif git show-ref --verify --quiet refs/remotes/origin/$TARGET_BRANCH; then
			echo "Creating $TARGET_BRANCH from origin/$TARGET_BRANCH"
			git checkout -b $TARGET_BRANCH origin/$TARGET_BRANCH
		else
			echo "Error: Branch $TARGET_BRANCH not found in upstream or origin"
			exit 1
		fi

		local commits=($(get_patch_commits))
		echo "Found ${#commits[@]} total commits to apply"
	fi

	if [ ${#commits[@]} -eq 0 ]; then
		echo "No patch commits found to apply"
		return
	fi

	echo "Applying ${#commits[@]} commits..."

	for commit in "${commits[@]}"; do
		echo "Cherry-picking commit: $commit"
		git cherry-pick $commit

		if [ $? -ne 0 ]; then
			echo "Conflict detected in commit $commit"
			echo "Please resolve conflicts manually, then run:"
			echo "  git cherry-pick --continue"
			echo "  git push origin $TARGET_BRANCH"
			exit 1
		fi

	done

	git push -u origin $TARGET_BRANCH

	echo "Successfully applied all patches to $TARGET_BRANCH"
	echo "Branch pushed to origin/$TARGET_BRANCH with tracking set up"
}

apply_changes
