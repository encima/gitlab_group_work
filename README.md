# Coursework Creator!

A script that uses the gitlab gem to handle the creation, assignment and removal of repositories for students. Useful for assignments.

## Running

1. `bundle install`
2. `mv gitlab.yaml.sample gitlab.yaml`
3. Add in your details (endpoints, group names, staff names etc)
5. Create a `teams.csv` of the format: `id,Surname,Forename,Team,Project`
2. `export GITLAB_TOKEN=<YOUR TOKEN>`
3. `ruby cc.rb ACTION`

## Feature Overview

The utilities here revolve primarily around group projects but also has the option for individuals.

* ACTION
    * CREATE
    * REMOVE
* target
    * TEAMS
    * INDIVIDUALS

## TODO

* Incorporate `group_clone` and `group_inspect` scripts (used to review student work)
* Tests
* Allow more customisation of arguments
