
library(tidyverse)
library(shiny)
library(leaflet)
library(rgdal)
library(sp)
library(reactable)

readr::read_csv("data/vaxpal_map_data.csv") %>%
  dplyr::select( -`...1`) -> vaxpal_map_data

readr::read_csv("data/vaxpal_table_date.csv") %>%
  dplyr::select(-c(`...1`,`Last Update`)) -> vaxpal_table_date

shinyUI(navbarPage("VaxPal Explorer", id="nav", collapsible=T,
  tabPanel("Map",
    div(class="outer",

      tags$head(
        tags$link(rel = "stylesheet", type = "text/css",
          href = "ion.rangeSlider.skinFlat.css"),
        includeScript("spin.min.js"),
        includeCSS("styles.css")
      ),

      leafletOutput("mapAct", width="100%", height="100%"),
      tags$script("
var spinner = new Spinner().spin();
$( 'div#mymap' ).append(spinner.el);"),

      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 100, left = "auto", right = 20, bottom = "auto",
        width = 360, height = "auto",

        h2(),
        p(class="intro",
          "This app helps you to explore the Medicine Patent Pool's",
          a("VaxPal database",
            href="https://medicinespatentpool.org/what-we-do/disease-areas/vaxpal/",
            target="_blank")),
          tabPanel("Controls",
                   radioButtons("vaccine", label = h4("Select Vaccine"), choices = unique(vaxpal_map_data$vaccine)
                                )),
          
                   selectInput("status", label = h4("Legal Status"), choices = c("Granted","Pending","Abandoned","Rejected",
                                                                       "Expired","Withdrawn"),
                                selected = "Granted",multiple = FALSE)),
         ),

      tags$script('
Shiny.addCustomMessageHandler("map_done",
      function(s) {
        spinner.stop();
        $( "div#mymap" ).remove(spinner);
      });')

  ), tabPanel("Table", 
              reactable::reactableOutput("table")
              )
)
)

