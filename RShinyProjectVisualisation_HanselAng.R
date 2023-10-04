# Load packages ----------------------------------------------------------------



library(shiny)
library(ggplot2)
library(tools)
library(shinythemes)
library(dplyr)
library(DT)


# Load data --------------------------------------------------------------------



Data <- read.csv(file = "https://raw.githubusercontent.com/HanselAng/tuberculosis-visualisation/main/TB_dataset_2023-10-02.csv", header = TRUE, sep = ",")



# Define UI --------------------------------------------------------------------



ui <- fluidPage(
  theme = shinytheme("readable"),
  navbarPage( "Tuberculosis Cases",
              tabPanel("Visualisation",
                       titlePanel(title = h5("The Global Tuberculosis Programme began asking global and regional priority countries for the provisional number of new and relapse TB cases notified to health authorities. This will provide a visualisation of the data.", align="center")),
                       titlePanel(title = h6("by Hansel Ang", align="center")),
                       br(),
                       sidebarLayout(
                         sidebarPanel(
                           selectInput(
                             inputId = "y",
                             label = "Y-axis:",
                             choices = c(
                               "Country" = "country",
                               "Country Code" = "iso2",
                               "Region" = "g_whoregion",
                               "Year" = "year",
                               "Total Cases" = "m_01"
                             ),
                             selected = "Country"
                           ),
                           
                           selectInput(
                             inputId = "x",
                             label = "X-axis:",
                             choices = c(
                               "Region" = "g_whoregion",
                               "Country" = "country",
                               "Country Code" = "iso2",
                               "Year" = "year",
                               "Total Cases" = "m_01"
                             ),
                             selected = "Region"
                           ),
                           
                           selectInput(
                             inputId = "z",
                             label = "Color by:",
                             choices = c(
                               "Year" = "year",
                               "Country" = "country"
                             ),
                             selected = "Year"
                           ),
                           
                           sliderInput(
                             inputId = "alpha",
                             label = "Alpha:",
                             min = 0, max = 1,
                             value = 0.5
                           ),
                           
                           sliderInput(
                             inputId = "size",
                             label = "Size:",
                             min = 0, max = 5,
                             value = 2
                           ),
                         ),
                         mainPanel(
                           plotOutput(outputId = "scatterplot", height = "1000px", width="600px", brush = brushOpts(id = "plot_brush")),
                           br(),
                           plotOutput("barplot", height="1000px")
                         ),
                       )),
              tabPanel("User Guide",
                       
                       tags$div(
                         "This guide provides a step-by-step explanation of how to utilize the application.", tags$br(),
                         "Instructions:", tags$br(),
                         "1. By default, the application will upload the .csv file from Github. However, you have the option to change this file and use a different set of data.", tags$br(),
                         "2. Upon loading the page, you will see the following sections:", tags$br(),
                         "a. Left panel - This section is primarily used for the Scatter Plot options It allows you to select the x-axis, y-axis, and z-axis. Additionally, you can choose the alpha and size, as well as input a desired title.", tags$br(),
                         "b. Upper right panel - This section displays the scatter plot.", tags$br(),
                         "c. Lower left panel - This section showcases a bar graph.", tags$br()
                         
                         
                       )
                       
              )
  )
)



# Define server ----------------------------------------------------------------



server <- function(input, output, session) {
  
  output$scatterplot <- renderPlot({
    ggplot(data = Data, aes_string(x = input$x, y = input$y, color = input$z)) +
      geom_point(alpha = input$alpha, size = input$size)
  })
  
  output$datatable <- renderDataTable({
    brushedPoints(Data, brush = input$plot_brush) %>%
      select(country, m_01)
  })
  
  output$barplot <- renderPlot({
    g <- ggplot(Data, aes(y=country, x=year))
    g + geom_bar(stat = "sum")
  })
  
}

# Create the Shiny app object --------------------------------------------------

shinyApp(ui = ui, server = server)
