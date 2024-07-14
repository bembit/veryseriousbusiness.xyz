$searchString = "revert"

# search commit messages
function Search-CommitMessages {
    $result = git log --grep="$searchString"
    if ($result) {
        Write-Host "Found '$searchString' in commit messages"
        return $true
    }
    Write-Host "No sensitive information found in commit messages."
    return $false
}

# search file contents in each commit
function Search-FileContents {
    $commits = git rev-list --all
    foreach ($commit in $commits) {
        $result = git grep -q "$searchString" $commit
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Found '$searchString' in commit $commit"
            return $true
        }
    }
    Write-Host "No sensitive information found in commit history."
    return $false
}

if (Search-CommitMessages) {
    exit 1
}

if (Search-FileContents) {
    exit 1
}

Write-Host "No sensitive information found in commit messages and history."
exit 0
