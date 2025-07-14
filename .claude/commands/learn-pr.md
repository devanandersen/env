 Learn from pull request #$ARGUMENTS. 

Follow these steps:

  1. Identify PR Context and Roles

  - Use gh pr view <PR-NUMBER> --json title,author,reviewRequests,latestReviews,files,body,comments,reviews,state to fetch details
  - Use gh api /repos/xxxx/<CURRENT-REPO>/pulls/<PR-NUMBER>/comments to fetch comments
  - Determine PR author
  - Get all reviewers

  2. If PR Author is Me:

  Filter and prioritize review comments:

  - P0: Requested changes (critical learning points)
  - P1: General comments (improvement suggestions)
  - P2: Approval comments (positive reinforcement)

  For each P0 comment:

  - Extract core issue (security/performance/architecture/etc.)
  - Classify as:
    - Universal: Applicable across projects
    - Project-specific: Relevant to this codebase only
  - Create learning rule in format: "When [context], ensure [action] because [reasoning]"

  For each P1 comment:

  - Identify improvement patterns
  - Note best practices suggested
  - Record alternative approaches proposed

  3. If PR Author is Others:

  Focus on:

  - Comments made after my approval
  - Issues I missed but others caught
  - Different perspectives from other reviewers

  For each missed issue:

  - Document what triggered other reviewers
  - Note why I might have overlooked it
  - Create checklist item for future reviews

  4. Generate Learning Summary:

  - Universal Learnings: Formatted as a list of context, check, reason, priority
  - Project-Specific Learnings: Formatted as a list of project, context, check, reason, priority

  5. Maintain Learning Database

  - Update universal-learnings.json and project-learnings.json files in project root folder
  - Warn user if these two files do not exist and skip this step
  - Store learning as structured format
  - Track frequency of similar issues
  - Update priority based on occurrence
  - Periodically review and consolidate patterns

  6. Create Actionable Checklist:

  Convert learnings into verification steps

  - For each P0 learning:
    - Suggest to add explicit check to personal PR checklist
    - Indicate if the check is automatable
  - For each P1 learning:
    - Suggest to add to best practices documentation

  Apply patterns to current work

  - Check if learnings apply to ongoing tasks
  - Format significant learnings as a Slack message so we can share with team

  7. Generate Summary Report:

  Key Learnings:

  - Universal: [list top 3 general learnings]
  - Project-specific: [list top 3 project learnings]

  Updated Checklist:

  - [new items to verify in future PRs]
