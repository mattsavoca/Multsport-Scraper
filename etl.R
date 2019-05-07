library(tidyverse)
library(ggplot2)
library(ggrepel)
library(ggridges)

source("helpers.R")

mlb = read_csv('./mlb/drafts.csv')
nhl = read_csv('./nhl/nhldrafts.csv')
nfl = read_csv('./nfl/nfldrafts.csv')
nba = read_csv('./nba/nbadrafts.csv')
nbapos = read_csv('./nba/nbapos.csv')


#MLB data #######
mlb_df = mlb %>%
  mutate(
    #create a june draft-only, numeric round (parse out supplemental draft picks)
    jun_draft_round = as.numeric(draft_round),
    #players that have a star next to their name were from picks awarded via the compensatory-pick system, note that
    compensatory_pick = ifelse(str_sub(player,1,1)=="*",1,0),
    #some players have extra characters,in addition to the possible star (see above). Let's clean that column.
    player = sub('\\*', '', player),
    player = sub('\\(', '', player),
    player = trimws(player),
    games = games_batting+games_pitching,
    war = replace_na(war, 0),
    pos_group = 
      ifelse(position %in% c('INF','1B','2B','SS','3B'), 
             'INF',
             ifelse(position %in% c('OF','LF','RF','CF'),
                    'OF',
                    position)),
    war_pctile = percent_rank(war),
    value = war,
    value_norm  = quicknorm(value),
    value_pctile = war_pctile
    ) %>%
  #create a pick-percentile variable for cross-sport analysis
  group_by(draft_year) %>%
  mutate(
    draft_pick_pctile = percent_rank(-draft_pick)
    )
  

#players in the MLB can get drafted to a team, but choose to remain in school. When they do so, they go back into the
#pool of eligible players for the following year's draft, essentially eliminating the franchise's pick.
mlb_df= mlb_df %>%
  group_by(player_id) %>%
  mutate(
    #first, check how many more drafts until the player's final year drafted
    player_draft_num = dense_rank(-draft_year),
    #then have a 1/0 variable to check if it's the player's final year drafted
    player_final_draft = ifelse(player_draft_num==1,1,0)) %>%
  ungroup() %>%
  #using a helper function, let's make all on-field stats 0 for players *not* in their final year drafted
  mutate(
    war = player_to_zero(war, player_final_draft),
    whip = player_to_zero(whip, player_final_draft),
    pitch_losses = player_to_zero(pitch_losses, player_final_draft),
    pitch_wins = player_to_zero(pitch_wins, player_final_draft),
    pitch_saves = player_to_zero(pitch_saves, player_final_draft),
    games_pitching = player_to_zero(games_pitching, player_final_draft),
    games_batting = player_to_zero(games_batting, player_final_draft),
    at_bats = player_to_zero(at_bats, player_final_draft),
    ops = player_to_zero(ops, player_final_draft)
  ) %>% 
  #*now* it's safe to make all NAs in all statistical-fields 0, we'll re-coerce for the one filed that should have NAs
  replace(is.na(.), 0) %>%
  mutate(jun_draft_round = ifelse(jun_draft_round == 0, NA, jun_draft_round),
         sport = "mlb",
         pos_group_b = paste0(pos_group, '(', sport, ')'))
#NFL data #####
nfl_df = nfl %>%
  group_by(draft_year) %>%
  mutate(
    draft_pick_pctile = percent_rank(-draft_pick)
  ) %>%
  ungroup() %>%
  mutate(
    allpros = replace_na(allpros, 0),
    probowls = replace_na(probowls,0),
    starter_seasons = replace_na(starter_seasons,0),
    career_avg_value = ifelse(career_avg_value<0,0,career_avg_value),
    career_avg_value = replace_na(career_avg_value,0),
    draft_team_avg_value = replace_na(drafteam_avg_value,0),
    games = replace_na(games,0),
    pos_group = 
      ifelse(position %in% c('T','G','C','OL'),'OL',
             ifelse(position %in% c('DT','NT','DE','DL'), 'DL',
              ifelse(position %in% c('LB','ILB','OLB','ILB'), 'LB',
                ifelse(position %in% c('S','CB'), 'DB',
                  ifelse(position %in% c('FB','TE'), 'TE',
                    ifelse(position %in% c('P','K','LS','KR'), 'ST',
                              position)))))),
    av_pctile = percent_rank(career_avg_value),
    draftteam_av_pctile = percent_rank(draft_team_avg_value),
    value = career_avg_value,
    value_norm  = quicknorm(value),
    value_pctile = av_pctile,
    sport = 'nfl',
    pos_group_b = paste0(pos_group, '(', sport, ')')
  )
#NHL data ######
nhl_df = nhl %>%
  group_by(draft_year) %>%
  mutate(draft_pick_pctile = percent_rank(-draft_pick))

