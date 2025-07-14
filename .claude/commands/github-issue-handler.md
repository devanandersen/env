# GitHub Ticket Handler

This document outlines the process for handling a list of GitHub tickets systematically. Each ticket will be addressed one by one, with each resolved ticket being managed in its own branch.

The list of Github Tickets are $ARGUMENTS

## Process for each GitHub Ticket

For each ticket in the list, follow these steps:

1. **Create a new branch**:  

Use the command:  
gt create ticket-[TicketNumber]

2. **Review the ticket details**:  
Ensure you understand the requirements and context for the ticket. You can use the 'gh' cli tool.

3. **Implement the necessary changes**:  
Make the required modifications as specified in the ticket. Write tests, check for linting, etc.

4. **Run tests**:
Make sure you run tests to ensure the changes work.

5. **Run linting / typing**:  
Make sure you run linting, and typechecking on the code.

6. **Commit your changes**:  
Use a descriptive commit message related to the ticket:  
git commit -m "Solve ticket [TicketNumber]: [Brief Description]"

7. **Create a Pull Request (PR)**:  
Use the following commands to track and submit the PR:  
gt track --parent main gt submit --stack

8. **Switch to the next task**:  
After submitting the PR, switch back to the next task in the list. Follow the previous steps again.

Create a new branch for the next ticket starting from step 1. If there are no new tasks, proceed to step 9.

9. **If there are no new tasks**
You're done! Provide links to all Graphite PRs and branches per github issue ticket as the output.

## Requirements

- One ticket per branch/PR
- Use graphite commands (gt) only, NO git commands
- Ensure all changes are in accordance with the ticket specifications
- Maintain clarity in commit messages for future reference
- Ensure all tests and linting are passed before submitting the PR
