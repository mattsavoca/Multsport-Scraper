theme_set(theme_minimal())

#Distribution of Value, Grouped by Sport #####
allsport_df %>% 
  ggplot()+
  aes(x = value_norm, y=..scaled.., fill = sport, group = sport)+
  geom_density(alpha = .3)+
  scale_fill_manual(values = sportcolors)+
  scale_x_continuous(limits = c(-0.03, .25))+
  scale_y_continuous(breaks = NULL)+
  labs(
    title = "Distribution of Value, Grouped by Sport",
    x = "Value",
    y = ''
  )


#Pick Value by Draft Year, All Sports #####
allsport_df %>%
  ggplot()+
  aes(x = draft_year, y = value_norm)+
  geom_jitter(color = 'black', alpha = .05)+
  geom_smooth()+
  scale_fill_manual(values = sportcolors)+
  scale_y_continuous(limits = c(0, .1))+
  labs(
    title = "Pick Value by Draft Year, All Sports",
    y = "Average Pick Value (Normalized)",
    x = "Season"
  )

#Pick Value by Draft Year, Facet Sports #####
allsport_df %>%
  ggplot()+
  aes(x = draft_year, y = value_norm)+
  geom_jitter(aes(color = sport), alpha = .05)+
  geom_smooth(color = 'blue')+
  scale_fill_manual(values = sportcolors)+
  scale_y_continuous(limits = c(0, .1))+
  labs(
    title = "Pick Value by Draft Year, All Sports",
    y = "Value",
    x = "Season"
  )+ facet_grid(. ~ sport)+
  scale_color_manual(values = sportcolors)+
  theme(legend.position = "none")
#Pick Value by Draft Pick Percentile, Facet Sports#####
allsport_df %>%
  ggplot()+
  aes(x = draft_pick_pctile, y = value_norm, color = sport)+
  geom_jitter(alpha = .05)+
  geom_smooth(color = 'blue')+
  scale_color_manual(values = sportcolors)+
  scale_x_reverse()+
  theme(legend.position = "none")+
  labs(
    title = "Pick Value by Draft Pick Percentile, All Sports",
    y = "Value",
    x = "Draft Pick Percentile"
  )+facet_grid(~sport)
#High Value Picks by Draft Year #####
allsport_df %>%
  filter(draft_pick_pctile <= .25) %>%
  ggplot()+
  aes(x = draft_year, y = value_norm)+
  geom_jitter(aes(color = sport), alpha = .25)+
  geom_smooth(color = 'blue')+
  scale_fill_manual(values = sportcolors)+
  scale_y_continuous(limits = c(0, .1))+
  labs(
    title = "Value by Draft Year, Top Picks, All Sports",
    subtitle = 'First Quarter of Draft Picks in each Draft',
    y = "Value",
    x = "Season"
  )+ facet_grid(. ~ sport)+
  scale_color_manual(values = sportcolors)+
  scale_x_continuous(breaks = seq(1980, 2019,10))+
  theme(legend.position = "none")
#Positional Values by Sport, All Picks #####
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST'))) %>%
  group_by(pos_group) %>%
  summarize_if(is.numeric, mean, na.rm = T) %>%
  left_join(pos_groups, by = 'pos_group') %>%
  mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm =T)) %>%
  ungroup() %>%
  ggplot()+
  aes(y = value_norm, x = pos_group, fill = sport)+
  geom_col(position = "dodge", show.legend = F)+
  coord_flip()+
  scale_fill_manual(values = sportcolors)+
  labs(
    title = 'Average Pick Value by Sport',
    #subtitle = 'MLB: 10 Rounds, NHL: 2 Rounds, NFL: 1.75 Rounds, NBA: 0.5 Rounds',
    x = NULL,
    y = 'Value'
  )+
  facet_wrap(. ~ sport, scales = "free_y")+
  labs(
    title = "Positional Values by Sport, All Draft Picks"
  )
  


#Positional Values by Sport, Top Picks #####
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST')),
         draft_pick_pctile <= 0.25) %>%
  group_by(pos_group) %>%
  summarize_if(is.numeric, mean, na.rm = T) %>%
  left_join(pos_groups, by = 'pos_group') %>%
  mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm =T)) %>%
  ungroup() %>%
  ggplot()+
  aes(y = value_norm, x = pos_group, fill = sport)+
  geom_col(position = "dodge", show.legend = F)+
  coord_flip()+
  scale_fill_manual(values = sportcolors)+
  labs(
    title = "Positional Values by Sport, Top Picks",
    subtitle = 'First 25% of Draft Picks in Each Draft',
    x = NULL,
    y = 'Value'
  )+
  facet_wrap(. ~ sport, scales = "free_y")




