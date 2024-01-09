## Load Libraries
library(shiny)
library(bslib)
library(bsicons)
library(shinyjs)

ui <- page_sidebar(title = NULL,theme =  bs_theme(),useShinyjs(),window_title = "AlloNavigatoR",
    ########################################################################
    ## Sidebar
    ########################################################################
    sidebar = sidebar(
                        width = 300,
                        tags$div(style = "text-align: center;", tags$img(src = "logo.png", width=100)),
                        fluidRow(column(12,h4("AlloNavigatoR"),align="center")),
                        fluidRow(column(12,helpText("This dashboard provides insights into the Allo Protocol Data for Arbitrum Chain for Round, Project or Donor level. Use the relevant tab and select the element and get the detailed stats on that level."),align="center")),
                        conditionalPanel("input.nav === 'Round'",uiOutput("roundsd")),
                        conditionalPanel("input.nav === 'Donor'",uiOutput("contsd")),
                        conditionalPanel("input.nav === 'Project'",uiOutput("projsd"))
                ),
    ########################################################################
    ########################################################################


    ########################################################################
    ## Main Panel
    ########################################################################
    navset_tab(
        id = "nav",selected="Overview",
        nav_panel(title = "Overview",
            br(),
            uiOutput("tabOV"),
            uiOutput("tabOP"),
        ),
        nav_panel(title = "Round",
            br(),
            uiOutput("tabRV"),
            uiOutput("tabTP"),
        ),
        nav_panel(title = "Project",
            br(),
            uiOutput("tabPV"),
            uiOutput("tabPP"),
        ),
        nav_panel(title = "Donor",
            br(),
            uiOutput("tabCV"),
            uiOutput("tabCP"),
        ),
    )
    ########################################################################
    ########################################################################
)