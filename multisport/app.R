# LIBRARIES ####
library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(ggrepel)
library(ggridges)
library(ggthemes)

# GLOBAL #####
theme_set(theme_fivethirtyeight())
  #get all CSVs ######
allsport_df = read_csv('allsport_df.csv', col_types = cols(pos_group = "c")) %>% filter(!(pos_group %in% c('UNK','ST','None')))
pos_groups = read_csv('pos_groups.csv')
team_pos_groups = read_csv('team_pos_groups.csv')
teams = read_csv('teams.csv')


  #color palatte #####
sportcolors = c(
  '#e41a1c',
  '#377eb8',
  '#4daf4a',
  '#984ea3'
)

names(sportcolors) = c('MLB', 'NBA', 'NFL', 'NHL')


  #position groups #####
position_groups = sort(unique(allsport_df$pos_group_b))

# UI #####
ui <- shinyUI(dashboardPage(title="Browser title",
  # Header and Skin #####
  skin = "green",
  dashboardHeader(title = h4('Evaluating the Evaluators')),
  # SidebarMenu #####
  dashboardSidebar(
    sidebarMenu(
      menuItem('Value by Year and Pick Percentile', tabName = "val_year", icon = icon("line-chart")),
      menuItem('Cumulative Draft Values by Year', tabName = "draftcumval", icon = icon("random")),
      menuItem('Top 60 Picks', tabName = "top60", icon = icon("star")),
      menuItem('Value Distributions', tabName = "values", icon = icon("area-chart")),
      menuItem('Positional Value Curves', tabName = "posfacet", icon = icon("share-alt")),
      menuItem('Avg. Positional Values', tabName = "positions", icon = icon("users")),
      menuItem('Team Values', tabName = "teams", icon = icon("bar-chart"))
                ),
    sliderInput("percentile",
                "Filter by Draft Pick Percentile:",
                min = min(allsport_df$draft_pick_pctile, na.rm = T),
                max = max(allsport_df$draft_pick_pctile, na.rm = T),
                value = .25),
    sliderInput("year",
                "Filter by Draft Year:",
                min = min(allsport_df$draft_year, na.rm = T),
                max = max(allsport_df$draft_year, na.rm = T),
                value = c(1979, 2019), sep = ""),
    selectizeInput(
      'posgroup', 'Filter by Position Group:', choices = position_groups, multiple = TRUE, selected = position_groups
    )),
  # Body #####
    dashboardBody(
        tabItems(
        tabItem(tabName = "val_year",
          h4('Values by Year'),
          plotOutput("val_year"),
          h4('Values by Draft Pick Percentile'),
          plotOutput("val_percentile")
                ),
        tabItem(tabName = 'draftcumval',
          h4('Cumulative Draft Values'),
          plotOutput('draftcumval')
        ),
        tabItem(tabName = "values",
          h4('Distributions of Values by Sport'),
          plotOutput("sportvaldist")
        ),
        tabItem(tabName = "posfacet",
          plotOutput('indposval')
        ),
        tabItem(tabName = "top60",
                h4('Top 60 Picks Analysis'),
                sliderInput("top60filter",
                            "Filter by Draft Pick",
                            min = min(allsport_df$draft_pick, na.rm = T),
                            max = 60,
                            value = c(1,60), sep = ""),
                plotOutput("val_top60")
        ),
        tabItem(tabName = "positions",
          h4('Positional Values'),
          plotOutput("positionbar"),
          plotOutput("positiondp")
                ),
        tabItem(tabName = "teams",
          h4('Individual Team Analysis'),
          selectizeInput(
            'teams', 'Select Team(s):', choices = sort(unique(allsport_df$team)), multiple = TRUE, selected = 'Pittsburgh Steelers'
                ),
          plotOutput('teamvals'),
          plotOutput('teamvalsdp')
        )
      )
    )
  )
)