#Distribution of High Value Picks by Position #####
allsport_df %>%
  filter(draft_pick_pctile <= .25,
         !(pos_group %in% c('UNK','None', 'ST'))) %>%
  mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm = T)) %>%
  ggplot()+
  aes(fill = sport, x = value_norm, y = pos_group)+
  geom_density_ridges()+
  scale_x_continuous(limits = c(-0.03, .1))+
  labs(
    title = 'Distribution of Pick Values by Sport and Position, Top Picks',
    subtitle = 'First 25% of Draft Picks in Each Draft',
    y = NULL,
    x = 'Value'
  )+
  facet_wrap(~sport, scales="free")+
  theme(legend.position = "none")+
  scale_fill_manual(values = sportcolors)









#Positional Values by Sport, Late Picks #####
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST')),
         draft_pick_pctile >= 0.75) %>%
  group_by(pos_group) %>%
  summarize_if(is.numeric, mean, na.rm = T) %>%
  left_join(pos_groups, by = 'pos_group') %>%
  mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm =T)) %>%
  ungroup() %>%
  ggplot()+
  aes(y = value_norm, x = pos_group, fill = sport)+
  geom_col(position = "dodge", show.legend = F)+
  coord_flip()+
  scale_fill_manual(values = sportcolors)+
  labs(
    title = "Positional Values by Sport, Late Picks",
    subtitle = 'Last 25% of Draft Picks in Each Draft',
    x = NULL,
    y = 'Value'
  )+
  facet_wrap(. ~ sport, scales = "free_y")





#Distribution of Late Picks by Position #####
allsport_df %>%
  filter(draft_pick_pctile <= .25,
         !(pos_group %in% c('UNK','None', 'ST'))) %>%
  mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm = T)) %>%
  ggplot()+
  aes(fill = sport, x = value_norm, y = pos_group)+
  geom_density_ridges()+
  scale_x_continuous(limits = c(-0.03, .1))+
  labs(
    title = 'Distribution of Pick Values by Sport and Position, Late Picks',
    subtitle = 'Last 25% of Draft Picks in Each Draft',
    y = NULL,
    x = 'Value'
  )+
  facet_wrap(~sport, scales="free")+
  theme(legend.position = "none")+
  scale_fill_manual(values = sportcolors)

#Pick Values by Team, Top Picks ######
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST')),
         draft_pick_pctile <= 0.25) %>%
  group_by(team) %>%
  summarize_if(is.numeric, mean, na.rm = T) %>%
  left_join(teams, by = 'team') %>%
  mutate(team = reorder(team, value_norm, mean, na.rm =T)) %>%
  ungroup() %>%
  ggplot()+
  aes(y = value_norm, x = team, fill = sport)+
  geom_col(position = "dodge", show.legend = F)+
  coord_flip()+
  scale_fill_manual(values = sportcolors)+
  labs(
    title = "Comparing top NFL, NHL, & NBA Franchises' Top Picks",
    subtitle = 'First 25% of Draft Picks in Each Draft',
    x = NULL,
    y = 'Value'
  )+
  facet_wrap(. ~ sport, scales = "free_y", nrow = 1)
#Pick Values by Team, All Picks ######
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST')),
         team != 0) %>%
  group_by(team) %>%
  summarize_if(is.numeric, mean, na.rm = T) %>%
  left_join(teams, by = 'team') %>%
  mutate(team = reorder(team, value_norm, mean, na.rm =T)) %>%
  ungroup() %>%
  ggplot()+
  aes(y = value_norm, x = team, fill = sport)+
  geom_col(position = "dodge", show.legend = F)+
  coord_flip()+
  scale_fill_manual(values = sportcolors)+
  labs(
    title = "Pick Value by Team, All Picks",
    subtitle = 'First 25% of Draft Picks in Each Draft',
    x = NULL,
    y = 'Value'
  )+
  facet_wrap(. ~ sport, scales = "free_y", nrow = 1)

#Postional Value by Draft Pick Percentile #####
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST'))) %>%
  ggplot()+
  aes(x = draft_pick_percentile, y = value_norm,color = sport)+
  geom_jitter(alpha = .05)+
  geom_smooth(color = 'blue')+
  scale_color_manual(values = sportcolors)+
  theme(legend.position = "none")+
  labs(
    title = "Positional Value by Draft Pick Percentile, All Sports",
    y = "Value",
    x = "Draft Pick Percentile"
  )+facet_wrap(sport~pos_group, scales = "free", ncol = 4)

#Postional Value by Draft Year #####
allsport_df %>%
  filter(!(pos_group %in% c('UNK','None', 'ST'))) %>%
  ggplot()+
  aes(x = draft_pick_pctile, y = value_norm,color = sport)+
  geom_jitter(alpha = .05)+
  geom_smooth(color = 'blue')+
  scale_color_manual(values = sportcolors)+
  scale_x_reverse()+
  theme(legend.position = "none")+
  labs(
    title = "Positional Value by Draft Pick Percentile, All Sports",
    y = "Value",
    x = "Draft Pick Percentile"
  )+facet_wrap(sport~pos_group, scales = "free", ncol = 4)

