# Review PR

Review a pull request against team standards.

## Arguments

- $ARGUMENTS: Branch name or PR number to review

## Instructions

You are a thorough PR reviewer. Review the given PR against the team's standards documented below.

### Step 1: Gather PR Information

Use `gh` CLI to gather all relevant PR information:

1. If given a branch name, find the associated PR: `gh pr view <branch> --json number,title,body,state,isDraft,reviewRequests,labels,headRefName,baseRefName,additions,deletions,files,statusCheckRollup,url,author`
2. Get the full diff: `gh pr diff <identifier>`
3. Get existing review comments: `gh api repos/{owner}/{repo}/pulls/{number}/comments`

### Step 1b: Check CI Status via Buildkite

Use the Buildkite MCP tools to check CI status. Determine the pipeline and organization from the repo.

**Available Buildkite MCP tools:**
- `list_builds` — List builds for a pipeline (filter by branch)
- `get_build` — Get detailed build info including jobs, timing, and execution details
- `get_jobs` — Get all jobs for a specific build including state, timing, commands
- `get_job_log` — Get log output for a specific job (auto-saves large logs to file)
- `list_pipelines` — List pipelines in the org (useful to find the right pipeline name)
- `get_build_test_engine_runs` — Get test engine data for a build
- `get_failed_test_executions` — Get failed test details with error messages and stack traces

**CI check workflow:**

1. **Find builds for the branch:** Use `list_builds` with the pipeline and filter by the PR's branch name. If the PR is a **draft** and there are **no Buildkite builds** for the branch, CI has not been triggered — flag this prominently: "This PR is in draft with no Buildkite CI runs. CI has not been triggered yet." Some basic GitHub Actions checks may still appear on draft PRs, but the full Buildkite CI suite requires a manual trigger.
2. **Get build details:** If builds exist, use `get_build` with the pipeline and the most recent build number to check overall status.
3. **Investigate failures:** If the build has failures, use `get_jobs` to see which jobs failed, then `get_job_log` for each failed job to get error details.
4. **Check test failures:** Use `get_build_test_engine_runs` and `get_failed_test_executions` to get specific test failure details with error messages and stack traces.
5. **Include CI findings in the review** — summarize what's passing/failing and include relevant error excerpts for any failures.

### Step 2: Check "Definition of Ready for Review"

Verify the PR meets all readiness criteria:

- [ ] **Not in draft state** — Draft PRs are not ready for review. If the PR is still in draft, stop and note this.
- [ ] **CI is green** — All CI checks must be passing. If CI is failing, the review should be a "Request Changes" noting CI needs to be fixed first.
- [ ] **PR description includes:**
  - Link to the corresponding issue (if applicable)
  - High-level context behind why the change is being made
  - Callouts of any special areas or risks in the approach
  - Rollout strategy including a link to the feature flag, or an explanation for why it's safe without one
  - Verification plan for how we'll know the change is successful
  - Rollback plan for how to mitigate or address issues
- [ ] **Tests** — Unit and/or E2E tests have been created or updated
- [ ] **Local testing** — Evidence or mention of local testing / tophatting

### Step 3: Code Review

Review the diff for:

**Correctness & Safety**
- Logic errors, edge cases, off-by-one errors
- Race conditions or concurrency issues
- Proper error handling
- Security concerns (injection, XSS, auth issues, OWASP top 10)
- Safe rollout considerations — does this need a feature flag?

**Code Quality**
- Readability and clarity
- Appropriate naming
- DRY without over-abstraction
- Consistent with surrounding codebase patterns and conventions

**Testing**
- Are the tests meaningful and covering the important paths?
- Are edge cases tested?
- Are tests brittle or robust?

**Architecture & Design**
- Does the approach make sense for the problem?
- Are there simpler alternatives?
- Is the blast radius of the change appropriate?

### Step 4: Output Your Review

Structure your review as follows:

```
## PR Review: <PR title> (#<number>)

### Readiness Checklist
<Go through each item from Step 2 with a check or X mark, with brief notes>

### Summary
<2-3 sentence summary of what the PR does and your overall impression>

### Review Findings

#### Must Address (Request Changes)
<Issues that must be fixed before merging. If none, say "None">

#### Should Address
<Strong suggestions that would meaningfully improve the PR. If none, say "None">

#### Nits / Non-blocking
<Minor style or preference suggestions the author can take or leave. If none, say "None">

### Verdict
<One of: READY FOR HUMAN REVIEW, REQUEST CHANGES, or NEEDS DISCUSSION>
<Brief justification>
```

### Important Guidelines

- Be constructive and specific — point to exact lines/files when giving feedback.
- Distinguish clearly between blocking issues and non-blocking suggestions.
- Non-blocking feedback is at the author's discretion to address.
- If requesting changes, the reviewer is responsible for re-reviewing once addressed.
- Remember: squash commits before merging.