# SERVER ######
server <- function(input, output, session) {
  
# reactive dfs #####
  allsport_reactive = reactive({
    allsport_df %>%
      filter(draft_pick_pctile <= input$percentile&
             !(pos_group %in% c('ST','UNK','None'))&
             draft_year %in%  seq(min(input$year, na.rm =T), max(input$year, na.rm =T),1)&
             pos_group_b %in% input$posgroup)
  })
  
  team_reactive = reactive({
      allsport_reactive() %>%
      filter(team %in% input$teams)
      
  })
  
  top60_reactive = reactive({
    allsport_df %>%
      filter(draft_pick %in% seq(min(input$top60filter), max(input$top60filter),1))
  })

  
#outputs #####
   output$val_year = renderPlot({
    allsport_reactive() %>% 
      ggplot()+
      aes(x = draft_year, y = value_norm)+
      geom_jitter(aes(color = sport), alpha = .05)+
      geom_smooth(color = 'blue')+
      scale_fill_manual(values = sportcolors)+
      labs(
        title =paste0('Pick Value by Draft Year, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
        subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
        y = "Value",
        x = "Season"
      )+ facet_grid(. ~ sport)+
      scale_y_continuous(limits = c(0,.1))+
      scale_color_manual(values = sportcolors)+
      theme(legend.position = "none")
  })
   output$val_percentile = renderPlot({
    allsport_reactive() %>% 
      ggplot()+
      aes(x = draft_pick_pctile, y = value_norm)+
      geom_jitter(aes(color = sport), alpha = .05)+
      geom_smooth(color = 'blue')+
      scale_fill_manual(values = sportcolors)+
      scale_y_continuous(limits = c(0, .1))+
      scale_x_reverse()+
      labs(
        title =paste0('Pick Value by Draft Pick Percentile, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
        subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
        y = "Value",
        x = "Draft Pick Percentile"
      )+ facet_grid(. ~ sport)+
      scale_color_manual(values = sportcolors)+
      theme(legend.position = "none")
  })
   output$indposval = renderPlot({
     allsport_reactive() %>%
       arrange(sport) %>%
       ggplot()+
       aes(x = draft_pick_pctile, y = value_norm,color = sport)+
       geom_jitter(alpha = .05)+
       geom_smooth(se=F)+
       scale_color_manual(values = sportcolors)+
       theme(legend.position = "none")+
       scale_y_continuous(limits = c(0, 0.15))+
       labs(
         title = "Positional Value by Draft Pick Percentile, All Sports",
         y = "Value",
         x = "Draft Pick Percentile"
       )+facet_wrap(pos_group~sport, ncol = 4)
   })
   output$draftcumval = renderPlot({
   allsport_reactive() %>%
     group_by(draft_year, sport) %>%
     summarize_if(is.numeric, sum,na.rm =T) %>%
     ggplot()+
     aes(y = value_norm, x = draft_year, color = sport, group = sport)+
     geom_jitter()+
     geom_smooth(show.legend = F)+
     labs(
         title =paste0('Cumulative Draft Value by Sport, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
         subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
         y = "Value",
         x = "Draft Pick Percentile"
       )   
       })
   output$val_top60 = renderPlot({
     top60_reactive() %>%
       filter(draft_pick <= 60) %>%
       ggplot()+
       aes(x = draft_pick, y = value_norm)+
       geom_jitter(aes(color = sport), alpha = .05)+
       geom_smooth(color = 'blue')+
       scale_fill_manual(values = sportcolors)+
       scale_y_continuous(limits = c(0, .1))+
       labs(
         title =paste0('Pick Value by Draft Pick, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
         subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
         y = "Value",
         x = "Draft Pick Percentile"
       )+ facet_grid(. ~ sport)+
       scale_color_manual(values = sportcolors)+
       theme(legend.position = "none")
   })
   output$sportvaldist = renderPlot({
      allsport_reactive() %>% 
        ggplot()+
        aes(x = value_norm, y=..scaled.., fill = sport, group = sport)+
        geom_density(alpha = .3)+
        scale_fill_manual(values = sportcolors)+
        scale_x_continuous(limits = c(-0.03, .25))+
        scale_y_continuous(breaks = NULL)+
        labs(
          title =paste0('Distribution of Player Values, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
          x = "Value",
          subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
          y = '')
   })
   output$positionbar = renderPlot({
     allsport_reactive() %>%
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
         title =paste0('Positional Values by Sport, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
         subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
         x = NULL,
         y = 'Value'
       )+
       facet_wrap(. ~ sport, scales = "free_y")
   })
   output$positiondp = renderPlot({
     allsport_reactive() %>%
       mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm = T)) %>%
       ggplot()+
       aes(fill = sport, x = value_norm, y = pos_group)+
       geom_density_ridges()+
       scale_x_continuous(limits = c(-0.03, .1))+
       labs(
         title =paste0('Dsitribution of Positional Values by Sport, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
         subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
         y = NULL,
         x = 'Value'
       )+
       facet_wrap(~sport, scales="free")+
       theme(legend.position = "none")+
       scale_fill_manual(values = sportcolors)
   })
   output$teamvals = renderPlot({
     team_reactive() %>%
       mutate(pos_group = reorder(pos_group, value_norm, mean, na.rm = T)) %>%
       ggplot()+
       aes(x = pos_group, y = value_norm, fill = sport)+
       stat_summary(fun.y = "mean", size = 2, geom = "bar")+
       coord_flip()+
       scale_fill_manual(values = sportcolors)+
       labs(
         title =paste0('Positional Values, ',  ifelse(input$percentile == 1, 'All Picks',paste0('Top ',round(input$percentile*100),'% of Drafts'))),
         subtitle = paste0('All Drafts, ', min(input$year),' to ', max(input$year)),
         x = NULL,
         y = 'Value'
       )+facet_wrap(team ~ ., scales = "free_y", nrow = 1)
   })
   output$teamvalsdp = renderPlot({
     team_reactive() %>%
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
       facet_wrap(team~sport, scales="free")+
       theme(legend.position = "none")+
       scale_fill_manual(values = sportcolors)
   })
}

# RUN #####
shinyApp(ui = ui, server = server)

