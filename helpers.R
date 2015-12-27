library(dplyr)
library(reshape2)

game_result <- function(away_score, home_score){
    if(away_score > home_score){
        result <- c('win', 'lose')
    }
    if(away_score < home_score){
        result <- c('lose', 'win')
    }
    if(away_score == home_score){
        result <- c('push', 'push')
    }
    result
}

create_compact_data <- function(ds) { # ds stands for datasource
  # add columns for straight away and home game results,
  # also add columns with full name of city and team 
  for(i in seq(nrow(ds))){
      ds$away_result[i] <- game_result(ds$away_score[i], ds$home_score[i])[1]
      ds$home_result[i] <- game_result(ds$away_score[i], ds$home_score[i])[2]
      ds$away_full_name[i] <- paste(ds$away_city[i], ds$away_name[i])
      ds$home_full_name[i] <- paste(ds$home_city[i], ds$home_name[i])
  }
  
  # return the columns of interest in a preffered succession
  ds[, c('year', 'away_full_name', 'away_score', 'away_ats_result', 'away_result', 'home_full_name', 'home_score', 'home_ats_result', 'home_result')]
}

# helper function to return counts of wins, losses and pushes
# or in case a result for a win or lose or push is not present to return 0
counts_or_zero <- function(data_source, result){
    if(nrow(data_source[which(data_source[, 1]==result),]) < 1) {
        0
    }
    else {
        data_source[which(data_source[, 1]==result),]$counts
    }
}

create_team_stats <- function(data_source){
    # creating data sources for counting score and game result for away or home
    # also counting ats(AgainstTheSpread) results
    # this one is a quite long function
    # very likely it can be rewritten in a more elegant and short way
    scores_away <- group_by(data_source, away_full_name) %>%
        summarise(away_score_sum=sum(away_score), away_counts=n())
    
    scores_home <- group_by(data_source, home_full_name) %>%
        summarise(home_score_sum=sum(home_score), home_counts=n())

    results_away <- group_by(data_source, away_full_name, away_result) %>%
        summarise(away_counts=n())
    
    results_home <- group_by(data_source, home_full_name, home_result) %>%
        summarise(home_counts=n())
    
    results_away_ats <- group_by(data_source, away_full_name, away_ats_result) %>%
        summarise(away_ats_counts=n())
    
    results_home_ats <- group_by(data_source, home_full_name, home_ats_result) %>%
        summarise(home_ats_counts=n())

    # binding each away and home scores*, results_* and results_ats* tables
    # excluding home_full_name from resulting data sets which is 4th column
    scores <- cbind(scores_away, scores_home)[, -4]

    # creating unique names data source
    # in this case it doesn't matter if we choose away or home team
    unique_teams <- select(data_source, away_full_name) %>%
        distinct(away_full_name) %>%
        arrange(away_full_name)

    teams_names <- character(nrow(unique_teams))
    teams_scores <- numeric(nrow(unique_teams))
    nr_wins <- numeric(nrow(unique_teams))
    nr_losses <- numeric(nrow(unique_teams))
    nr_pushes <- numeric(nrow(unique_teams))
    nr_wins_ats <- numeric(nrow(unique_teams))
    nr_losses_ats <- numeric(nrow(unique_teams))
    nr_pushes_ats <- numeric(nrow(unique_teams))
    i <- 1
    # creating data source with each team results and total score    
    for(team in unique_teams$away_full_name){
        team_score <- filter(scores, away_full_name==team) %>%
            mutate(total_score=away_score_sum + home_score_sum)

        team_results_away <- filter(results_away, away_full_name==team) %>%
            melt(variable.name = 'counts', id=1:2, measure.vars='away_counts') %>%
            group_by(away_result) %>%
            summarise(counts=sum(value))

        team_results_home <- filter(results_home, home_full_name==team) %>%
            melt(variable.name = 'counts', id=1:2, measure.vars='home_counts') %>%
            group_by(home_result) %>%
            summarise(counts=sum(value))
        
        team_results_away_ats <- filter(results_away_ats, away_full_name==team) %>%
            melt(variable.name = 'counts', id=1:2, measure.vars='away_ats_counts') %>%
            group_by(away_ats_result) %>%
            summarise(counts=sum(value))
        
        team_results_home_ats <- filter(results_home_ats, home_full_name==team) %>%
            melt(variable.name = 'counts', id=1:2, measure.vars='home_ats_counts') %>%
            group_by(home_ats_result) %>%
            summarise(counts=sum(value))
        
        teams_names[i] <- team
        teams_scores[i] <- team_score$total_score
        nr_wins[i] <- counts_or_zero(team_results_away, 'win') + counts_or_zero(team_results_home, 'win')
        nr_losses[i] <- counts_or_zero(team_results_away, 'lose') + counts_or_zero(team_results_home, 'lose')
        nr_pushes[i] <- counts_or_zero(team_results_away, 'push') + counts_or_zero(team_results_home, 'push')
        nr_wins_ats[i] <- counts_or_zero(team_results_away_ats, 'win') + counts_or_zero(team_results_home_ats, 'win')
        nr_losses_ats[i] <- counts_or_zero(team_results_away_ats, 'lose') + counts_or_zero(team_results_home_ats, 'lose')
        nr_pushes_ats[i] <- counts_or_zero(team_results_away_ats, 'push') + counts_or_zero(team_results_home_ats, 'push')
        
        i <- i + 1
    }
    data.frame(year=rep(data_source$year[1], nrow(unique_teams)), team_name=teams_names, team_score=teams_scores, nr_wins, nr_losses, nr_pushes, nr_wins_ats, nr_losses_ats, nr_pushes_ats, stringsAsFactors=FALSE)
}

process_csv <- function(year){
    csv.file.path <- paste0("data/fantasysupercontest.com_", year, ".csv")
    # remove lines which contains na's in away score
    # this is actual for current year which could have incomplete data
    d <- filter(read.csv(csv.file.path), !is.na(away_score))
    compact_data <- create_compact_data(d)
    create_team_stats(compact_data)
}

filter_stats_by_year <- function (data_source, start_year, end_year) {
    group_by(data_source, team_name) %>%
        filter(year>=start_year & year<=end_year) %>%
        summarise(team_score=sum(team_score), win_counts=sum(nr_wins), lose_counts=sum(nr_losses), push_nr=sum(nr_pushes)) %>%
        arrange(desc(win_counts, team_score))
}

create_top_stats <- function (data_source, start_year, end_year, top_nr) {
    team_scores_cum <- filter(data_source, year>=start_year & year<=end_year) %>%
        group_by(team_name) %>%
        mutate(score_cumulative=cumsum(team_score), wins_cumulative=cumsum(nr_wins)) %>%
        group_by(year) %>%
        arrange(desc(wins_cumulative), desc(score_cumulative))
    
    stats_by_year <- filter(team_scores_cum, year>=start_year & year<=end_year) %>% arrange(desc(nr_wins), desc(team_score))
    
    top_n_teams <- filter(stats_by_year, year==end_year) %>%
        select(team_name, wins_cumulative, score_cumulative) %>%
        arrange(desc(wins_cumulative), desc(score_cumulative)) %>%
        top_n(top_nr)
    
    filter(team_scores_cum, team_name %in% top_n_teams$team_name) %>%
        arrange(desc(wins_cumulative), desc(score_cumulative))
}