nhl_df = nhl_df %>%
  mutate(
    plus_minus = replace_na(plus_minus, 0),
    point_share = replace_na(point_share, min(point_share)),
    points = replace_na(points, 0),
    point_share_pctile = percent_rank(point_share),
    point_pctile = percent_rank(points),
    years_played = ifelse(is.na(played_until),0,played_until-draft_year),
    position =  sub('\\/', '-', position),
    position = sub(';+[:space:]*', '-', position),
    position = 
        ifelse(is.na(position), 'None',
        ifelse(position == 'L', 'LW',
        ifelse(position == 'Centr', 'C',
        ifelse(position == 'C RW', 'C-RW',
        ifelse(position == 'C- LW', 'C-LW', position)))))
  ) %>%
  separate(position, c("position_1","position_2"), sep = '-') %>%
  mutate(
    pos_group = 
        ifelse(
          position_1 %in% c('RW','LW','W','F','L'), 'W',
          position_1),
    value = point_share,
    value_norm  = quicknorm(value),
    value_pctile = point_share_pctile,
    sport = 'nhl',
    pos_group_b = paste0(pos_group, '(', sport, ')')
  )

#NBA data #####
nbapos = na.omit(nbapos)

nba_merge = left_join(
  nba, nbapos, by = 'player_id'
)

nba_df = nba_merge %>%
  group_by(draft_year) %>%
  mutate(
    draft_pick_pctile = percent_rank(-draft_pick)
  ) %>%
  ungroup() %>%
  mutate(
    position = replace_na(position, 'UNK'),
    bpm = replace_na(bpm, min(bpm)),
    games = replace_na(games, 0),
    minutes = replace_na(minutes, 0),
    seasons = replace_na(seasons, 0),
    vorp = replace_na(vorp, min(vorp)),
    win_shares = replace_na(win_shares, min(win_shares)),
    win_shares_per48 = replace_na(win_shares_per48,min(win_shares_per48)),
    bpm_pctile = percent_rank(bpm),
    games_pctile = percent_rank(games),
    minutes_pctile = percent_rank(minutes),
    seasons_pctile = percent_rank(seasons),
    vorp_pctile = percent_rank(vorp),
    win_shares_pctile = percent_rank(win_shares),
    win_shares_per48_pctile = percent_rank(win_shares_per48)
  ) %>% 
  separate(position, c("position_1","position_2"), sep = '-') %>%
  mutate(pos_group = position_1,
         value = vorp,
         value_norm  = quicknorm(value),
         value_pctile = vorp_pctile,
         sport = 'nba',
         pos_group_b = paste0(pos_group, '(', sport, ')'))

nba_df_filter = nba_df %>% filter(pos_group != 'UNK')



#Merge dfs to an allsport_df #####
mlb_selected = mlb_df %>% select(
  team, team_id, games, pos_group, pos_group_b,  value, value_pctile, value_norm, draft_pick,draft_pick_pctile, draft_year, sport
)

nfl_selected = nfl_df %>% select(
  team, team_id,  games, pos_group, pos_group_b,  value, value_pctile, value_norm, draft_pick,draft_pick_pctile, draft_year, sport
)

nhl_selected = nhl_df %>% select(
  team, team_id,  games, pos_group, pos_group_b,  value, value_pctile, value_norm, draft_pick,draft_pick_pctile, draft_year, sport
)

nba_selected = nba_df %>% select(
  team, team_id,  games, pos_group, pos_group_b, value, value_pctile, value_norm, draft_pick,draft_pick_pctile, draft_year, sport
)

df_cols = c('team', 'team_id',  'pos_group', 'pos_group_b',  'value', 'value_norm','value_pctile', 'draft_pick','draft_pick_pctile', 'draft_year', 'sport', 'games')


merge_df_one = full_join(mlb_selected, nfl_selected, by = df_cols)
merge_df_two = full_join(nhl_selected, nba_selected, by = df_cols)

allsport_df = full_join(merge_df_one, merge_df_two, by = df_cols) %>%
  filter(!(pos_group %in% c('UNK(nba)','None(nhl)')))

allsport_df$sport = toupper(allsport_df$sport)

#dfs for labelling #####
pos_groups = allsport_df %>% group_by(pos_group, sport) %>% count() %>% select(pos_group, sport)
teams = allsport_df %>% group_by(team, sport) %>% count() %>% select(team, sport) %>% filter(team !=0, !is.na(team))
team_pos_groups  = allsport_df %>% group_by(sport, team, pos_group) %>% count() %>% select(sport, team, pos_group)

#color palatte #####
sportcolors = c(
  '#e41a1c',
  '#377eb8',
  '#4daf4a',
  '#984ea3'
)

names(sportcolors) = c('MLB', 'NBA', 'NFL', 'NHL')